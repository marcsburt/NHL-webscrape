library(plyr)
library(dplyr)
library(rvest)
library(ggmap)
library(leaflet)
library(RColorBrewer)
library(XML)
library(xml2)
library(RSelenium)
library(stringr)
library(RPostgreSQL)

setwd("/home/marcburt/web_scrape")
load(file = "nhl.RData")

base <- 'http://www.hockey-reference.com'
leagues <- paste(base,"/leagues", sep ='')

url <- read_html(leagues)
top.table.selector <- "#league_index"
top.table<- url %>%
	html_nodes(top.table.selector) %>%
	html_table()
top.table[[1]][3:13,] #season didn't happen. Split them up.
top.table[[1]][15:37,]


url.selector = 'td:nth-child(2) a'
url.seasons <- url %>%
  html_nodes(url.selector) %>%
  html_attr("href")
top.urls <- unlist(paste0(base, url.seasons))
year.urls <- top.urls[2:37]



###---- GET TEAM STATS ----###

myteams <- list()
years.list <- c()
lnum <- 1
for(i in year.urls){
	east <- readHTMLTable(i, which = 1)
	west <- readHTMLTable(i, which = 2)
	east$DIV <- "East"
	west$DIV <- "West"

	teams <- as.data.frame(rbind(east, west))
	teams <- teams[complete.cases(teams),]
	
	names(teams)[1] <- "Team_Name"
	teams$Team_Name <- gsub("\\*", "", teams$Team_Name)
	year <- strsplit(i, "[^[:digit:]]")
	num.year <- as.numeric(unlist(year))
	num.year <- num.year[!is.na(num.year)]
	teams$Season_Ended <- num.year

	myteams[[lnum]] <- teams
	lnum <- lnum + 1

	years.list <- c(years.list, num.year)
	
}

teams.stats.df <- ldply(myteams, data.frame)
teams.df <- unique(teams.stats.df$Team_Name)


### --- gather team urls -- ###

ateam.links <- c()
for(i in years.list){

	yearly.url <- paste0("http://www.hockey-reference.com/leagues/NHL_", i ,".html")
	doc <- htmlParse(yearly.url)
	links <- xpathSApply(doc, "//a/@href")
	m <- glob2rx(paste0("/teams/*/", i, "*"))
	teams.links <- unique(subset(links, grepl(m, links)))
	fteams.links <- paste0(base, teams.links)
	ateam.links <- c(ateam.links, fteams.links)
}

#-------------------GET ALL PLAYERS------------------------#

c.rosters <- data.frame()
counter = 0
for(i in ateam.links){
	roster <- readHTMLTable(i, which = 2)
	roster$Team <- str_sub(i, -13, -11)
	roster <- subset(roster, select = -c(Exp, Wt, Age, Summary, Pos))
	c.rosters <- unique(rbind(c.rosters, roster))
	counter = counter + 1
	if(counter %% 50 == 0) {
		print(paste("Still working at number", counter))
	}
}
players.df <- c.rosters

#-----------------------GET ALL STATS FOR FIELD PLAYERS-------------------#

field.stats <- data.frame()
goalie.stats <- data.frame()
counter <- 0
for(i in ateam.links){
	
	team <- str_sub(i, -13, -11)
	year <- as.numeric(str_sub(i, -9, -6))

	regular.season <- readHTMLTable(i, which = 3)
	regular.season <- regular.season[,1:24]
	regular.season$Team <- team
	regular.season$Season_Ended <- year
	field.stats <- rbind(field.stats, regular.season)
	
	goalies.season <- readHTMLTable(i, which = 4)
	goalies.season$Team <- team
	goalies.season$Season_Ended <- year
	goalie.stats <- rbind(goalie.stats, goalies.season)

	counter <- counter +1
	if(counter %% 50 == 0){
		print(paste("Still working at number", counter))
	}
}
players.stats.df <- field.stats
names(players.stats.df)
goalies.stats.df <- goalie.stats
goalie.stats.df <- goalies.stats.df[,-21]


#-------add accr to team names ------------------------#
unique.accry<- sort(unique.accry)
unique.accry<-unique.accry[-38]
teams.df <- data.frame(Team_Name = sort(teams.df), Team_Accry = unique.accry)
teams.df



#------------------adding data tables to postgresql -----------------------#



drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = 'nhldb', host = 'localhost', user = 'postgres', password = pw)



dbWriteTable(con, "teams", teams.df, row.names = FALSE)
dbWriteTable(con, "team_stats", teams.stats.df, row.names = FALSE)
dbWriteTable(con, "players", players.df, row.names = FALSE)
dbWriteTable(con, "player_stats", players.stats.df, row.names = FALSE)
dbWriteTable(con, "goalies_stat", goalie.stats.df, row.names = FALSE)

dbGetQuery(con, "SELECT * FROM teams WHERE team_name == 'Anaheim Ducks'")
dbReadTable(con, "Players")
dbExistsTable(con, "Goalie_Stats")




save.image(file = "nhl.RData")
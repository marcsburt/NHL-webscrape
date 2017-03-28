library(rvest)
library(xml2)

NHL.stats <- read_html('http://www.hockey-reference.com/leagues/')
summary(NHL.stats)
xml_children(NHL.stats)
xml_contents(NHL.stats)
NHL.stats$doc

toptable <- NHL.stats %>%
	html_nodes(xpath = '//*[@id = "league_index"]') %>%
	html_table()
head(toptable[[1]][4])



library(rvest)

url <- "http://www.ajnr.org/content/30/7/1402.full"
page <- read_html(url)

# First find all the urls
table_urls <- page %>% 
  html_nodes(".table td:nth-child(1) a") %>%
  html_attr("href") %>%
  html_text()

# Then loop over the urls, downloading & extracting the table
lapply(table_urls, . %>% read_html() %>% html_table())

table_urls 
//*[@id="league_index"]

//*[@id="league_index"]/tbody

url = "http://www.hockey-reference.com/teams/FLA/2016.html"

year <- strsplit(i, "[^[:digit:]]")
num.year <- as.numeric(unlist(year))
num.year <- num.year[!is.na(num.year)]
num.year

roster <- readHTMLTable(test.link, which = 2)
regular.season <- readHTMLTable(test.link, which = 3)
goalies <- readHTMLTable(test.link, which = 4)
playoffs <- readHTMLTable(test.link, which = 5)
1:20
for (i in 1:5){
	try({
	thing <- readHTMLTable(test.link, which = i)
	print(thing)
	})
	print(i)
}



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
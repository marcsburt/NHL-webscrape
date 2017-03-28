#league_index > tbody > tr:nth-child(1) > td:nth-child(2)
#standings_EAS

east.selector <- "#standings_EAS"
team.url <- read_html(urls.top[2])
east <- read_html(urls.top[2]) %>%
	html_nodes(east.selector) %>%
	html_table()
head(east)


for(i in seq_along(urls.top)){
}

team.grab.tables <- function(url.list){

	team.urls <- list()
	for(i in seq_along(url.list)){

	}

}

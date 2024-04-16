## Webscraping

install.packages("rvest")
library(rvest)

#which website (trustpilot allows scraping)
url <- 'https://www.trustpilot.com/review/redrobin.com'

#creat empty list to loop each page into
all_reviews <- list()

# Loop through each page
for (page in 1:5) {
  # Construct the URL for the current page
  all_pages <- sprintf(url, page)
  
  #reads html on site
  webpage <- read_html(all_pages)
  
  #creates columns
  #for title -> use 'selector gadget' > select title, deselect useless info
  title_html <- html_nodes(webpage, '.link_notUnderlined__szqki .typography_appearance-default__AAY17')
  content_html <- html_nodes(webpage, '.typography_color-black__5LYEn')
  
  
  #show text in html title
  title <- html_text(title_html)
  content <- html_text(content_html)

  #Make data frame with text
  page_reviews <- data.frame(Review = title, Content = content)
  # Store the data frame in the list
  all_reviews[[page]] <- page_reviews
}
# Combine data frames for all pages into a single data frame
all_reviews_df <- do.call(rbind, all_reviews)

#To find- click session > set working directory > choose directory >
write.csv(all_reviews_df, "Data for JMP")


##Extra Practice
url <- "http://books.toscrape.com/catalogue/category/books/travel_2/index.html"




















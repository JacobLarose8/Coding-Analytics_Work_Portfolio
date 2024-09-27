## Data mining Test

library(rvest)
library(dplyr)

# Base URL for each page
base_url <- 'https://reviews.webmd.com/drugs/drugreview-2798-oxycontin-oral?page=%d'

# Create an empty list to store reviews from each page
all_reviews <- list()

# Loop through multiple pages
for (page in 1:72) {  # Adjust the number of pages you want to scrape
  # Construct the URL for the current page
  page_url <- sprintf(base_url, page)
  
  # Read HTML from the current page
  webpage <- read_html(page_url)
  
  # Extract the review block for each review (this keeps everything in order)
  review_blocks <- html_nodes(webpage, '.review-details-holder')
  
  # Loop through each review block to extract details
  for (block in review_blocks) {
    # Extract condition, review text, name (containing age/gender/date), and rating
    condition <- html_text(html_node(block, '.condition'), trim = TRUE)
    text_review <- html_text(html_node(block, '.description-text'), trim = TRUE)
    name <- html_text(html_node(block, '.card-header'), trim = TRUE)
    ovr_rating <- html_text(html_node(block, '.overall-rating strong'), trim = TRUE)
    
    # If any of the extracted data is missing, set it to NA
    condition <- ifelse(length(condition) == 0, NA, condition)
    text_review <- ifelse(length(text_review) == 0, NA, text_review)
    name <- ifelse(length(name) == 0, NA, name)
    ovr_rating <- ifelse(length(ovr_rating) == 0, NA, ovr_rating)
    
    # Extract additional information (age, gender, date) from the "name" field
    age <- gsub(".*\\|\\s*([0-9]+-[0-9]+)\\s*\\|.*", "\\1", name)
    gender <- gsub(".*\\|\\s*(Male|Female)\\s*\\|.*", "\\1", name)
    date <- gsub(".*(\\d{1,2}/\\d{1,2}/\\d{4}).*", "\\1", name)
    
    # Convert date to Date type
    date <- as.Date(date, format = "%m/%d/%Y")
    
    # Store this review's data in a data frame
    review_data <- data.frame(
      Condition = condition,
      Review = text_review,
      Name = name,
      Star_Rating = ovr_rating,
      Age = age,
      Gender = gender,
      Review_Date = date,
      stringsAsFactors = FALSE
    )
    
    # Append the data frame to the list
    all_reviews[[length(all_reviews) + 1]] <- review_data
  }
}

# Combine data frames for all pages into a single data frame
all_reviews_df <- do.call(rbind, all_reviews)

# Sort by Review_Date to keep the most recent reviews on top
all_reviews_df <- all_reviews_df %>%
  arrange(desc(Review_Date))

# Print or save the results
print(all_reviews_df)

# Optionally, save to CSV
write.csv(all_reviews_df, "webmd_oxycontin_reviews.csv", row.names = FALSE)


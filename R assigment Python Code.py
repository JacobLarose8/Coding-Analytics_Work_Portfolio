# Install and load the reticulate package in R for running in RStudio, does not run in python

install.packages("reticulate")

library(reticulate)

# Install required Python packages
py_install("requests")
py_install("pandas")
py_install("beautifulsoup4")

# Import Python packages
py_run_string("import requests")
py_run_string("import pandas as pd")
py_run_string("from bs4 import BeautifulSoup")



# Actual Python code
#Scraping code
import requests
import pandas as pd
from bs4 import BeautifulSoup

# Define the URL
url = 'https://www.trustpilot.com/review/redrobin.com'

# Create an empty list to store reviews
all_reviews = []

# Loop through each page
for page in range(1, 6):
    # Construct the URL for the current page
    current_url = f"{url}?page={page}"
    
    # Send an HTTP request to the website
    response = requests.get(current_url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Extract review titles and content
    titles = [title.text for title in soup.select('.link_notUnderlined__szqki .typography_appearance-default__AAY17')]
    contents = [content.text for content in soup.select('.typography_color-black__5LYEn')]
    
    # Create a DataFrame for the current page
    page_reviews = pd.DataFrame({'Review': titles, 'Content': contents})
    
    # Append to the list of all reviews
    all_reviews.append(page_reviews)

# Combine DataFrames for all pages into a single DataFrame
all_reviews_df_py = pd.concat(all_reviews, ignore_index=True)

# Print the resulting DataFrame
print(all_reviews_df_py)

#Write into CSV
all_reviews_df.to_csv("Data_for_JMP.csv", index=False)


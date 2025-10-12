#!/usr/bin/env Rscript

# Startup script for Family Dinner Tracker
# This script checks dependencies and launches the Shiny app

cat("Family Dinner Tracker - Startup Script\n")
cat("=======================================\n\n")

# Check for required packages
required_packages <- c("shiny", "DT", "dplyr", "lubridate", "RSQLite", "quarto")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(missing_packages) > 0) {
  cat("Missing packages detected:", paste(missing_packages, collapse = ", "), "\n")
  cat("Installing missing packages...\n\n")
  install.packages(missing_packages, repos = "https://cran.rstudio.com/")
}

# Check if database exists
if (!file.exists("dinner_data.db")) {
  cat("Database not found. Creating new database...\n")
  cat("Would you like to initialize with sample data? (y/n): ")
  
  # For automated runs, you can comment out the readline and set response directly
  response <- readline()
  
  if (tolower(response) == "y") {
    cat("Initializing sample data...\n")
    source("init_sample_data.R")
  }
}

cat("\nLaunching Shiny app...\n")
cat("Press Ctrl+C to stop the application\n\n")

# Launch the app
shiny::runApp("app.R", launch.browser = TRUE)

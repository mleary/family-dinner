# Test Suite for Family Dinner Tracker
# Run with: testthat::test_file("tests/test_app.R")

library(testthat)
library(RSQLite)
library(dplyr)

# Setup test database
setup_test_db <- function() {
  # Remove test database if it exists
  if (file.exists("test_dinner_data.db")) {
    file.remove("test_dinner_data.db")
  }
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # Create tables
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS dinners (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      menu TEXT,
      notes TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS ratings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dinner_id INTEGER NOT NULL,
      user_name TEXT NOT NULL,
      rating INTEGER CHECK(rating >= 1 AND rating <= 5),
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (dinner_id) REFERENCES dinners(id)
    )
  ")
  
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dinner_id INTEGER NOT NULL,
      user_name TEXT NOT NULL,
      comment TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (dinner_id) REFERENCES dinners(id)
    )
  ")
  
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS suggestions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_name TEXT NOT NULL,
      suggestion TEXT NOT NULL,
      status TEXT DEFAULT 'pending',
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  dbDisconnect(con)
}

# Teardown test database
teardown_test_db <- function() {
  if (file.exists("test_dinner_data.db")) {
    file.remove("test_dinner_data.db")
  }
}

# Test: Database Creation
test_that("Database tables are created correctly", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  tables <- dbListTables(con)
  dbDisconnect(con)
  
  expect_true("dinners" %in% tables)
  expect_true("ratings" %in% tables)
  expect_true("comments" %in% tables)
  expect_true("suggestions" %in% tables)
  
  teardown_test_db()
})

# Test: Adding Dinner
test_that("Can add a dinner to the database", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinners <- dbGetQuery(con, "SELECT * FROM dinners")
  dbDisconnect(con)
  
  expect_equal(nrow(dinners), 1)
  expect_equal(dinners$date, "2025-10-12")
  expect_equal(dinners$menu, "Test Menu")
  expect_equal(dinners$notes, "Test Notes")
  
  teardown_test_db()
})

# Test: Adding Rating
test_that("Can add a rating to a dinner", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # First add a dinner
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  
  # Add rating
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, "Test User", 5))
  
  ratings <- dbGetQuery(con, "SELECT * FROM ratings")
  dbDisconnect(con)
  
  expect_equal(nrow(ratings), 1)
  expect_equal(ratings$dinner_id, dinner_id)
  expect_equal(ratings$user_name, "Test User")
  expect_equal(ratings$rating, 5)
  
  teardown_test_db()
})

# Test: Adding Comment
test_that("Can add a comment to a dinner", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # First add a dinner
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  
  # Add comment
  dbExecute(con, 
    "INSERT INTO comments (dinner_id, user_name, comment) VALUES (?, ?, ?)",
    params = list(dinner_id, "Test User", "Great dinner!"))
  
  comments <- dbGetQuery(con, "SELECT * FROM comments")
  dbDisconnect(con)
  
  expect_equal(nrow(comments), 1)
  expect_equal(comments$dinner_id, dinner_id)
  expect_equal(comments$user_name, "Test User")
  expect_equal(comments$comment, "Great dinner!")
  
  teardown_test_db()
})

# Test: Adding Suggestion
test_that("Can add a suggestion", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  dbExecute(con, 
    "INSERT INTO suggestions (user_name, suggestion) VALUES (?, ?)",
    params = list("Test User", "Try pizza!"))
  
  suggestions <- dbGetQuery(con, "SELECT * FROM suggestions")
  dbDisconnect(con)
  
  expect_equal(nrow(suggestions), 1)
  expect_equal(suggestions$user_name, "Test User")
  expect_equal(suggestions$suggestion, "Try pizza!")
  expect_equal(suggestions$status, "pending")
  
  teardown_test_db()
})

# Test: Rating Constraints
test_that("Rating must be between 1 and 5", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # First add a dinner
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  
  # Try to add invalid rating (should fail)
  expect_error(
    dbExecute(con, 
      "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
      params = list(dinner_id, "Test User", 10))
  )
  
  dbDisconnect(con)
  teardown_test_db()
})

# Test: Get Latest Dinner
test_that("Can retrieve the latest dinner", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # Add multiple dinners
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-10", "Dinner 1", "Notes 1"))
  
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Dinner 2", "Notes 2"))
  
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-11", "Dinner 3", "Notes 3"))
  
  # Get latest
  latest <- dbGetQuery(con, "SELECT * FROM dinners ORDER BY date DESC LIMIT 1")
  dbDisconnect(con)
  
  expect_equal(latest$date, "2025-10-12")
  expect_equal(latest$menu, "Dinner 2")
  
  teardown_test_db()
})

# Test: Multiple Ratings Average
test_that("Can calculate average rating correctly", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # Add a dinner
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  
  # Add multiple ratings
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, "User 1", 5))
  
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, "User 2", 4))
  
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, "User 3", 3))
  
  # Calculate average
  ratings <- dbGetQuery(con, 
    "SELECT AVG(rating) as avg_rating FROM ratings WHERE dinner_id = ?",
    params = list(dinner_id))
  
  dbDisconnect(con)
  
  expect_equal(ratings$avg_rating, 4.0)
  
  teardown_test_db()
})

# Test: Foreign Key Relationship
test_that("Ratings are linked to dinners via foreign key", {
  setup_test_db()
  
  con <- dbConnect(RSQLite::SQLite(), "test_dinner_data.db")
  
  # Add a dinner
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list("2025-10-12", "Test Menu", "Test Notes"))
  
  dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id
  
  # Add rating
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, "Test User", 5))
  
  # Query with join
  result <- dbGetQuery(con, "
    SELECT d.menu, r.user_name, r.rating 
    FROM dinners d 
    JOIN ratings r ON d.id = r.dinner_id
  ")
  
  dbDisconnect(con)
  
  expect_equal(nrow(result), 1)
  expect_equal(result$menu, "Test Menu")
  expect_equal(result$user_name, "Test User")
  expect_equal(result$rating, 5)
  
  teardown_test_db()
})

# Test: Template File Exists
test_that("Quarto template file exists", {
  expect_true(file.exists("weekly_dinner_template.qmd"))
})

# Test: Required Columns in Template
test_that("Template contains required placeholders", {
  if (file.exists("weekly_dinner_template.qmd")) {
    template <- readLines("weekly_dinner_template.qmd")
    template_text <- paste(template, collapse = " ")
    
    expect_true(grepl("\\{\\{DATE\\}\\}", template_text))
    expect_true(grepl("\\{\\{MENU\\}\\}", template_text))
    expect_true(grepl("\\{\\{NOTES\\}\\}", template_text))
    expect_true(grepl("\\{\\{AVG_RATING\\}\\}", template_text))
  } else {
    skip("Template file not found")
  }
})

cat("\nAll tests completed!\n")
cat("To run these tests, use: testthat::test_file('tests/test_app.R')\n")

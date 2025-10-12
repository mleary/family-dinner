# Sample data initialization script for Family Dinner Tracker
# Run this to populate the database with example data

library(RSQLite)
library(lubridate)

# Initialize database
con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")

# Create tables (same structure as in app.R)
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

# Insert sample dinner
dbExecute(con, "
  INSERT INTO dinners (date, menu, notes) 
  VALUES (?, ?, ?)",
  params = list(
    as.character(Sys.Date() - 7),
    "Spaghetti with meat sauce, Caesar salad, Garlic bread",
    "Great family dinner! Everyone helped with cooking. Kids loved the garlic bread."
  )
)

# Get the dinner ID
dinner_id <- dbGetQuery(con, "SELECT last_insert_rowid() as id")$id

# Insert sample ratings
dbExecute(con, "
  INSERT INTO ratings (dinner_id, user_name, rating) 
  VALUES (?, ?, ?)",
  params = list(dinner_id, "Mom", 5)
)

dbExecute(con, "
  INSERT INTO ratings (dinner_id, user_name, rating) 
  VALUES (?, ?, ?)",
  params = list(dinner_id, "Dad", 4)
)

dbExecute(con, "
  INSERT INTO ratings (dinner_id, user_name, rating) 
  VALUES (?, ?, ?)",
  params = list(dinner_id, "Emma", 5)
)

# Insert sample comments
dbExecute(con, "
  INSERT INTO comments (dinner_id, user_name, comment) 
  VALUES (?, ?, ?)",
  params = list(
    dinner_id, 
    "Mom", 
    "The sauce turned out perfect! Will use this recipe again."
  )
)

dbExecute(con, "
  INSERT INTO comments (dinner_id, user_name, comment) 
  VALUES (?, ?, ?)",
  params = list(
    dinner_id, 
    "Emma", 
    "Can we make extra garlic bread next time? It was so good!"
  )
)

# Insert sample suggestions
dbExecute(con, "
  INSERT INTO suggestions (user_name, suggestion) 
  VALUES (?, ?)",
  params = list(
    "Dad",
    "How about trying homemade pizza night next week?"
  )
)

dbExecute(con, "
  INSERT INTO suggestions (user_name, suggestion) 
  VALUES (?, ?)",
  params = list(
    "Emma",
    "Taco Tuesday would be fun!"
  )
)

# Add this week's dinner
dbExecute(con, "
  INSERT INTO dinners (date, menu, notes) 
  VALUES (?, ?, ?)",
  params = list(
    as.character(Sys.Date()),
    "Roasted chicken, Mashed potatoes, Green beans, Apple pie",
    "Traditional Sunday dinner. Chicken was perfectly seasoned!"
  )
)

dbDisconnect(con)

cat("Sample data inserted successfully!\n")
cat("Run the Shiny app with: shiny::runApp('app.R')\n")

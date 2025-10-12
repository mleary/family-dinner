library(shiny)
library(DT)
library(dplyr)
library(lubridate)
library(RSQLite)
library(quarto)

# Initialize database connection
init_db <- function() {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  
  # Create tables if they don't exist
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

# Database helper functions
get_dinners <- function() {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dinners <- dbGetQuery(con, "SELECT * FROM dinners ORDER BY date DESC")
  dbDisconnect(con)
  dinners
}

get_latest_dinner <- function() {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dinner <- dbGetQuery(con, "SELECT * FROM dinners ORDER BY date DESC LIMIT 1")
  dbDisconnect(con)
  if (nrow(dinner) > 0) dinner else NULL
}

get_ratings <- function(dinner_id) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  ratings <- dbGetQuery(con, 
    "SELECT * FROM ratings WHERE dinner_id = ? ORDER BY created_at DESC",
    params = list(dinner_id))
  dbDisconnect(con)
  ratings
}

get_comments <- function(dinner_id) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  comments <- dbGetQuery(con, 
    "SELECT * FROM comments WHERE dinner_id = ? ORDER BY created_at DESC",
    params = list(dinner_id))
  dbDisconnect(con)
  comments
}

get_suggestions <- function() {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  suggestions <- dbGetQuery(con, "SELECT * FROM suggestions ORDER BY created_at DESC")
  dbDisconnect(con)
  suggestions
}

add_dinner <- function(date, menu, notes) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dbExecute(con, 
    "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
    params = list(date, menu, notes))
  dbDisconnect(con)
}

add_rating <- function(dinner_id, user_name, rating) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dbExecute(con, 
    "INSERT INTO ratings (dinner_id, user_name, rating) VALUES (?, ?, ?)",
    params = list(dinner_id, user_name, rating))
  dbDisconnect(con)
}

add_comment <- function(dinner_id, user_name, comment) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dbExecute(con, 
    "INSERT INTO comments (dinner_id, user_name, comment) VALUES (?, ?, ?)",
    params = list(dinner_id, user_name, comment))
  dbDisconnect(con)
}

add_suggestion <- function(user_name, suggestion) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dbExecute(con, 
    "INSERT INTO suggestions (user_name, suggestion) VALUES (?, ?)",
    params = list(user_name, suggestion))
  dbDisconnect(con)
}

# Initialize database on app start
init_db()

# UI
ui <- fluidPage(
  titlePanel("Family Dinner Weekly Tracker"),
  
  tabsetPanel(
    # Latest Week Tab
    tabPanel("Latest Week",
      fluidRow(
        column(8,
          h3("This Week's Dinner"),
          uiOutput("latest_dinner_ui"),
          hr(),
          h4("Ratings & Comments"),
          wellPanel(
            fluidRow(
              column(6,
                textInput("rate_user_name", "Your Name:"),
                sliderInput("rating_value", "Rate this dinner:", 
                           min = 1, max = 5, value = 5, step = 1),
                actionButton("submit_rating", "Submit Rating", class = "btn-primary")
              ),
              column(6,
                textInput("comment_user_name", "Your Name:"),
                textAreaInput("comment_text", "Comment:", rows = 3),
                actionButton("submit_comment", "Submit Comment", class = "btn-primary")
              )
            )
          ),
          h4("Recent Ratings"),
          DTOutput("ratings_table"),
          h4("Recent Comments"),
          DTOutput("comments_table")
        ),
        column(4,
          wellPanel(
            h4("Generate Weekly Report"),
            p("Create a Quarto document for this week's dinner."),
            actionButton("generate_quarto", "Generate Report", 
                        class = "btn-success btn-block"),
            hr(),
            textOutput("quarto_status")
          ),
          wellPanel(
            h4("Add New Dinner"),
            dateInput("new_dinner_date", "Date:", value = Sys.Date()),
            textAreaInput("new_dinner_menu", "Menu:", rows = 3),
            textAreaInput("new_dinner_notes", "Notes:", rows = 3),
            actionButton("add_new_dinner", "Add Dinner", 
                        class = "btn-info btn-block")
          )
        )
      )
    ),
    
    # History Tab
    tabPanel("Dinner History",
      fluidRow(
        column(12,
          h3("All Family Dinners"),
          DTOutput("dinners_table")
        )
      )
    ),
    
    # Suggestions Tab
    tabPanel("Suggestions",
      fluidRow(
        column(6,
          wellPanel(
            h4("Submit a Suggestion"),
            textInput("suggestion_user_name", "Your Name:"),
            textAreaInput("suggestion_text", "Your Suggestion:", rows = 4),
            actionButton("submit_suggestion", "Submit Suggestion", 
                        class = "btn-primary")
          )
        ),
        column(6,
          h4("All Suggestions"),
          DTOutput("suggestions_table")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive values
  trigger <- reactiveVal(0)
  
  # Latest dinner display
  output$latest_dinner_ui <- renderUI({
    trigger()
    dinner <- get_latest_dinner()
    
    if (is.null(dinner)) {
      return(div(
        class = "alert alert-info",
        "No dinners recorded yet. Add one using the form on the right!"
      ))
    }
    
    tagList(
      h4(paste("Date:", dinner$date)),
      h5("Menu:"),
      p(dinner$menu),
      h5("Notes:"),
      p(dinner$notes),
      tags$small(paste("Added:", dinner$created_at))
    )
  })
  
  # Ratings table
  output$ratings_table <- renderDT({
    trigger()
    dinner <- get_latest_dinner()
    if (!is.null(dinner)) {
      ratings <- get_ratings(dinner$id)
      if (nrow(ratings) > 0) {
        ratings %>% 
          select(user_name, rating, created_at) %>%
          rename("User" = user_name, "Rating" = rating, "Date" = created_at)
      } else {
        data.frame(Message = "No ratings yet")
      }
    } else {
      data.frame(Message = "No dinner to rate")
    }
  }, options = list(pageLength = 5, dom = 't'))
  
  # Comments table
  output$comments_table <- renderDT({
    trigger()
    dinner <- get_latest_dinner()
    if (!is.null(dinner)) {
      comments <- get_comments(dinner$id)
      if (nrow(comments) > 0) {
        comments %>% 
          select(user_name, comment, created_at) %>%
          rename("User" = user_name, "Comment" = comment, "Date" = created_at)
      } else {
        data.frame(Message = "No comments yet")
      }
    } else {
      data.frame(Message = "No dinner to comment on")
    }
  }, options = list(pageLength = 5, dom = 't'))
  
  # All dinners table
  output$dinners_table <- renderDT({
    trigger()
    dinners <- get_dinners()
    if (nrow(dinners) > 0) {
      dinners %>% 
        select(date, menu, notes, created_at) %>%
        rename("Date" = date, "Menu" = menu, "Notes" = notes, "Added" = created_at)
    } else {
      data.frame(Message = "No dinners recorded yet")
    }
  }, options = list(pageLength = 10))
  
  # Suggestions table
  output$suggestions_table <- renderDT({
    trigger()
    suggestions <- get_suggestions()
    if (nrow(suggestions) > 0) {
      suggestions %>% 
        select(user_name, suggestion, status, created_at) %>%
        rename("User" = user_name, "Suggestion" = suggestion, 
               "Status" = status, "Date" = created_at)
    } else {
      data.frame(Message = "No suggestions yet")
    }
  }, options = list(pageLength = 10))
  
  # Add new dinner
  observeEvent(input$add_new_dinner, {
    req(input$new_dinner_date, input$new_dinner_menu)
    
    add_dinner(
      as.character(input$new_dinner_date),
      input$new_dinner_menu,
      input$new_dinner_notes
    )
    
    # Clear inputs
    updateTextAreaInput(session, "new_dinner_menu", value = "")
    updateTextAreaInput(session, "new_dinner_notes", value = "")
    
    trigger(trigger() + 1)
    
    showNotification("Dinner added successfully!", type = "message")
  })
  
  # Submit rating
  observeEvent(input$submit_rating, {
    req(input$rate_user_name)
    dinner <- get_latest_dinner()
    
    if (!is.null(dinner)) {
      add_rating(dinner$id, input$rate_user_name, input$rating_value)
      updateTextInput(session, "rate_user_name", value = "")
      updateSliderInput(session, "rating_value", value = 5)
      trigger(trigger() + 1)
      showNotification("Rating submitted!", type = "message")
    } else {
      showNotification("No dinner to rate!", type = "error")
    }
  })
  
  # Submit comment
  observeEvent(input$submit_comment, {
    req(input$comment_user_name, input$comment_text)
    dinner <- get_latest_dinner()
    
    if (!is.null(dinner)) {
      add_comment(dinner$id, input$comment_user_name, input$comment_text)
      updateTextInput(session, "comment_user_name", value = "")
      updateTextAreaInput(session, "comment_text", value = "")
      trigger(trigger() + 1)
      showNotification("Comment submitted!", type = "message")
    } else {
      showNotification("No dinner to comment on!", type = "error")
    }
  })
  
  # Submit suggestion
  observeEvent(input$submit_suggestion, {
    req(input$suggestion_user_name, input$suggestion_text)
    
    add_suggestion(input$suggestion_user_name, input$suggestion_text)
    updateTextInput(session, "suggestion_user_name", value = "")
    updateTextAreaInput(session, "suggestion_text", value = "")
    trigger(trigger() + 1)
    showNotification("Suggestion submitted!", type = "message")
  })
  
  # Generate Quarto report
  output$quarto_status <- renderText({
    ""
  })
  
  observeEvent(input$generate_quarto, {
    dinner <- get_latest_dinner()
    
    if (is.null(dinner)) {
      showNotification("No dinner to generate report for!", type = "error")
      return()
    }
    
    tryCatch({
      # Get ratings and comments
      ratings <- get_ratings(dinner$id)
      comments <- get_comments(dinner$id)
      
      # Calculate average rating
      avg_rating <- if(nrow(ratings) > 0) mean(ratings$rating) else NA
      
      # Create filename with date
      filename <- paste0("weekly_dinner_", 
                        gsub("-", "_", dinner$date), ".qmd")
      
      # Render from template
      template_content <- readLines("weekly_dinner_template.qmd")
      
      # Replace placeholders
      template_content <- gsub("\\{\\{DATE\\}\\}", dinner$date, template_content)
      template_content <- gsub("\\{\\{MENU\\}\\}", dinner$menu, template_content)
      template_content <- gsub("\\{\\{NOTES\\}\\}", 
                              ifelse(is.na(dinner$notes) || dinner$notes == "", 
                                     "No notes", dinner$notes), 
                              template_content)
      template_content <- gsub("\\{\\{AVG_RATING\\}\\}", 
                              ifelse(is.na(avg_rating), "No ratings yet", 
                                     sprintf("%.1f", avg_rating)), 
                              template_content)
      template_content <- gsub("\\{\\{NUM_RATINGS\\}\\}", 
                              nrow(ratings), template_content)
      template_content <- gsub("\\{\\{NUM_COMMENTS\\}\\}", 
                              nrow(comments), template_content)
      
      # Write the file
      writeLines(template_content, filename)
      
      output$quarto_status <- renderText({
        paste("Generated:", filename)
      })
      
      showNotification(paste("Quarto report generated:", filename), 
                      type = "message", duration = 5)
      
    }, error = function(e) {
      showNotification(paste("Error generating report:", e$message), 
                      type = "error")
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)

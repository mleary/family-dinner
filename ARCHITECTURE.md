# Architecture and Technical Details

## Application Overview

The Family Dinner Tracker is a full-stack R Shiny application that combines:
- **Frontend**: Interactive Shiny UI with Bootstrap styling
- **Backend**: R server logic with SQLite database
- **Reports**: Quarto-based document generation

## Technology Stack

### Core Technologies
- **R Shiny**: Web application framework
- **SQLite**: Lightweight database for data persistence
- **Quarto**: Document generation and rendering
- **DT (DataTables)**: Interactive table display
- **dplyr**: Data manipulation
- **lubridate**: Date/time handling

## Database Schema

### Tables

#### 1. dinners
Stores main dinner records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-incrementing dinner ID |
| date | TEXT | Date of the dinner (YYYY-MM-DD) |
| menu | TEXT | Menu items and dishes |
| notes | TEXT | Additional notes and highlights |
| created_at | TEXT | Timestamp when record was created |

#### 2. ratings
Stores user ratings for dinners.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-incrementing rating ID |
| dinner_id | INTEGER | Foreign key to dinners.id |
| user_name | TEXT | Name of the person rating |
| rating | INTEGER | Rating value (1-5) |
| created_at | TEXT | Timestamp when rating was submitted |

#### 3. comments
Stores user comments about dinners.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-incrementing comment ID |
| dinner_id | INTEGER | Foreign key to dinners.id |
| user_name | TEXT | Name of the commenter |
| comment | TEXT | Comment text |
| created_at | TEXT | Timestamp when comment was submitted |

#### 4. suggestions
Stores future dinner suggestions.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER PRIMARY KEY | Auto-incrementing suggestion ID |
| user_name | TEXT | Name of the person suggesting |
| suggestion | TEXT | Suggestion text |
| status | TEXT | Status (pending, accepted, completed) |
| created_at | TEXT | Timestamp when suggestion was submitted |

## Application Flow

### 1. Initialization
```
App Start → init_db() → Create/Verify Tables → Load UI
```

### 2. Adding a Dinner
```
User Input → Validation → add_dinner() → Insert to DB → Refresh UI
```

### 3. Rating/Commenting
```
User Input → Get Latest Dinner → add_rating()/add_comment() → 
Insert to DB → Refresh UI
```

### 4. Generating Reports
```
Click Generate → Get Dinner Data → Get Ratings/Comments → 
Calculate Stats → Read Template → Replace Placeholders → 
Write .qmd File → Notify User
```

## Component Structure

### UI Components

#### Tab 1: Latest Week
- **Dinner Display**: Shows most recent dinner
- **Rating Panel**: 1-5 star rating input
- **Comment Panel**: Text area for comments
- **Tables**: Display ratings and comments
- **Generate Report Button**: Creates Quarto document
- **Add Dinner Panel**: Form for new dinner entry

#### Tab 2: Dinner History
- **DataTable**: Sortable, searchable table of all dinners

#### Tab 3: Suggestions
- **Suggestion Form**: Input for new suggestions
- **Suggestions Table**: Display all suggestions with status

### Server Logic

#### Reactive Values
- `trigger`: Counter to force reactive updates

#### Database Functions
- `get_dinners()`: Fetch all dinners
- `get_latest_dinner()`: Fetch most recent dinner
- `get_ratings(dinner_id)`: Fetch ratings for a dinner
- `get_comments(dinner_id)`: Fetch comments for a dinner
- `get_suggestions()`: Fetch all suggestions
- `add_dinner()`: Insert new dinner
- `add_rating()`: Insert new rating
- `add_comment()`: Insert new comment
- `add_suggestion()`: Insert new suggestion

#### Event Observers
- Add Dinner button
- Submit Rating button
- Submit Comment button
- Submit Suggestion button
- Generate Report button

## Quarto Template System

### Template Variables
The template uses placeholder syntax `{{VARIABLE}}` which are replaced during generation:

- `{{DATE}}`: Dinner date
- `{{MENU}}`: Menu items
- `{{NOTES}}`: Additional notes
- `{{AVG_RATING}}`: Calculated average rating
- `{{NUM_RATINGS}}`: Count of ratings
- `{{NUM_COMMENTS}}`: Count of comments

### Generation Process
1. Retrieve dinner data from database
2. Query related ratings and comments
3. Calculate statistics (average rating)
4. Read template file
5. Replace all placeholders with actual values
6. Write new .qmd file with date-based filename
7. Notify user of successful generation

## File Organization

```
family-dinner/
├── app.R                      # Main application (UI + Server)
├── weekly_dinner_template.qmd # Quarto template with placeholders
├── init_sample_data.R         # Database initialization with examples
├── run.R                      # Convenience startup script
├── DESCRIPTION               # Package dependencies
├── _quarto.yml               # Quarto project configuration
├── index.qmd                 # Project homepage
├── QUICKSTART.qmd            # Quick start guide
├── styles.css                # Custom CSS for reports
├── example_report.qmd        # Example generated report
├── README.md                 # Main documentation
└── dinner_data.db           # SQLite database (auto-created)
```

## Data Flow Diagram

```
┌─────────────┐
│   User      │
│  Browser    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│      Shiny UI (app.R)          │
│  - Input Forms                  │
│  - Display Tables               │
│  - Action Buttons               │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   Server Logic (app.R)         │
│  - Event Handlers               │
│  - Data Processing              │
│  - Report Generation            │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   SQLite Database              │
│  - dinners                      │
│  - ratings                      │
│  - comments                     │
│  - suggestions                  │
└─────────────────────────────────┘
```

## Security Considerations

### Current Implementation
- **Local Database**: Data stored locally in SQLite
- **No Authentication**: Single-user or trusted family environment
- **No Encryption**: Database is not encrypted

### For Production Use
If deploying this app publicly, consider:
1. Add user authentication (shiny.auth, firebase, etc.)
2. Implement input validation and sanitization
3. Add rate limiting for submissions
4. Use encrypted database or secure cloud storage
5. Implement HTTPS for web deployment
6. Add session management
7. Implement CSRF protection

## Performance Considerations

### Database
- SQLite is sufficient for family use (< 10,000 records)
- Indexes automatically created on PRIMARY KEY columns
- For larger deployments, consider PostgreSQL or MySQL

### Reactive Updates
- `trigger` reactiveVal used to manually control updates
- Minimizes unnecessary database queries
- Updates only when data changes

### Table Rendering
- DT package provides client-side pagination
- Reduces load for large datasets
- Built-in search and sorting

## Extending the Application

### Adding Features

#### Photo Uploads
Add a photos table and file upload input:
```r
fileInput("dinner_photo", "Upload Photo")
```

#### Recipe Integration
Add a recipes table and link to dinners:
```r
dbExecute(con, "CREATE TABLE recipes (...)")
```

#### Meal Planning
Add a future_dinners table:
```r
dateRangeInput("meal_plan", "Plan Week")
```

#### Email Notifications
Integrate with mailR or blastula:
```r
send_email(to = family_members, subject = "New Dinner Posted!")
```

### Customization

#### Changing Rating Scale
Modify the slider input range:
```r
sliderInput("rating_value", min = 1, max = 10, ...)
```

#### Adding Categories
Add category column to dinners table:
```r
ALTER TABLE dinners ADD COLUMN category TEXT
```

#### Custom Report Themes
Edit `_quarto.yml` to change theme:
```yaml
theme: flatly  # or darkly, journal, etc.
```

## Troubleshooting

### Common Issues

**Database locked error**
- Close any other connections to the database
- Check if another R session is running

**Quarto not found**
- Install Quarto CLI: https://quarto.org/docs/get-started/
- Or use `install.packages("quarto")`

**Packages not loading**
- Run `install.packages()` for missing packages
- Check R version compatibility

**Port already in use**
- Change port: `runApp("app.R", port = 8080)`
- Or stop other Shiny apps

## Future Enhancements

- [ ] Mobile-responsive design improvements
- [ ] Export data to CSV/Excel
- [ ] Calendar view of dinners
- [ ] Recipe database integration
- [ ] Shopping list generator
- [ ] Dietary restrictions tracking
- [ ] Cost tracking per dinner
- [ ] Photo gallery
- [ ] Social sharing features
- [ ] Integration with meal planning services

# family-dinner

A R Shiny application for tracking weekly family dinners with interactive features for ratings, comments, and suggestions. Includes Quarto template integration for generating beautiful weekly reports.

## Features

- 📅 **Weekly Dinner Tracking**: Record date, menu, and notes for each family dinner
- ⭐ **Interactive Ratings**: Family members can rate dinners on a 1-5 star scale
- 💬 **Comments System**: Share feedback and thoughts about each meal
- 💡 **Suggestions**: Submit ideas for future dinners
- 📊 **Dinner History**: View all past dinners in a searchable table
- 📄 **Quarto Reports**: Generate professional weekly reports from a template

## Installation

### Prerequisites

- R (>= 4.0.0)
- RStudio (recommended)
- Quarto CLI (optional, for advanced report rendering)

### Required R Packages

Install the required packages:

```r
install.packages(c(
  "shiny",
  "DT",
  "dplyr",
  "lubridate",
  "RSQLite",
  "quarto"
))
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/mleary/family-dinner.git
cd family-dinner
```

### 2. Initialize Sample Data (Optional)

To get started with example data:

```r
source("init_sample_data.R")
```

This will create a SQLite database with sample dinners, ratings, and comments.

### 3. Run the Shiny Application

```r
shiny::runApp("app.R")
```

Or in RStudio, open `app.R` and click the "Run App" button.

## Usage

### Adding a Dinner

1. Navigate to the **Latest Week** tab
2. Use the **Add New Dinner** panel on the right
3. Select the date, enter menu items, and add notes
4. Click "Add Dinner"

### Rating and Commenting

1. View the latest dinner in the **Latest Week** tab
2. Enter your name and select a rating (1-5 stars)
3. Or add a comment about the meal
4. Submit your feedback

### Making Suggestions

1. Go to the **Suggestions** tab
2. Enter your name and suggestion
3. Submit to share your idea with the family

### Generating Weekly Reports

1. Click the **Generate Report** button in the Latest Week tab
2. A Quarto document will be created with:
   - Menu details
   - Average ratings
   - Number of comments
   - Summary information
3. The filename includes the date: `weekly_dinner_YYYY_MM_DD.qmd`

### Viewing History

1. Navigate to the **Dinner History** tab
2. Browse all past dinners
3. Use the search feature to find specific meals

## Project Structure

```
family-dinner/
├── app.R                      # Main Shiny application
├── weekly_dinner_template.qmd # Quarto template for weekly reports
├── init_sample_data.R         # Sample data initialization script
├── index.qmd                  # Project homepage (Quarto)
├── _quarto.yml               # Quarto project configuration
├── DESCRIPTION               # R package dependencies
├── README.md                 # This file
├── LICENSE                   # MIT License
└── .gitignore               # Git ignore rules
```

## Data Storage

The application uses SQLite for data persistence. All data is stored in `dinner_data.db` (automatically created on first run).

### Database Schema

- **dinners**: Main dinner records (date, menu, notes)
- **ratings**: User ratings for each dinner (1-5 stars)
- **comments**: User comments and feedback
- **suggestions**: Future dinner ideas and suggestions

## Customization

### Modifying the Quarto Template

Edit `weekly_dinner_template.qmd` to customize the report format. The template uses placeholders:

- `{{DATE}}`: Dinner date
- `{{MENU}}`: Menu items
- `{{NOTES}}`: Additional notes
- `{{AVG_RATING}}`: Average rating
- `{{NUM_RATINGS}}`: Number of ratings
- `{{NUM_COMMENTS}}`: Number of comments

### Styling

The Shiny app uses Bootstrap styling. Customize by modifying the UI elements in `app.R`.

For Quarto reports, edit the `format` section in `_quarto.yml` or individual `.qmd` files.

## Contributing

This is a personal family project, but feel free to fork and adapt it for your own use!

## License

MIT License - see LICENSE file for details.

## Support

For issues or questions, please open an issue on GitHub.

---

**Enjoy your family dinners! 🍽️**

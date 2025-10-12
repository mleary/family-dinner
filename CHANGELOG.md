# Changelog

All notable changes to the Family Dinner Tracker project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-12

### Added
- Initial release of Family Dinner Tracker
- R Shiny application with three main tabs:
  - Latest Week: View current dinner, rate, and comment
  - Dinner History: Browse all past dinners
  - Suggestions: Submit and view future dinner ideas
- SQLite database for data persistence
  - Dinners table for meal records
  - Ratings table for 1-5 star ratings
  - Comments table for user feedback
  - Suggestions table for future meal ideas
- Interactive features:
  - Add new dinners with date, menu, and notes
  - Submit ratings (1-5 stars)
  - Leave comments on dinners
  - Make suggestions for future dinners
- Quarto template integration
  - Generate weekly reports from template
  - Automatic placeholder replacement
  - Date-based file naming
- Data visualization:
  - Interactive DataTables for browsing data
  - Real-time updates after submissions
  - Searchable and sortable tables
- Sample data initialization script
- Comprehensive documentation:
  - README with setup instructions
  - QUICKSTART guide for new users
  - ARCHITECTURE documentation
  - DEPLOYMENT guide with multiple options
  - WORKFLOW documentation with diagrams
  - UI_GUIDE with visual descriptions
- Test suite with testthat
- Bootstrap-styled UI with responsive design
- Notification system for user feedback
- Database helper functions for all operations

### Project Structure
- `app.R`: Main Shiny application
- `weekly_dinner_template.qmd`: Quarto template for reports
- `init_sample_data.R`: Sample data initialization
- `run.R`: Convenience startup script
- `DESCRIPTION`: R package dependencies
- `_quarto.yml`: Quarto project configuration
- `index.qmd`: Project homepage
- `styles.css`: Custom CSS for reports
- `example_report.qmd`: Example generated report
- `tests/test_app.R`: Test suite
- Comprehensive documentation files

### Technical Details
- R Shiny for web application framework
- SQLite for lightweight database
- DT package for interactive tables
- dplyr for data manipulation
- lubridate for date handling
- quarto package for report generation
- Bootstrap CSS framework
- Reactive programming patterns

### Features for Future Releases
- Photo upload for dinners
- Recipe database integration
- Email notifications
- User authentication
- Advanced analytics and charts
- Mobile app version
- Calendar view
- Meal planning features
- Shopping list generator
- Cost tracking
- Dietary restrictions tracking

## [Unreleased]

### Planned Features
- User authentication system
- Photo gallery for dinners
- Recipe management
- Export to CSV/Excel
- Import from external sources
- Advanced statistics dashboard
- Email reminders
- Integration with meal planning services
- Multi-language support
- Dark mode theme

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 0.1.0 | 2025-10-12 | Initial release with core features |

## Contributing

We welcome contributions! Please see CONTRIBUTING.md for guidelines (to be created).

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

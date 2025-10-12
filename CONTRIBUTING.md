# Contributing to Family Dinner Tracker

Thank you for your interest in contributing to the Family Dinner Tracker! This document provides guidelines for contributing to the project.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This is a family-friendly project. We expect all contributors to:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/family-dinner.git
   cd family-dinner
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- Clear title and description
- Steps to reproduce the bug
- Expected vs actual behavior
- Your environment (R version, OS, browser)
- Screenshots if applicable

### Suggesting Features

We welcome feature suggestions! Please create an issue with:
- Clear description of the feature
- Use case and benefits
- Potential implementation approach (optional)

### Improving Documentation

Documentation improvements are always welcome:
- Fix typos or unclear explanations
- Add examples or tutorials
- Translate documentation
- Add screenshots or diagrams

## Development Setup

### Prerequisites
- R (>= 4.0.0)
- RStudio (recommended)
- Git

### Installation

1. Install required R packages:
   ```r
   install.packages(c("shiny", "DT", "dplyr", "lubridate", "RSQLite", "quarto", "testthat"))
   ```

2. Initialize the database with sample data:
   ```r
   source("init_sample_data.R")
   ```

3. Run the application:
   ```r
   shiny::runApp("app.R")
   ```

## Coding Standards

### R Code Style

We follow the [Tidyverse Style Guide](https://style.tidyverse.org/):

- Use `<-` for assignment, not `=`
- Use snake_case for function and variable names
- Indent with 2 spaces, not tabs
- Maximum line length of 80 characters (flexible)
- Use meaningful variable names

**Good:**
```r
calculate_average_rating <- function(dinner_id) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  result <- dbGetQuery(con, 
    "SELECT AVG(rating) as avg FROM ratings WHERE dinner_id = ?",
    params = list(dinner_id))
  dbDisconnect(con)
  return(result$avg)
}
```

**Not so good:**
```r
calc<-function(x){
con=dbConnect(RSQLite::SQLite(),"dinner_data.db")
r=dbGetQuery(con,"SELECT AVG(rating) as avg FROM ratings WHERE dinner_id = ?",params=list(x))
dbDisconnect(con)
return(r$avg)}
```

### Database Best Practices

- Always close database connections
- Use parameterized queries to prevent SQL injection
- Handle errors gracefully with `tryCatch()`
- Keep transactions short

**Good:**
```r
add_dinner <- function(date, menu, notes) {
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  tryCatch({
    dbExecute(con, 
      "INSERT INTO dinners (date, menu, notes) VALUES (?, ?, ?)",
      params = list(date, menu, notes))
  }, error = function(e) {
    stop("Failed to add dinner: ", e$message)
  }, finally = {
    dbDisconnect(con)
  })
}
```

### Shiny Best Practices

- Use reactive values appropriately
- Validate inputs with `req()`
- Provide user feedback with notifications
- Keep UI and server logic separate
- Use meaningful IDs for inputs and outputs

### Documentation

- Add comments for complex logic
- Document function parameters and return values
- Update README when adding features
- Include examples in documentation

## Testing

### Running Tests

Run the test suite:
```r
testthat::test_file("tests/test_app.R")
```

### Writing Tests

When adding new features, please include tests:

```r
test_that("New feature works correctly", {
  # Setup
  setup_test_db()
  
  # Test
  result <- your_new_function()
  
  # Assert
  expect_equal(result, expected_value)
  
  # Cleanup
  teardown_test_db()
})
```

### Test Coverage

Aim to test:
- Database operations
- Data validation
- Edge cases
- Error handling

## Submitting Changes

### Pull Request Process

1. **Update your branch** with the latest main:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Test your changes** thoroughly:
   - Run the application
   - Test all affected features
   - Run the test suite
   - Check for console errors

3. **Commit your changes** with clear messages:
   ```bash
   git add .
   git commit -m "Add feature: brief description"
   ```
   
   Follow conventional commit format:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation
   - `test:` for tests
   - `refactor:` for code refactoring
   - `style:` for formatting changes

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub:
   - Clear title and description
   - Reference any related issues
   - Explain what changed and why
   - Include screenshots for UI changes
   - List any breaking changes

### Pull Request Checklist

Before submitting, ensure:
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No merge conflicts
- [ ] Feature works as expected
- [ ] No console errors or warnings

## Areas for Contribution

We especially welcome contributions in these areas:

### High Priority
- User authentication system
- Photo upload functionality
- Advanced analytics/charts
- Mobile responsiveness improvements
- Performance optimizations

### Medium Priority
- Export/import features
- Recipe database integration
- Email notifications
- Calendar view
- Meal planning features

### Documentation
- Video tutorials
- Translation to other languages
- More example use cases
- Deployment guides for specific platforms

### Testing
- Additional test cases
- Integration tests
- UI/UX testing
- Performance testing

## Questions?

If you have questions about contributing:
- Open an issue with the "question" label
- Check existing issues and documentation
- Reach out to the maintainers

## Recognition

Contributors will be recognized in:
- README.md contributor list
- Release notes
- Special thanks in documentation

Thank you for contributing to Family Dinner Tracker! 🍽️

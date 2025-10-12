# Frequently Asked Questions (FAQ)

## General Questions

### What is Family Dinner Tracker?

Family Dinner Tracker is a R Shiny web application designed to help families track their weekly dinners, collect feedback through ratings and comments, and generate beautiful reports using Quarto templates. It's perfect for families who want to keep a record of their meals, share what worked well, and plan future dinners together.

### Who is this application for?

This application is ideal for:
- Families who have regular dinner gatherings
- Home cooks who want to track their recipes and gather feedback
- Anyone interested in documenting their meal history
- Families looking to engage everyone in meal planning

### Is this free to use?

Yes! The application is open source under the MIT license. You can use, modify, and distribute it freely. There are no subscription fees or hidden costs. You only need to set up the R environment and optionally pay for hosting if you choose a paid deployment option.

## Installation & Setup

### What software do I need to run this?

You need:
- R (version 4.0.0 or higher)
- Several R packages: shiny, DT, dplyr, lubridate, RSQLite, quarto
- Optionally: RStudio (makes development easier)
- Optionally: Quarto CLI (for advanced report features)

### How do I install R and the required packages?

1. Download and install R from https://cran.r-project.org/
2. Download and install RStudio from https://posit.co/downloads/
3. Open R or RStudio and run:
   ```r
   install.packages(c("shiny", "DT", "dplyr", "lubridate", "RSQLite", "quarto"))
   ```

### The installation is taking a long time. Is this normal?

Yes, installing R packages can take several minutes, especially the first time. Some packages need to be compiled, which requires additional time. Be patient and let the installation complete.

### I'm getting an error during package installation. What should I do?

Common solutions:
- Make sure you have an internet connection
- Try running R/RStudio as administrator
- On Linux, you may need to install system dependencies first
- Check the error message for specific package names and search for solutions
- Try installing packages one at a time to identify the problematic one

## Using the Application

### How do I start the application?

There are two ways:
1. **Using RStudio**: Open `app.R` and click the "Run App" button
2. **Using R console**: Navigate to the app directory and run `shiny::runApp("app.R")`

Or use the convenience script: `source("run.R")`

### Can I access the app from my phone or tablet?

Yes! If you're running it on your local network:
1. Find your computer's IP address
2. Run the app with: `shiny::runApp("app.R", host = "0.0.0.0", port = 3838)`
3. Access it from your mobile device at: `http://YOUR_IP:3838`

The interface is responsive and should work on mobile devices.

### How do I add a new dinner?

1. Go to the "Latest Week" tab
2. Find the "Add New Dinner" panel on the right side
3. Select the date
4. Enter the menu items
5. Add any notes (optional)
6. Click "Add Dinner"

### How do family members rate dinners?

1. Go to the "Latest Week" tab
2. In the "Ratings & Comments" section
3. Enter their name
4. Move the slider to select a rating (1-5 stars)
5. Click "Submit Rating"

### What happens to the data when I close the app?

All data is saved in a SQLite database file (`dinner_data.db`). When you restart the app, all your dinners, ratings, comments, and suggestions will still be there. The data persists between sessions.

### Can I delete or edit a dinner after adding it?

Currently, the application doesn't have built-in delete or edit functionality to keep it simple. If you need to modify data:
- For simple changes, you can use SQLite tools to edit the database directly
- Or consider adding a new entry and ignoring the old one
- Future versions may include edit/delete features

### How do I generate a weekly report?

1. Make sure you have at least one dinner added
2. Go to the "Latest Week" tab
3. Click the "Generate Report" button
4. A Quarto file (`.qmd`) will be created with the dinner details

The file will be named `weekly_dinner_YYYY_MM_DD.qmd` and saved in your app directory.

### Can I customize the report template?

Yes! Edit the `weekly_dinner_template.qmd` file to change:
- Layout and formatting
- Colors and themes
- What information is included
- How data is presented

The template uses placeholders like `{{DATE}}` and `{{MENU}}` which are automatically replaced with actual data.

## Data & Privacy

### Where is my data stored?

Your data is stored locally in a SQLite database file called `dinner_data.db` in the same directory as the application. It never leaves your computer unless you choose to deploy the app to a remote server.

### Is my data private?

If you're running the app locally, yes - your data stays on your computer. If you deploy it to a server or cloud service, the data will be on that server. Choose your deployment method based on your privacy needs.

### Can I backup my data?

Yes! Simply make a copy of the `dinner_data.db` file. You can:
- Copy it to another location manually
- Set up automatic backups using system tools
- Use cloud storage services to sync the file

To restore from backup, replace the database file with your backup copy.

### Can I export my data?

Currently, there's no built-in export feature, but you can:
- Use SQLite tools to export to CSV: `sqlite3 dinner_data.db ".mode csv" ".output dinners.csv" "SELECT * FROM dinners;"`
- Use R to read the database and export: 
  ```r
  con <- dbConnect(RSQLite::SQLite(), "dinner_data.db")
  dinners <- dbGetQuery(con, "SELECT * FROM dinners")
  write.csv(dinners, "dinners.csv")
  dbDisconnect(con)
  ```

### How much data can the application handle?

SQLite can easily handle:
- Thousands of dinner entries
- Tens of thousands of ratings and comments
- Years of family dinner history

For typical family use (1 dinner per week), you could use this for decades without performance issues.

## Troubleshooting

### The app won't start. What should I check?

1. Make sure R and all packages are installed
2. Check you're in the correct directory
3. Look for error messages in the R console
4. Try running `source("app.R")` to see detailed errors
5. Check file permissions on the app directory

### I'm seeing "database locked" errors. How do I fix this?

This happens when:
- Another R session is using the database
- The app crashed without closing the connection
- Multiple users are accessing the same database file

Solutions:
- Close all R sessions and restart
- Delete the `.db-journal` file if it exists
- Make sure only one instance of the app is running

### The "Generate Report" button doesn't work. Why?

Check:
- Is there a dinner in the database?
- Does `weekly_dinner_template.qmd` exist?
- Are there any error messages in the R console?
- Do you have write permissions in the app directory?

### Tables are not showing data. What's wrong?

Possible causes:
- Database is empty (add some data first)
- Database connection error (check R console for errors)
- JavaScript not loading (try refreshing the browser)
- Browser compatibility issue (try Chrome or Firefox)

### The app is running but I can't access it in my browser.

Check:
- What URL is shown in the R console?
- Is your firewall blocking the connection?
- Try accessing `http://localhost:####` or `http://127.0.0.1:####`
- Make sure the port isn't being used by another application

## Customization

### Can I change the color scheme?

Yes! The app uses Bootstrap CSS. You can:
- Add custom CSS by creating a `www/custom.css` file
- Modify the UI code in `app.R` to use different Bootstrap classes
- For Quarto reports, edit the theme in `_quarto.yml` or template files

### Can I add more fields to dinner entries?

Yes, but it requires modifying the code:
1. Add a column to the `dinners` table in the database
2. Add input widget to the UI
3. Update the `add_dinner()` function to include the new field
4. Update display code to show the new field
5. Update the Quarto template if you want it in reports

### Can I change the rating scale from 1-5 to something else?

Yes, modify the slider input in `app.R`:
```r
sliderInput("rating_value", "Rate this dinner:", 
           min = 1, max = 10, value = 10, step = 1)
```

Also update the database constraint in the `init_db()` function.

### Can I add photos to dinners?

This feature isn't currently included, but could be added with:
- File upload input: `fileInput()`
- Image storage (local files or database BLOB)
- Display code to show images
- Update templates to include photos

See ARCHITECTURE.md for extension guidance.

## Deployment

### Can others use my app without installing R?

Yes, by deploying to:
- **shinyapps.io**: Cloud hosting (free tier available)
- **Shiny Server**: Self-hosted server
- **Your local network**: Run on one computer, access from others

See DEPLOYMENT.md for detailed instructions.

### What's the easiest way to share with remote family members?

Use shinyapps.io free tier:
- 25 active hours per month (plenty for family use)
- No server management needed
- HTTPS included
- Shareable URL

See DEPLOYMENT.md for step-by-step instructions.

### Is it secure to deploy publicly?

The basic app has no authentication. For public deployment:
- Add user authentication (see DEPLOYMENT.md security section)
- Use HTTPS
- Consider rate limiting
- Regular backups
- Keep R and packages updated

For private family use on local network, basic setup is usually sufficient.

## Features & Development

### Will there be new features added?

This is an open-source project. New features can be added by:
- Contributing code yourself (see CONTRIBUTING.md)
- Requesting features via GitHub issues
- Hiring a developer to customize it
- Forking and building your own version

### Can I request a feature?

Yes! Please:
1. Check if it's already requested in GitHub issues
2. Open a new issue with the "enhancement" label
3. Describe the feature and its benefits
4. Be patient - this is a community project

### How can I contribute?

See CONTRIBUTING.md for:
- How to submit code contributions
- Coding standards
- Testing requirements
- Documentation improvements

### Can I use this for commercial purposes?

Yes! The MIT license allows commercial use. You can:
- Use it in a business
- Charge for hosting services
- Create derivative works
- Sell customized versions

Just maintain the original license and attribution.

## Support

### Where can I get help?

- Read the documentation (README, guides, this FAQ)
- Search GitHub issues for similar problems
- Open a new issue on GitHub
- Check R Shiny documentation
- Ask in R community forums

### How do I report a bug?

1. Go to the GitHub repository
2. Click "Issues"
3. Click "New Issue"
4. Describe the bug with:
   - What you were trying to do
   - What happened
   - What you expected to happen
   - Your environment (R version, OS)
   - Steps to reproduce

### Is there a user community?

Currently, community interaction happens through:
- GitHub Issues (questions, bugs, features)
- GitHub Discussions (general conversation)
- Pull Requests (code contributions)

### Can I hire someone to customize this for me?

Yes! This is open-source software. You can:
- Hire an R/Shiny developer
- Post on freelance platforms
- Contact R consultants
- Reach out to the maintainer (see GitHub profile)

## Comparison with Other Tools

### How is this different from a spreadsheet?

Benefits of this app:
- ✅ Better user interface
- ✅ Multiple users can interact easily
- ✅ Automatic report generation
- ✅ No spreadsheet knowledge needed
- ✅ Interactive tables and search

Spreadsheets might be better for:
- Quick one-time tracking
- Complex calculations
- Existing Excel expertise

### Could I use a generic note-taking app instead?

You could, but this app offers:
- Structured data entry
- Rating system
- Searchable history
- Automated reports
- Family collaboration features
- Data persistence and backup

### Why not use a commercial meal planning app?

Benefits of Family Dinner Tracker:
- Free and open source
- Full data ownership
- No subscription fees
- Customizable to your needs
- Privacy (data stays local)
- No ads or upsells

Commercial apps might offer:
- More polish
- Mobile apps
- Recipe databases
- Grocery integration
- Professional support

Choose based on your priorities!

---

**Have a question not answered here?** Open an issue on GitHub!

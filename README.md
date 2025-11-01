# Family Dinner Menu App 🍽️

A Streamlit web application to display and manage weekly family dinner menus.

## Features

- **Next Menu**: Displays the upcoming family dinner menu in a beautiful card format
- **Previous Menus**: Browse through past family dinner menus
- **CSV-based Storage**: Easy to update menus by editing the CSV file
- **Responsive Design**: Clean and modern UI with custom styling

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

## Running the App

To start the Streamlit app:
```bash
streamlit run app.py
```

The app will open in your default browser at `http://localhost:8501`

## Managing Menus

Menus are stored in `menus.csv`. The CSV file has the following structure:

```csv
date,main_dish,side_dish,dessert,notes
2025-11-08,Roasted Chicken,Mashed Potatoes & Green Beans,Apple Pie,Classic comfort food
```

### Adding a New Menu

1. Open `menus.csv`
2. Add a new row with the following columns:
   - `date`: Date of the dinner (YYYY-MM-DD format)
   - `main_dish`: Main course
   - `side_dish`: Side dishes
   - `dessert`: Dessert
   - `notes`: Any additional notes (optional)

3. Save the file and refresh the app

## Project Structure

```
family-dinner/
├── app.py              # Main Streamlit application
├── menus.csv           # Menu data storage
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

## Technologies Used

- **Streamlit**: Web application framework
- **Pandas**: Data manipulation and CSV handling
- **Python 3.x**: Programming language

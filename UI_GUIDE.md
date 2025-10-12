# Application Screenshots and UI Guide

## Application Overview

The Family Dinner Tracker is a three-tab Shiny application with a clean, Bootstrap-styled interface.

## Main Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                  Family Dinner Weekly Tracker                    │
├─────────────────────────────────────────────────────────────────┤
│ [Latest Week] [Dinner History] [Suggestions]                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Content Area (Changes based on selected tab)                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Tab 1: Latest Week

### Layout Description

```
┌─────────────────────────────────────────────────────────────────┐
│                         Latest Week Tab                          │
├─────────────────────────────────────┬───────────────────────────┤
│  Left Column (8/12 width)           │ Right Column (4/12 width) │
│                                      │                           │
│  ┌────────────────────────────────┐ │ ┌───────────────────────┐ │
│  │ This Week's Dinner              │ │ │ Generate Weekly Report│ │
│  │                                 │ │ │                       │ │
│  │ Date: 2025-10-12                │ │ │ Create a Quarto doc   │ │
│  │                                 │ │ │ for this week's dinner│ │
│  │ Menu:                           │ │ │                       │ │
│  │ Roasted chicken, Mashed         │ │ │ [Generate Report]     │ │
│  │ potatoes, Green beans, Apple pie│ │ │                       │ │
│  │                                 │ │ │ Status: (empty)       │ │
│  │ Notes:                          │ │ └───────────────────────┘ │
│  │ Traditional Sunday dinner.       │ │                           │
│  │ Chicken was perfectly seasoned! │ │ ┌───────────────────────┐ │
│  │                                 │ │ │ Add New Dinner        │ │
│  │ Added: 2025-10-12 14:30:00     │ │ │                       │ │
│  └────────────────────────────────┘ │ │ Date: [2025-10-12  ▼] │ │
│                                      │ │                       │ │
│  ═══════════════════════════════════ │ │ Menu:                 │ │
│                                      │ │ ┌───────────────────┐ │ │
│  Ratings & Comments                  │ │ │                   │ │ │
│  ┌────────────────────────────────┐ │ │ │                   │ │ │
│  │ ┌──────────┬────────┐          │ │ │ └───────────────────┘ │ │
│  │ │ Your Name│ [    ] │          │ │ │                       │ │
│  │ └──────────┴────────┘          │ │ │ Notes:                │ │
│  │                                 │ │ │ ┌───────────────────┐ │ │
│  │ Rate this dinner:               │ │ │ │                   │ │ │
│  │ 1 ●━━━━━━━━━● 5                │ │ │ │                   │ │ │
│  │              (slider at 5)      │ │ │ └───────────────────┘ │ │
│  │                                 │ │ │                       │ │
│  │ [Submit Rating]                 │ │ │ [Add Dinner]          │ │
│  │                                 │ │ └───────────────────────┘ │
│  │ ┌──────────┬────────┐          │ │                           │
│  │ │ Your Name│ [    ] │          │ │                           │
│  │ └──────────┴────────┘          │ │                           │
│  │                                 │ │                           │
│  │ Comment:                        │ │                           │
│  │ ┌─────────────────────────────┐│ │                           │
│  │ │                             ││ │                           │
│  │ │                             ││ │                           │
│  │ └─────────────────────────────┘│ │                           │
│  │                                 │ │                           │
│  │ [Submit Comment]                │ │                           │
│  └────────────────────────────────┘ │                           │
│                                      │                           │
│  Recent Ratings                      │                           │
│  ┌────────────────────────────────┐ │                           │
│  │ User   │ Rating │ Date         │ │                           │
│  ├────────┼────────┼──────────────┤ │                           │
│  │ Mom    │ 5      │ 2025-10-12.. │ │                           │
│  │ Dad    │ 4      │ 2025-10-12.. │ │                           │
│  │ Emma   │ 5      │ 2025-10-12.. │ │                           │
│  └────────────────────────────────┘ │                           │
│                                      │                           │
│  Recent Comments                     │                           │
│  ┌────────────────────────────────┐ │                           │
│  │ User │ Comment      │ Date     │ │                           │
│  ├──────┼──────────────┼──────────┤ │                           │
│  │ Mom  │ The sauce... │ 2025-... │ │                           │
│  │ Emma │ Can we make..│ 2025-... │ │                           │
│  └────────────────────────────────┘ │                           │
└─────────────────────────────────────┴───────────────────────────┘
```

### Key UI Elements

1. **This Week's Dinner Card**
   - Shows the most recent dinner entry
   - Displays: Date, Menu, Notes, Creation timestamp
   - Clean card layout with header and body

2. **Ratings & Comments Panel**
   - Split into two columns
   - Left: Rating submission (name + 1-5 slider)
   - Right: Comment submission (name + text area)
   - Primary blue buttons for submission

3. **Recent Ratings Table**
   - Compact DataTable showing recent ratings
   - Columns: User, Rating (1-5), Date
   - Limited to 5 entries for quick view

4. **Recent Comments Table**
   - DataTable with user comments
   - Columns: User, Comment, Date
   - Shows latest 5 comments

5. **Generate Report Sidebar**
   - Success-green button
   - Status message below
   - Explains report generation feature

6. **Add New Dinner Sidebar**
   - Date picker (calendar widget)
   - Text areas for menu and notes
   - Info-blue button for submission

## Tab 2: Dinner History

### Layout Description

```
┌─────────────────────────────────────────────────────────────────┐
│                      Dinner History Tab                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  All Family Dinners                                              │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Show [10 ▼] entries                    Search: [        ]   ││
│  ├────────┬──────────────────────┬─────────────┬──────────────┤│
│  │ Date   │ Menu                 │ Notes       │ Added        ││
│  ├────────┼──────────────────────┼─────────────┼──────────────┤│
│  │ 2025-  │ Roasted chicken,     │ Traditional │ 2025-10-12.. ││
│  │ 10-12  │ Mashed potatoes...   │ Sunday...   │              ││
│  ├────────┼──────────────────────┼─────────────┼──────────────┤│
│  │ 2025-  │ Spaghetti with       │ Great family│ 2025-10-05.. ││
│  │ 10-05  │ meat sauce, Caesar...│ dinner!...  │              ││
│  ├────────┼──────────────────────┼─────────────┼──────────────┤│
│  │ 2025-  │ Grilled salmon,      │ Healthy and │ 2025-09-28.. ││
│  │ 09-28  │ Rice pilaf...        │ delicious!  │              ││
│  ├────────┼──────────────────────┼─────────────┼──────────────┤│
│  │ ...    │ ...                  │ ...         │ ...          ││
│  └────────┴──────────────────────┴─────────────┴──────────────┘│
│  Showing 1 to 10 of 24 entries        [Previous] [1] [2] [Next]│
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key UI Elements

1. **DataTable Controls**
   - Show entries dropdown (10, 25, 50, 100)
   - Search box (searches all columns)
   - Automatic client-side filtering

2. **Data Columns**
   - Date: Sortable dinner date
   - Menu: Full menu description
   - Notes: Additional notes
   - Added: Creation timestamp

3. **Pagination**
   - Previous/Next buttons
   - Page numbers
   - Shows entry range

4. **Sorting**
   - Click column headers to sort
   - Toggle ascending/descending
   - Visual indicators (arrows)

## Tab 3: Suggestions

### Layout Description

```
┌─────────────────────────────────────────────────────────────────┐
│                         Suggestions Tab                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────┬───────────────────────────┐ │
│  │ Left Column (6/12 width)       │ Right Column (6/12 width) │ │
│  │                                │                           │ │
│  │ ┌────────────────────────────┐│ │ All Suggestions         │ │
│  │ │ Submit a Suggestion        ││ │                         │ │
│  │ │                            ││ │ ┌─────────────────────┐ │ │
│  │ │ Your Name:                 ││ │ │ Show [10▼] entries  │ │ │
│  │ │ ┌────────────────────────┐ ││ │ │ Search: [        ]  │ │ │
│  │ │ │                        │ ││ │ ├──────┬────────────┬─┤ │ │
│  │ │ └────────────────────────┘ ││ │ │ User │ Suggestion │S│ │ │
│  │ │                            ││ │ ├──────┼────────────┼─┤ │ │
│  │ │ Your Suggestion:           ││ │ │ Dad  │ How about..│p│ │ │
│  │ │ ┌────────────────────────┐ ││ │ │ Emma │ Taco Tue...│p│ │ │
│  │ │ │                        │ ││ │ │ Mom  │ Try that...│p│ │ │
│  │ │ │                        │ ││ │ │ ...  │ ...        │.│ │ │
│  │ │ │                        │ ││ │ └─────────────────────┘ │ │
│  │ │ │                        │ ││ │ Showing 1 to 10 of ... │ │
│  │ │ └────────────────────────┘ ││ │                         │ │
│  │ │                            ││ │                         │ │
│  │ │ [Submit Suggestion]        ││ │                         │ │
│  │ │                            ││ │                         │ │
│  │ └────────────────────────────┘│ │                         │ │
│  │                                │ │                         │ │
│  └────────────────────────────────┴───────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key UI Elements

1. **Suggestion Form**
   - Name text input
   - Multi-line text area for suggestion
   - Primary blue submit button
   - Contained in a well/panel

2. **Suggestions Table**
   - Columns: User, Suggestion, Status, Date
   - Status shows "pending", "accepted", or "completed"
   - Full DataTable functionality (search, sort, paginate)
   - Interactive and searchable

## Color Scheme

The application uses Bootstrap's default theme with these primary colors:

- **Primary (Blue)**: #337ab7 - For main action buttons
- **Success (Green)**: #5cb85c - For generate report button
- **Info (Light Blue)**: #5bc0de - For add dinner button
- **Background**: White/Light gray
- **Text**: Dark gray (#333)
- **Borders**: Light gray (#ddd)

## Responsive Design

The layout is responsive:
- **Desktop**: Three columns, full width
- **Tablet**: Stacked columns, readable widths
- **Mobile**: Single column, full-width elements

## Interactive Features

### Real-time Updates
- After submitting rating/comment/dinner, tables refresh automatically
- No page reload required
- Success notifications appear in top-right corner

### Notifications
```
┌────────────────────────────┐
│ ✓ Rating submitted!        │
└────────────────────────────┘
```

Notification types:
- Success (green): Successful operations
- Error (red): Failed operations
- Info (blue): General messages

## Empty States

When no data exists:

**No Dinners:**
```
┌────────────────────────────────────────┐
│ ℹ No dinners recorded yet. Add one    │
│   using the form on the right!        │
└────────────────────────────────────────┘
```

**No Ratings:**
```
┌─────────────────┐
│ Message         │
├─────────────────┤
│ No ratings yet  │
└─────────────────┘
```

## Data Display

### Ratings Display
- Shows as numbers (1-5)
- Could be enhanced with star icons (⭐⭐⭐⭐⭐)

### Date Display
- ISO format: YYYY-MM-DD HH:MM:SS
- Consistent throughout application

### Text Truncation
- Long text in tables may be truncated
- Hover for full text (DataTable feature)

## Button States

### Normal
```
┌──────────────────┐
│ Submit Rating    │
└──────────────────┘
```

### Hover
```
┌──────────────────┐
│ Submit Rating    │ (darker color)
└──────────────────┘
```

### Disabled
```
┌──────────────────┐
│ Submit Rating    │ (grayed out)
└──────────────────┘
```

## Form Validation

- Required fields marked with validation
- Empty submission prevented by `req()` function
- User-friendly error messages via notifications

## Accessibility Features

- Semantic HTML structure
- Form labels associated with inputs
- Keyboard navigation support (Bootstrap default)
- Screen reader friendly (DataTables accessible)

## Future UI Enhancements

Potential improvements:
- Star rating widget (instead of slider)
- Photo upload for dinners
- Calendar view of dinners
- Charts for rating trends
- Dark mode toggle
- User avatars
- Rich text editor for notes
- Emoji reactions
- Print-friendly views

---

**Note**: This is a textual representation of the UI. To see the actual application, run `shiny::runApp("app.R")` in R.

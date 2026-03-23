# Family Dinner Planner — Coding Spec

## Overview

A single-page React app (single `.html` file) with three screens: **Game**, **Snacks Review**, and **Parent Dashboard**. The game lets two kids (TacoCat and SmoreCat) take turns spinning a wheel and picking meals or snacks. Parents then finalize the weekly plan and generate a grocery list.

Tech: React (via CDN), Tailwind CSS (via CDN), localStorage for persistence. No backend.

---

## Data Model

Design the data model first. Even features we build later (saved meals library) should have a place in the schema from day one.

```js
// Top-level app state persisted to localStorage
{
  currentWeek: "2026-03-23",        // ISO date of the Monday
  gameState: { ... },                // see Game State below
  snackSelections: { ... },          // see Snack Selections below
  weeklyPlan: { ... },              // see Weekly Plan below
  mealDatabase: [ ... ],            // all available meals
  savedMeals: [ ... ],             // future: user-favorited meals
}
```

### Meal Object
```js
{
  id: "meal-001",
  main: "Tacos",
  side: "Spanish Rice",
  healthySide: "Side Salad",
  ingredients: ["tortillas", "ground beef", "taco seasoning", "rice", "tomatoes", "lettuce", "cheese", "salsa"],
  icon: "🌮",        // emoji fallback, could be image later
  addedBy: "TacoCat" // which player picked this, null if parent-added
}
```

### Snack Object
```js
{
  id: "snack-001",
  name: "Granola Bars",
  category: "school",        // "breakfast" | "school" | "general"
  ingredients: ["granola bars"],
  icon: "🥜",
  addedBy: "SmoreCat"       // or null
}
```

### Weekly Plan
```js
{
  monday:    { meal: null | MealObject, status: "tbd" | "planned" },
  tuesday:   { meal: null | MealObject, status: "tbd" | "planned" },
  wednesday: { meal: null | MealObject, status: "tbd" | "planned" },
  thursday:  { meal: null | MealObject, status: "tbd" | "planned" },
  friday:    { meal: { main: "Pizza", side: "Movie", healthySide: "—" }, status: "locked" },
  saturday:  { meal: null | MealObject, status: "tbd" | "planned" },
  sunday:    { meal: null | MealObject, status: "tbd" | "planned" },
}
```

### Game State
```js
{
  phase: "playing" | "finished",
  currentPlayer: "TacoCat" | "SmoreCat",
  players: {
    TacoCat:  { position: 0, mealsChosen: [], snacksChosen: [], avatar: "🐱🌮" },
    SmoreCat: { position: 0, mealsChosen: [], snacksChosen: [], avatar: "🐱🍫" },
  },
  board: [ ...BoardSpace ],         // the path of spaces
  spinResult: null | WheelSegment,   // current spin result
  pickingPhase: null | "meal" | "snack",  // what the player is choosing right now
}
```

---

## Screen 1: The Game

### Game Board

A visual path of **14 spaces** (7 per player on average). Each space has a type:

| Type       | Count | What happens when you land on it |
|------------|-------|----------------------------------|
| `meal`     | 5     | Player opens the meal builder (picks main + side + healthy side) |
| `snack`    | 3     | Player picks one snack from any category |
| `star`     | 3     | Fun animation, bonus confetti, no action — "You're a superstar!" |
| `swap`     | 1     | Players trade positions on the board |
| `double`   | 1     | Spin again! Get a second turn |
| `finish`   | 1     | Final space — game complete |

**Space layout** (example, randomize on new game):
```
[meal] [star] [snack] [meal] [star] [meal] [swap] [snack] [star] [meal] [double] [snack] [meal] [finish]
```

**Key constraint**: The board must guarantee that each player lands on **at least 2 meal spaces and at least 1 snack space**. To enforce this:
- The game tracks each player's meal and snack counts
- If a player is approaching the end of the board and hasn't met minimums, the spinner becomes **weighted** — it forces a meal or snack result as needed
- The game doesn't end until both players have met their minimums (2 meals, 1 snack each)

### The Spinner

A circular wheel divided into segments. The spinner determines **how many spaces you move** (1, 2, or 3). After moving, the space you land on determines what happens.

Wheel segments:
- **Move 1** (40% of wheel)
- **Move 2** (35% of wheel)
- **Move 3** (25% of wheel)

Visual: an animated wheel that spins and slows to a stop. Satisfying for kids. The spin should take ~2-3 seconds with easing.

### Meal Builder (triggered on meal space)

When a player lands on a meal space, a card flips open with three columns:

1. **Main** — scrollable list of options with icons (e.g., 🌮 Tacos, 🍝 Pasta, 🍗 Chicken, 🐟 Fish, 🍔 Burgers...)
2. **Side** — scrollable list (e.g., 🍚 Rice, 🥔 Potatoes, 🍝 Mac & Cheese, 🌽 Corn Bread...)
3. **Healthy Side** — scrollable list (e.g., 🥦 Broccoli, 🥗 Salad, 🥕 Carrots, 🫛 Green Beans...)

Each option is a **big tappable card** with an icon/emoji and short label. Designed for a 5-year-old to understand visually.

Player taps one from each column. A "Done!" button confirms the meal and adds it to their picks.

#### Starter Meal Components (seed data)

**Mains (~12-15):**
| Label | Icon | Ingredients |
|-------|------|-------------|
| Tacos | 🌮 | tortillas, ground beef, taco seasoning, cheese, salsa, lettuce |
| Spaghetti | 🍝 | spaghetti noodles, marinara sauce, ground beef, parmesan |
| Chicken Nuggets | 🍗 | chicken nuggets, ketchup |
| Grilled Chicken | 🍗 | chicken breasts, olive oil, seasoning |
| Burgers | 🍔 | hamburger buns, ground beef, cheese, ketchup, mustard |
| Mac & Cheese | 🧀 | macaroni, cheese sauce, milk, butter |
| Stir Fry | 🥘 | chicken, soy sauce, sesame oil, mixed veggies |
| Fish Sticks | 🐟 | fish sticks, tartar sauce |
| Quesadillas | 🫔 | tortillas, cheese, chicken |
| Soup | 🍲 | chicken broth, noodles, carrots, celery |
| Breakfast for Dinner | 🥞 | pancake mix, eggs, syrup, bacon |
| Hot Dogs | 🌭 | hot dogs, buns, ketchup, mustard |
| Meatballs | 🧆 | meatballs, marinara sauce, bread |

**Sides (~10):**
| Label | Icon | Ingredients |
|-------|------|-------------|
| Rice | 🍚 | rice |
| Mashed Potatoes | 🥔 | potatoes, butter, milk |
| Mac & Cheese | 🧀 | macaroni, cheese sauce |
| French Fries | 🍟 | frozen french fries |
| Corn on the Cob | 🌽 | corn, butter |
| Garlic Bread | 🍞 | bread, butter, garlic |
| Applesauce | 🍎 | applesauce |
| Chips & Salsa | 🫙 | tortilla chips, salsa |
| Fruit Cup | 🍇 | mixed fruit |
| Rolls | 🥖 | dinner rolls, butter |

**Healthy Sides (~10):**
| Label | Icon | Ingredients |
|-------|------|-------------|
| Broccoli | 🥦 | broccoli, butter |
| Side Salad | 🥗 | lettuce, tomatoes, cucumber, ranch |
| Carrots & Ranch | 🥕 | baby carrots, ranch dressing |
| Green Beans | 🫛 | green beans, butter |
| Steamed Veggies | 🥬 | mixed vegetables |
| Cucumber Slices | 🥒 | cucumber |
| Fruit Salad | 🍓 | strawberries, blueberries, grapes |
| Celery & PB | 🥜 | celery, peanut butter |
| Edamame | 🫘 | edamame, salt |
| Sweet Potato | 🍠 | sweet potato, butter, cinnamon |

### Snack Picker (triggered on snack space)

When a player lands on a snack space, a panel slides up showing three tabs: **Breakfast**, **School**, **General**. Each tab has a grid of snack options as tappable cards. Player picks **one snack** and it gets added to the snack list.

#### Starter Snack Options

**Breakfast Snacks (~8):**
Yogurt, Granola Bars, Muffins, Fruit & Oatmeal, Toast & Jam, Cereal Cups, Banana Bread, Smoothie Pouches

**School Snacks (~8):**
Goldfish Crackers, Cheese Sticks, Apple Slices, Pretzels, Trail Mix, Crackers & Hummus, Popcorn, Fruit Snacks

**General Snacks (~8):**
Cookies, Ice Cream, Chips, Animal Crackers, Graham Crackers, Pudding Cups, Cheese & Crackers, Veggies & Dip

### Player Avatars

Two characters:
- **TacoCat** — a cat with a taco theme. Placeholder: 🐱 with taco accent. Later: custom image via `<img>` tag
- **SmoreCat** — a cat with a s'more theme. Placeholder: 🐱 with marshmallow accent. Later: custom image via `<img>` tag

Both should have a slot in the code for a custom image URL (default to emoji/CSS-drawn avatar).

### Game Flow

```
1. Game starts → TacoCat goes first
2. Active player taps "Spin!"
3. Wheel animates → lands on 1, 2, or 3
4. Character hops forward that many spaces (animated)
5. Check what space they landed on:
   - meal → open Meal Builder, wait for pick
   - snack → open Snack Picker, wait for pick
   - star → confetti animation + encouraging message
   - swap → swap player positions, fun animation
   - double → player gets another spin immediately
6. Turn ends → switch to other player
7. Repeat until a player reaches or passes the finish space
8. Check minimums:
   - If both players have ≥2 meals and ≥1 snack → game complete!
   - If not → bonus round: player(s) who need more get guaranteed meal/snack spins
9. Celebration screen → "Great job TacoCat & SmoreCat! Let's see what we're eating this week!"
10. Transition to parent dashboard (or snack review first)
```

### Game Screen Layout

```
┌─────────────────────────────────────────────────┐
│  🎲 Family Dinner Dash!                         │
│                                                  │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│  │🍽│→│⭐│→│🍪│→│🍽│→│⭐│→│🍽│→│🔄│  ...      │
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘           │
│    ↑ TacoCat (space 1)                          │
│         ↑ SmoreCat (space 2)                    │
│                                                  │
│  ┌──────────────┐    ┌─────────────────────┐    │
│  │  🎡 SPINNER  │    │  TacoCat's Picks:   │    │
│  │              │    │  🌮 Tacos meal       │    │
│  │  [ SPIN! ]   │    │  🍪 Granola Bars     │    │
│  │              │    │                      │    │
│  └──────────────┘    │  SmoreCat's Picks:   │    │
│                      │  🍝 Pasta meal        │    │
│                      │  (needs 1 more meal) │    │
│                      └─────────────────────┘    │
└─────────────────────────────────────────────────┘
```

---

## Screen 2: Snack Review

After the game, a **quick review screen** for snacks. This is where parents (or kids) can add more snacks beyond what was picked in the game.

Three columns: **Breakfast | School | General**

Each column shows:
- Snacks already picked during the game (pre-checked, labeled with who picked them)
- Full checklist of all available snacks in that category
- Anyone can check/uncheck freely

A "Done with Snacks" button advances to the dashboard.

---

## Screen 3: Parent Dashboard

### Weekly Calendar

A 7-column grid (Mon–Sun). Each day cell shows:

- **Day name** header
- **Meal card** (if assigned): shows main, side, healthy side
- **Status badge**: "Planned" (green), "TBD" (amber), or "Locked" (for Friday)
- **Edit button**: opens a dropdown/modal to change the meal
- **Source label**: "TacoCat's pick" / "SmoreCat's pick" / "Parent" — in small text

**Friday** is always locked to Pizza & Movie and cannot be edited.

**Populating the calendar:**
After the game, the kids' meal picks go into an **unassigned pool**. Parents drag meals from the pool into day slots (or tap a day → pick from pool). Days without assigned meals show as TBD.

The pool area sits above or beside the calendar:
```
┌─────────────────────────────────────────────────┐
│  📋 Unassigned Meals (from the game)            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │TacoCat │ │TacoCat │ │Smore.. │ │Smore.. │  │
│  │Tacos   │ │Chicken │ │Pasta   │ │Stir Fry│  │
│  │Rice    │ │Fries   │ │Bread   │ │Rice    │  │
│  │Salad   │ │Broccoli│ │Carrots │ │Edamame │  │
│  └────────┘ └────────┘ └────────┘ └────────┘  │
│                                                  │
│  Mon    Tue    Wed    Thu    Fri     Sat    Sun  │
│ ┌─────┐┌─────┐┌─────┐┌─────┐┌──────┐┌─────┐┌─────┐
│ │ TBD ││ TBD ││ TBD ││ TBD ││🍕🎬  ││ TBD ││ TBD │
│ │     ││     ││     ││     ││Pizza &││     ││     │
│ │[tap ││[tap ││[tap ││[tap ││Movie ││[tap ││[tap │
│ │to   ││to   ││to   ││to   ││LOCKED││to   ││to   │
│ │fill]││fill]││fill]││fill]││      ││fill]││fill]│
│ └─────┘└─────┘└─────┘└─────┘└──────┘└─────┘└─────┘
└─────────────────────────────────────────────────┘
```

**Manual entry**: Parents can also type a custom meal for any day (not just from the pool). A simple form: main, side, healthy side, and an ingredients list (comma-separated).

**TBD slots**: Remain as TBD until filled. No pressure to fill everything in one session.

### Grocery List

Auto-generated from:
1. All meals assigned to calendar days (not TBD days, not Friday)
2. All selected snacks

**Deduplication**: If two meals both need "rice," it appears once in the list.

**Layout**:
```
┌─────────────────────────────────────────────────┐
│  🛒 Grocery List                                │
│                                                  │
│  Meal Ingredients:                              │
│  ☐ tortillas               ☐ ground beef        │
│  ☐ taco seasoning          ☐ cheese             │
│  ☐ spaghetti noodles       ☐ marinara sauce     │
│  ☑ rice (already have)     ☐ chicken breasts    │
│  ...                                            │
│                                                  │
│  Snack Items:                                   │
│  ☐ granola bars            ☐ goldfish crackers  │
│  ☐ yogurt                  ☑ apple juice (have) │
│  ...                                            │
│                                                  │
│  [ 📋 Copy Remaining Items ]                    │
│                                                  │
└─────────────────────────────────────────────────┘
```

**"Copy Remaining Items"** button: Copies all **unchecked** items to clipboard as a plain text list:
```
Grocery List (Week of Mar 23):
- tortillas
- ground beef
- taco seasoning
- cheese
- spaghetti noodles
- marinara sauce
- chicken breasts
- granola bars
- goldfish crackers
- yogurt
```

---

## Navigation

A tab bar or top nav with three sections:

```
[ 🎲 Game ]  [ 🍪 Snacks ]  [ 📅 Plan & Groceries ]
```

- **Game** tab: the board game (only active during game play, shows results after)
- **Snacks** tab: the snack checklist
- **Plan & Groceries** tab: the parent dashboard with calendar + grocery list

The flow is designed to go Game → Snacks → Dashboard, but all tabs are always accessible. A "New Week" button resets the game and plan for a fresh start.

---

## Visual Design

**Vibe**: Family dashboard — polished enough that parents enjoy using it, colorful enough that kids are excited. Not garish, not corporate.

- **Color palette**: Warm, inviting. Think soft teal/sage backgrounds, warm coral/orange accents for interactive elements, golden yellow for highlights and celebrations
- **Typography**: Rounded, friendly sans-serif (use system fonts or a Google Font like Nunito or Quicksand)
- **Cards**: Rounded corners (12-16px), subtle shadows, hover/tap states
- **Animations**:
  - Spinner wheel: smooth CSS rotation with easing
  - Character movement: hopping animation along the board path
  - Confetti: on star spaces and game completion (use canvas-confetti library or CSS)
  - Card flip: when meal builder opens
- **Responsiveness**: Must work on iPad (likely what the kids use at the table) and desktop. Tablet-first.

### Player Avatars

- **TacoCat**: CSS-drawn or emoji placeholder. A cat face with taco-themed coloring. Reserve an `<img>` slot so Matt can drop in custom images later.
- **SmoreCat**: Same approach, s'more/marshmallow themed.

Each avatar has a **name plate** beneath it and a **glow effect** when it's their turn.

---

## Persistence (localStorage)

### Save Strategy

Save the full app state to `localStorage` under key `familyDinnerPlanner`:

```js
localStorage.setItem('familyDinnerPlanner', JSON.stringify(appState))
```

**When to save**: After every meaningful state change (meal picked, snack toggled, calendar updated, item checked off).

**When to load**: On app mount, check localStorage. If data exists and `currentWeek` matches this week's Monday, restore state. If it's a new week, prompt: "Start a new week or continue last week's plan?"

### Future: Saved Meals Library

The data model includes a `savedMeals` array. For now it's unused in the UI, but the schema is ready:
```js
{
  id: "saved-001",
  main: "Tacos",
  side: "Rice",
  healthySide: "Salad",
  ingredients: [...],
  timesUsed: 5,
  lastUsed: "2026-03-16",
  familyRating: 4   // future: let family rate meals
}
```

---

## Component Architecture

```
App
├── NavBar (tab switching)
├── GameScreen
│   ├── GameBoard (the path of spaces + player positions)
│   ├── Spinner (the wheel)
│   ├── PlayerPanel (shows each player's picks and status)
│   ├── MealBuilder (modal/overlay for picking main + side + healthy side)
│   ├── SnackPicker (modal/overlay for picking a snack)
│   └── GameComplete (celebration screen)
├── SnackScreen
│   ├── SnackColumn (one per category: breakfast, school, general)
│   └── SnackItem (individual checkable snack)
├── DashboardScreen
│   ├── MealPool (unassigned meals from the game)
│   ├── WeeklyCalendar
│   │   └── DayCell (one per day, shows meal or TBD)
│   ├── MealEditor (modal for editing/adding a meal to a day)
│   └── GroceryList
│       ├── GrocerySection (meal ingredients vs snack items)
│       ├── GroceryItem (individual item with checkbox)
│       └── CopyButton
└── NewWeekPrompt (modal: start fresh or continue?)
```

---

## Implementation Order

Build in this order so you have something testable at each step:

### Phase 1: Foundation
1. Set up the HTML file with React, ReactDOM, Tailwind via CDN
2. Build the `App` shell with tab navigation
3. Implement the data model and localStorage save/load
4. Build the `NewWeekPrompt` component

### Phase 2: Parent Dashboard (build the destination first)
5. Build `WeeklyCalendar` with day cells, TBD state, Friday locked
6. Build `MealEditor` modal (manual meal entry)
7. Build `MealPool` (hardcode a few meals to test drag-to-assign)
8. Build `GroceryList` with auto-generation, checkboxes, and copy button
9. Build `SnackScreen` with three columns and checkable items

### Phase 3: The Game
10. Build `GameBoard` layout (the path of spaces, static first)
11. Build `Spinner` with animation
12. Build player movement animation
13. Build `MealBuilder` modal (the three-column picker)
14. Build `SnackPicker` modal (triggered from snack spaces)
15. Implement game flow logic (turns, minimums, bonus rounds)
16. Build `GameComplete` celebration screen
17. Wire game results into the dashboard (populate MealPool and SnackScreen)

### Phase 4: Polish
18. Add confetti and animations for star/swap/double spaces
19. Refine avatar placeholders with image slot support
20. Test on iPad-sized viewport
21. Add "New Week" reset flow
22. Final visual polish pass

---

## Seed Data Location

All meal components and snack options should be defined in a single `SEED_DATA` constant at the top of the file. This makes it easy for Matt to edit the options without digging through components:

```js
const SEED_DATA = {
  mains: [ { id, label, icon, defaultIngredients }, ... ],
  sides: [ { id, label, icon, defaultIngredients }, ... ],
  healthySides: [ { id, label, icon, defaultIngredients }, ... ],
  snacks: {
    breakfast: [ { id, label, icon, defaultIngredients }, ... ],
    school: [ { id, label, icon, defaultIngredients }, ... ],
    general: [ { id, label, icon, defaultIngredients }, ... ],
  },
  boardLayout: [ "meal", "star", "snack", "meal", ... ],  // space types in order
}
```

---

## Key UX Details

- **Spin button**: Big, central, impossible to miss. Glows when it's your turn.
- **Turn indicator**: The active player's avatar pulses/glows. The other is dimmed.
- **Meal builder close**: No "X" close button — must pick all three to continue. Encourages commitment over analysis paralysis.
- **Sound effects**: Optional future add. Leave hooks for them (`playSound('spin')`, `playSound('confetti')`).
- **Undo**: No undo in the game (keeps it simple). Parents can freely edit everything in the dashboard.
- **Friday**: Locked everywhere. Can't assign meals to it. Can't remove Pizza & Movie. It's sacred.
- **Copy format**: Plain text, one item per line, prefixed with "- ". Clean enough to paste into any app.

---

## Notes for Future Iterations

These are NOT in scope for v1 but the architecture should not block them:

- **Saved Meals Library**: Browse past meals, mark favorites, quick-add to calendar
- **Kroger Integration**: "Send to Kroger Cart" button alongside "Copy" button
- **Custom Avatars**: Upload images for TacoCat and SmoreCat
- **Meal Ratings**: After the week, rate meals 1-5 stars as a family
- **Shopping History**: Track what you buy to auto-check "already have" items
- **Sound Effects**: Fun sounds for spinning, landing, picking
- **Multi-week View**: See past weeks for inspiration

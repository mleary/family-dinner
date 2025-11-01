import streamlit as st
import pandas as pd
from datetime import datetime

# Page configuration
st.set_page_config(
    page_title="Family Dinner Menu",
    page_icon="🍽️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for card styling
st.markdown("""
<style>
    .menu-card {
        background-color: #f8f9fa;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin: 20px 0;
    }
    .menu-header {
        color: #2c3e50;
        font-size: 2.5em;
        font-weight: bold;
        text-align: center;
        margin-bottom: 20px;
    }
    .menu-date {
        color: #7f8c8d;
        font-size: 1.2em;
        text-align: center;
        margin-bottom: 30px;
    }
    .menu-section {
        background-color: white;
        border-radius: 8px;
        padding: 20px;
        margin: 15px 0;
        border-left: 4px solid #3498db;
    }
    .menu-section-title {
        color: #3498db;
        font-size: 1.3em;
        font-weight: bold;
        margin-bottom: 10px;
    }
    .menu-section-content {
        color: #34495e;
        font-size: 1.1em;
        line-height: 1.6;
    }
    .placeholder-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 10px;
        padding: 60px;
        text-align: center;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin: 20px 0;
    }
    .placeholder-text {
        color: white;
        font-size: 2em;
        font-weight: bold;
    }
</style>
""", unsafe_allow_html=True)

# Load menu data
@st.cache_data
def load_menus():
    try:
        df = pd.read_csv('menus.csv')
        df['date'] = pd.to_datetime(df['date'])
        return df.sort_values('date')
    except FileNotFoundError:
        return pd.DataFrame()

# Function to get next menu
def get_next_menu(menus_df):
    if menus_df.empty:
        return None
    
    today = datetime.now().date()
    future_menus = menus_df[menus_df['date'].dt.date >= today]
    
    if not future_menus.empty:
        return future_menus.iloc[0]
    else:
        # If no future menus, show the most recent one
        return menus_df.iloc[-1]

# Function to display menu card
def display_menu_card(menu_row):
    st.markdown('<div class="menu-card">', unsafe_allow_html=True)
    
    st.markdown(f'<div class="menu-header">🍽️ Family Dinner Menu</div>', unsafe_allow_html=True)
    st.markdown(f'<div class="menu-date">{menu_row["date"].strftime("%A, %B %d, %Y")}</div>', unsafe_allow_html=True)
    
    st.markdown(f'''
    <div class="menu-section">
        <div class="menu-section-title">🍗 Main Dish</div>
        <div class="menu-section-content">{menu_row["main_dish"]}</div>
    </div>
    ''', unsafe_allow_html=True)
    
    st.markdown(f'''
    <div class="menu-section">
        <div class="menu-section-title">🥗 Side Dish</div>
        <div class="menu-section-content">{menu_row["side_dish"]}</div>
    </div>
    ''', unsafe_allow_html=True)
    
    st.markdown(f'''
    <div class="menu-section">
        <div class="menu-section-title">🍰 Dessert</div>
        <div class="menu-section-content">{menu_row["dessert"]}</div>
    </div>
    ''', unsafe_allow_html=True)
    
    if pd.notna(menu_row.get("notes")):
        st.markdown(f'''
        <div class="menu-section">
            <div class="menu-section-title">📝 Notes</div>
            <div class="menu-section-content">{menu_row["notes"]}</div>
        </div>
        ''', unsafe_allow_html=True)
    
    st.markdown('</div>', unsafe_allow_html=True)

# Function to display placeholder when no menu available
def display_placeholder():
    st.markdown('''
    <div class="placeholder-card">
        <div class="placeholder-text">🍽️ More to Come!</div>
        <p style="color: white; font-size: 1.2em; margin-top: 20px;">
            Our next delicious family dinner menu will be announced soon.
        </p>
    </div>
    ''', unsafe_allow_html=True)

# Main app
def main():
    # Sidebar navigation
    st.sidebar.title("🏠 Navigation")
    page = st.sidebar.radio(
        "Select Page",
        ["Next Menu", "Previous Menus"],
        index=0
    )
    
    st.sidebar.markdown("---")
    st.sidebar.markdown("### About")
    st.sidebar.markdown("Weekly family dinner menu planner")
    
    # Load menus
    menus_df = load_menus()
    
    if page == "Next Menu":
        st.title("Next Family Dinner")
        
        if not menus_df.empty:
            next_menu = get_next_menu(menus_df)
            if next_menu is not None:
                display_menu_card(next_menu)
            else:
                display_placeholder()
        else:
            display_placeholder()
    
    elif page == "Previous Menus":
        st.title("Previous Menus")
        
        if not menus_df.empty:
            today = datetime.now().date()
            past_menus = menus_df[menus_df['date'].dt.date < today]
            
            if not past_menus.empty:
                st.markdown("### Past Family Dinners")
                
                # Display past menus in reverse chronological order
                for idx, menu in past_menus.iloc[::-1].iterrows():
                    with st.expander(f"🍽️ {menu['date'].strftime('%A, %B %d, %Y')} - {menu['main_dish']}"):
                        col1, col2, col3 = st.columns(3)
                        
                        with col1:
                            st.markdown("**🍗 Main Dish**")
                            st.write(menu['main_dish'])
                        
                        with col2:
                            st.markdown("**🥗 Side Dish**")
                            st.write(menu['side_dish'])
                        
                        with col3:
                            st.markdown("**🍰 Dessert**")
                            st.write(menu['dessert'])
                        
                        if pd.notna(menu.get('notes')):
                            st.markdown("**📝 Notes**")
                            st.write(menu['notes'])
            else:
                st.info("No previous menus available yet. Check back after your first family dinner!")
        else:
            st.info("No menus available yet. Start by adding some menus to the CSV file!")

if __name__ == "__main__":
    main()

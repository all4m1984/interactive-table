import csv
import random
from datetime import datetime, timedelta

# Configuration
NUM_RECORDS = 10000
OUTPUT_FILE = "hits2_synthetic_data.csv"

# Data generators
def random_date(start_date, end_date):
    """Generate a random date between start_date and end_date"""
    time_delta = end_date - start_date
    random_days = random.randint(0, time_delta.days)
    return start_date + timedelta(days=random_days)

def random_ip():
    """Generate a random IP address"""
    return f"{random.randint(1, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}"

def random_search_phrase():
    """Generate a random search phrase"""
    phrases = [
        "python tutorial",
        "data science",
        "machine learning",
        "artificial intelligence",
        "web development",
        "cloud computing",
        "database design",
        "snowflake tutorial",
        "sql queries",
        "data analytics",
        "big data",
        "data warehouse",
        "business intelligence",
        "data visualization",
        "pandas dataframe",
        "numpy arrays",
        "deep learning",
        "neural networks",
        "natural language processing",
        "computer vision",
        "api development",
        "microservices",
        "docker containers",
        "kubernetes",
        "devops practices",
        "agile methodology",
        "project management",
        "software engineering",
        "code review",
        "unit testing",
        "",  # Empty search phrase
        "",
        ""
    ]
    return random.choice(phrases)

def random_title():
    """Generate a random page title"""
    titles = [
        "Home Page",
        "Product Catalog",
        "About Us",
        "Contact Information",
        "User Dashboard",
        "Account Settings",
        "Blog Post - Tech News",
        "Tutorial: Getting Started",
        "Documentation",
        "FAQ - Frequently Asked Questions",
        "Search Results",
        "Shopping Cart",
        "Checkout Page",
        "Order Confirmation",
        "Customer Reviews",
        "Product Details",
        "Privacy Policy",
        "Terms of Service",
        "Help Center",
        "Support Portal",
        "News and Updates",
        "Community Forum",
        "Events Calendar",
        "Pricing Plans",
        "Features Overview",
        "Case Studies",
        "Testimonials",
        "Partners Page",
        "Careers",
        "Press Releases"
    ]
    return random.choice(titles)

def generate_record(date_start, date_end):
    """Generate a single record"""
    return {
        "EventDate": random_date(date_start, date_end).strftime("%Y-%m-%d"),
        "CounterID": random.randint(1000, 9999),
        "ClientIP": random_ip(),
        "SearchEngineID": random.choice([0, 1, 2, 3, 4, 5]),  # 0 = none, 1-5 = different search engines
        "SearchPhrase": random_search_phrase(),
        "ResolutionWidth": random.choice([1920, 1366, 1440, 1536, 1280, 1024, 768, 2560, 3840]),
        "Title": random_title(),
        "IsRefresh": random.choice([0, 0, 0, 1]),  # 25% chance of refresh
        "DontCountHits": random.choice([0, 0, 0, 0, 1])  # 20% chance of not counting
    }

def main():
    print(f"Generating {NUM_RECORDS} synthetic records...")
    
    # Define date range (last year)
    end_date = datetime.now()
    start_date = end_date - timedelta(days=365)
    
    # Generate data
    records = []
    for i in range(NUM_RECORDS):
        records.append(generate_record(start_date, end_date))
        if (i + 1) % 1000 == 0:
            print(f"Generated {i + 1} records...")
    
    # Write to CSV
    print(f"\nWriting to {OUTPUT_FILE}...")
    fieldnames = ["EventDate", "CounterID", "ClientIP", "SearchEngineID", 
                  "SearchPhrase", "ResolutionWidth", "Title", "IsRefresh", "DontCountHits"]
    
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)
    
    print(f"Successfully created {OUTPUT_FILE} with {NUM_RECORDS} records!")
    print(f"\nYou can load this into Snowflake using:")
    print(f"COPY INTO HITS2_CSV")
    print(f"FROM @your_stage/{OUTPUT_FILE}")
    print(f"FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '\"' SKIP_HEADER = 1);")

if __name__ == "__main__":
    main()


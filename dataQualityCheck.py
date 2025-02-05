import pandas as pd

# Load JSON data
users = pd.read_json("users.json")
receipts = pd.read_json("receipts.json")
rewards_receipt_items = pd.read_json("rewards_receipt_items.json")
brands = pd.read_json("brands.json")

def check_primary_key(df, primary_key):
    """Check for unique and non-null primary key."""
    if df[primary_key].isnull().any():
        print(f"Primary key {primary_key} has null values.")
    if not df[primary_key].is_unique:
        print(f"Primary key {primary_key} is not unique.")
		
def find_invalid_order(df, col1, col2):
    """
    Find rows where values in col1 are greater than values in col2.
    """
    invalid_order = df.loc[valid_rows, col1] < df.loc[valid_rows, col2]
    if invalid_order.any():
        print(f"Rows where {last_login_col} is earlier than {created_date_col}:")

def check_category_validity(df, column, allowed_values):
    """Validate that a column contains only allowed values."""
    if not df[column].isin(allowed_values).all():
        print(f"Invalid values found in column {column}.")
		
def check_composite_key_uniqueness(df, key_columns):
    # Check for duplicate rows based on the composite key
    duplicates = df[df.duplicated(subset=key_columns, keep=False)]

    if not duplicates.empty:
        print(f"Duplicate composite key found in columns: {key_columns}")



# USERS table checks
print("USERS table checks:")
check_primary_key(users, "_id")
find_invalid_order(users, "lastLogin", "createdDate")
check_category_validity(users, "active", ["true", "false"])

# RECEIPTS table checks
print("\nRECEIPTS table checks:")
check_primary_key(receipts, "_id")
check_date_validity(receipts, "modifyDate", "createDate")


# RewardsReceiptItems table checks
print("\nRewardsReceiptItems table checks:")
check_primary_key(rewards_receipt_items, "rewardsreceiptitemId")

# BRANDS table checks
print("\nBRANDS table checks:")
check_primary_key(brands, "_id")




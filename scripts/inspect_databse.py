import sqlite3
from pathlib import Path

# Get the main project directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Locate the database
DATABASE = BASE_DIR / "Database" / "NittanyRide.db"

def inspect_database():

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()

    # Make sure foreign keys are enabled
    cursor.execute("PRAGMA foreign_keys = ON")

    # Get all tables
    cursor.execute("""
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
        ORDER BY name;
    """)

    tables = cursor.fetchall()

    print("\n========== DATABASE SCHEMA ==========")

    for (table,) in tables:

        print(f"\nTABLE: {table}")
        print("-" * 50)

        # Inspect columns
        cursor.execute(f'PRAGMA table_info("{table}")')

        columns = cursor.fetchall()

        print("\nColumns:")

        for col in columns:
            cid, name, data_type, not_null, default, pk = col

            print(
                f"  {name} | "
                f"Type: {data_type} | "
                f"NOT NULL: {bool(not_null)} | "
                f"Primary Key: {bool(pk)} | "
                f"Default: {default}"
            )

        # Inspect foreign keys
        cursor.execute(f'PRAGMA foreign_key_list("{table}")')

        foreign_keys = cursor.fetchall()

        print("\nForeign Keys:")

        if foreign_keys:
            for fk in foreign_keys:
                print(
                    f"  {fk[3]} -> "
                    f"{fk[2]}.{fk[4]}"
                )
        else:
            print("  None")

    conn.close()


if __name__ == "__main__":
    inspect_database()

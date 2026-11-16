
import sqlite3
import pandas as pd
from pathlib import Path

# Get the main paths for the CSV files and Database
BASE_DIR = Path(__file__).resolve().parent.parent

DATABASE = BASE_DIR / "Database" / "NittanyRide.db"
CSV_FOLDER = BASE_DIR / "CSV Files"


# Initialize table order
# Parent tables must be imported before dependent tables.

TABLE_ORDER = [
    "Zone",
    "ZipCode",
    "User",
    "Rider",
    "Driver",
    "SupportStaff",
    "Vehicle",
    "RideTypeCategory",
    "PaymentCard",
    "RideOffering",
    "RideRequest",
    "Payment",
    "Review",
    "Question",
    "SupportRequest",
    "Refund",
    "SafetyAlert"
]


# Database population

def populate_database():

    if not DATABASE.exists():
        raise FileNotFoundError(
            f"Database not found: {DATABASE}"
        )

    if not CSV_FOLDER.exists():
        raise FileNotFoundError(
            f"CSV folder not found: {CSV_FOLDER}"
        )

    connection = sqlite3.connect(DATABASE)

    try:

        # Enable foreign key enforcement
        connection.execute("PRAGMA foreign_keys = ON")

        print("\n===================================")
        print("       NITTANYRIDE DATABASE")
        print("          POPULATION")
        print("===================================\n")

        connection.execute("BEGIN")

        total_records = 0

        for table in TABLE_ORDER:

            csv_file = CSV_FOLDER / f"{table}.csv"

            if not csv_file.exists():
                raise FileNotFoundError(
                    f"Missing CSV file: {csv_file}"
                )

            print(f"Importing {table}...")

            # Read CSV using pandas
            df = pd.read_csv(
                csv_file,
                dtype=str,
                keep_default_na=False
            )

            # Convert empty strings and \N into SQL NULL
            df = df.replace(
                {"": None, r"\N": None}
            )

            # Ensure missing values are Python None
            df = df.astype(object).where(
                pd.notna(df),
                None
            )

            # Check that the table exists
            table_info = connection.execute(
                f'PRAGMA table_info("{table}")'
            ).fetchall()

            if not table_info:
                raise ValueError(
                    f"Table '{table}' does not exist "
                    "in the database."
                )

            # Get existing database column names
            db_columns = [column[1] for column in table_info]

            # Check for invalid CSV columns
            invalid_columns = [
                col for col in df.columns
                if col not in db_columns
            ]

            if invalid_columns:
                raise ValueError(
                    f"{table}: Unknown CSV columns: "
                    f"{invalid_columns}"
                )

            # Check for missing required columns
            missing_columns = []

            for column in table_info:

                col_name = column[1]
                col_type = (column[2] or "").upper()
                not_null = column[3]
                default_value = column[4]
                primary_key = column[5]

                # SQLite automatically generates an
                # INTEGER PRIMARY KEY if omitted.
                auto_generated_pk = (
                    primary_key
                    and col_type == "INTEGER"
                )

                required = (
                    (not_null or primary_key)
                    and default_value is None
                    and not auto_generated_pk
                )

                if required and col_name not in df.columns:
                    missing_columns.append(col_name)

            if missing_columns:
                raise ValueError(
                    f"{table}: Missing required columns: "
                    f"{missing_columns}"
                )

            # Skip empty CSV files
            if df.empty:
                print(f"  No records found in {table}.\n")
                continue

            # Build INSERT statement
            columns = list(df.columns)

            column_names = ", ".join(
                f'"{column}"' for column in columns
            )

            placeholders = ", ".join(
                ["?"] * len(columns)
            )

            sql = (
                f'INSERT INTO "{table}" '
                f'({column_names}) '
                f'VALUES ({placeholders})'
            )

            # Convert DataFrame into tuples
            records = list(
                df.itertuples(index=False, name=None)
            )

            # Insert records into existing table
            connection.executemany(sql, records)

            imported = len(records)
            total_records += imported

            print(
                f"  Successfully imported "
                f"{imported} records.\n"
            )

        # Check referential integrity before committing
        foreign_key_errors = connection.execute(
            "PRAGMA foreign_key_check"
        ).fetchall()

        if foreign_key_errors:
            raise ValueError(
                "Foreign key violations detected:\n"
                f"{foreign_key_errors}"
            )

        # Commit all imports
        connection.commit()

        print("===================================")
        print("       IMPORT COMPLETED")
        print("===================================")

        print(f"\nTotal records imported: {total_records}")

        # Check database integrity
        integrity = connection.execute(
            "PRAGMA integrity_check"
        ).fetchone()[0]

        print(f"Database integrity: {integrity}")

        # Display final table counts
        print("\nFINAL TABLE COUNTS")
        print("-----------------------------------")

        for table in TABLE_ORDER:

            count = connection.execute(
                f'SELECT COUNT(*) FROM "{table}"'
            ).fetchone()[0]

            print(f"{table:<20} {count}")

        print("-----------------------------------")
        print("\nDatabase population successful!")

    except Exception as error:

        # Undo all inserts if anything fails
        connection.rollback()

        print("\n===================================")
        print("          IMPORT FAILED")
        print("===================================")

        print(f"\nError: {error}")
        print("\nAll changes have been rolled back.")

        raise

    finally:

        connection.close()


# Main

if __name__ == "__main__":
    populate_database()

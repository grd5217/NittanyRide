import sqlite3
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATABASE_PATH = os.path.join(
  BASE_DIR, 
  'database', 
  'NittanyRide.db'
)

def get_db_connection():
  connection = sqlite3.connect(DATABASE_PATH)

  connection.row_factory = sqlite3.Row

  connection.execute("PRAGMA foreign_keys = ON");

  return connection

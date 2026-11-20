import db

#test db connection 
conn = db.get_db_connection()
print(conn.execute("PRAGMA database_list;").fetchall())

tables = conn.execute("""
    SELECT name
    FROM sqlite_master
    WHERE type = 'table';
""").fetchall()

for table in tables:
    print(table["name"])



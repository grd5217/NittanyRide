#testing file for password hash

from database import db

conn = db.get_db_connection()
cur = conn.cursor()

user = cur.execute('''
    SELECT FullName, Password
    FROM User
    WHERE UserID = ?
''', ("alex.rider@example.com",)).fetchone()

if user:
    print(user['FullName'], user["Password"])
else:
    print("User not found.")

conn.close()


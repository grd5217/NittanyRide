

# DO NOT RUN MORE THAN ONCE, ALREADY RAN IT


"""
from database import db
from werkzeug.security import generate_password_hash

conn = db.get_db_connection()
cur = conn.cursor()

users = cur.execute(''' 
  select UserID, Password
  from User  
''').fetchall()

for user in users:
  hashed_password = generate_password_hash(user['Password'])

  cur.execute('''
    Update User
    set Password = ?
    where UserID = ?
  ''', [hashed_password, user["UserID"]])

conn.commit()
conn.close()

"""
from flask import Flask, render_template, request, redirect, url_for
from werkzeug.security import generate_password_hash, check_password_hash


from database import db 

app = Flask(__name__)

def verify_password(userid, input_password, conn):
  cur = conn.cursor()

  user = cur.execute('''
    select *
    from User
    where UserID = ?
  ''', [userid]).fetchone()

  if user:
    return check_password_hash(user['Password'], input_password)
  else:
    return False

#checks if a user is in a given table.  used to redirect to the users corresponding dashboard
def is_user_in_table(userid, table, conn):
  allowed_tables = ['Driver', 'Rider', 'SupportStaff']
  if table not in allowed_tables:
    raise ValueError('Invalid table name')

  cur = conn.cursor()
  result = cur.execute(f'''
    select * 
    from "{table}"
    where UserID = ?
  ''', [userid]).fetchone()

  return result is not None


#login screen
@app.route('/', methods=['GET', 'POST'])
def home():
  error = None

  #get user login info
  if request.method == 'POST':
    email = request.form['email']
    password = request.form['password']

    #open db connection
    conn = db.get_db_connection()
    cur = conn.cursor()

    #compare input against table
    user = cur.execute('''
      select * 
      from User
      where UserID = ?''', [email]).fetchone()

    if user and verify_password(email, password, conn):   #password correct
      # check if account inactive before allowing login
      if user["AccountStatus"] != 'active':
        error = "Account deactivated"
        print("account deactive")

      else:   #account active, accept login
        print("accepted login")
        if is_user_in_table(email, 'Driver', conn):
          return redirect(url_for('driver_dashboard'))
        if is_user_in_table(email, 'Rider', conn):
          return redirect(url_for('rider_dashboard'))
        if is_user_in_table(email, 'SupportStaff', conn):
          return redirect(url_for('support_dashboard'))

    else: #login not accepted
      error = "Email or password is incorrect."
      print('login failed')

    conn.close()
  return render_template('login.html', error=error)


#rider dashboard screen
@app.route('/rider')
def rider_dashboard():
  return render_template('rider_dashboard.html')

#driver dashboard screen
@app.route('/driver')
def driver_dashboard():
  return render_template('driver_dashboard.html')

#support staff dashboard screen
@app.route('/support')
def support_dashboard():
  return render_template('support_dashboard.html')

#run app
if __name__ == '__main__':
  app.run(debug=True)
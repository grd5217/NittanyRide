## Prerequisites

Before running the application, make sure you have installed:

- Python 3
- Visual Studio Code
- MySQL / SQLite

## Important Notes
Always activate your .venv environment before working on NittanyRide.
.venv should not be committed to the repository.  It is safe to delete, and easy to reinstall everything. 

## 1. Navigate to the Project Directory

Open a terminal and navigate to the src folder:

cd src

## 2. Create a Virtual Environment

Create a virtual environment to keep project dependencies separate:

python -m venv .venv

or

py -m venv .venv

## 3. Activate the Virtual Environment

Windows (Command Prompt):

.venv\Scripts\activate.ps1

Mac/Linux:

source .venv/bin/activate

Once activated, you should see (.venv) at the beginning of your terminal prompt.

## 4. Install Dependencies

Make sure your virtual environment is activated.

Install all required packages:

pip install flask

or

python -m pip install flask

## 5. Run the Flask Application

In the terminal, ensure that you are still in the venv.  Run:

python app.py

or 

py app.py

If successful, Flask will display a message similar to:

* Running on http://127.0.0.1:5000

Open your browser and navigate to:

http://127.0.0.1:5000

## 6. Stop the Application

To stop the Flask development server, press:

CTRL + C

## 7. Deactivate the Virtual Environment

When finished working on the project, run:

deactivate



## Quick setup for Windows (paste into terminal and run):
cd src

py -m venv .venv

.venv\Scripts\activate.ps1

python -m pip install flask

py app.py


### OR


cd src

python -m venv .venv

.venv\Scripts\activate.ps1

pip install flask

python app.py

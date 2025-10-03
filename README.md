# purplehire
PurpleHire is a job matching platform that connects candidates with employers. The backend provides APIs for job search, application management, skill matching, and resume analysis.



Database Setup
Prerequisites

PostgreSQL 12+ installed
Python 3.8+ installed
pip package manager

Step 1: Create Database
bash# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE phire_db;

# Connect to the database
\c phire_db
Step 2: Run Schema Script
bash# Copy the schema SQL file and run it
psql -U postgres -d phire_db -f schema.sql
Or directly in psql:
sql\i /path/to/schema.sql
Step 3: Verify Installation
sql-- Check if tables were created
\dt

-- Check if view was created
\dv

-- Check if function was created
\df search_jobs

-- Verify sample skills were inserted
SELECT COUNT(*) FROM skills;
Expected output: 12+ tables, 1 view, 1 function, 12 skills

Backend Setup
Step 1: Install Dependencies
bashpip install flask flask-cors psycopg2-binary pyjwt werkzeug



Step 2: Configure Database Connection
Edit app.py and update the database configuration:
pythonDATABASE_CONFIG = {
    'host': 'localhost',
    'database': 'phire_db',
    'user': 'your_postgres_username',
    'password': 'your_postgres_password',
    'port': 5432
}



Step 3: Update Secret Key
pythonapp.config['SECRET_KEY'] = 'your-very-secure-secret-key-here'



Step 4: Run the Application
bashpython app.py
The API will be available at http://localhost:5000



Step 5: Test Health Check
bashcurl http://localhost:5000/health
Expected response:
json{
  "status": "healthy",
  "message": "Job Search API is running"
}

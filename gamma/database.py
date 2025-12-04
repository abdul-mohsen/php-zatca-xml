import os 
from dotenv import load_dotenv

from sqlalchemy import create_engine, text
# Load environment variables from .env file
load_dotenv()
# Read database credentials from environment variables
username = os.getenv('DBUSER')
password = os.getenv('PASSWORD')
host = os.getenv('HOST')
database = os.getenv('DBNAME')

# Create the connection string
connection_string = f'mysql+mysqlconnector://{username}:{password}@{host}/{database}'
# Alternatively, if using PyMySQL, use:
# connection_string = f'mysql+pymysql://{username}:{password}@{host}/{database}'
# Create the SQLAlchemy engine
engine = create_engine(connection_string)

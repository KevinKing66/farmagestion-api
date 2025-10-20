from src.config.setting import settings


USER = "farmagestion_user"
PASSWORD = "password123"
DB_NAME = "farmagestion"
PORT = 3306
DATABASE_URL = f"mysql+mysqlconnector://{USER}:{PASSWORD}@localhost:{PORT}/{DB_NAME}"


import mysql.connector

def get_connection():
    connection = mysql.connector.connect(
        host=settings.DATABASE_HOST,
        port=settings.DATABASE_PORT,
        user=settings.DATABASE_USER,
        password=settings.DATABASE_PASSWORD,
        database=settings.DATABASE_NAME,
    )
    return connection
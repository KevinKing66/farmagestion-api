CREATE USER 'farmagestion_user'@'localhost' IDENTIFIED BY 'password123';

GRANT ALL PRIVILEGES ON farmagestion.* TO 'farmagestion_user'@'localhost';

FLUSH PRIVILEGES;

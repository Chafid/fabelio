# Fabelio Price Monitoring App

This is a simple web app application to retrieve product data from Fabelio website and display it on the browser.
The app consist of:
 - add.html
  - add_product.pl
  - list_product.pl
  - get_details.pl
  - update_price.pl

 The retrive data is stored into a table called products in a mysql database. 
 The database configuration is in the config/db.conf file. Please change it to your database configuration to deploy.
 update_price.pl script is to retrieve the new price and update it to the database every hour. 
 
  ## Deploying the application
  1. Make sure the following is installed:
    - perl
    - mysql
    - DBD::mysql module for perl
    - apache2
  2. go the /var/www directory and copy html and cgi-bin directory there
  3. create a database called fabeliodb
  4. create the table by executing the products.sql
  5. execute chmod 755 on the app executables
  6. Set schedule in crontab to run update_price.pl every minute
  6. Go to http://localhost/fabelio-test/add.html to start
  
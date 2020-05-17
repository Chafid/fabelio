# Fabelio Price Monitoring App

This is a simple web app application to retrieve product data from Fabelio website and display it on the browser.
The app consist of:
 - add.html
 - add_product
 - list_product
 - get_details

 The retrive data is stored into a table called products in a mysql database. 
 The database configuration is in the config/db.conf file. Please change it to your database configuration to deploy.

 The source code of the application is in the perl script:
  - add_product.pl
  - list_product.pl
  - get_details.pl

  To reduce the need of installing dependencies, the perl scripts was compiled into executables along with the library.

  ## Deploying the application
  1. Make sure apache2 and mysql is installed
  2. go the /var/www directory and copy html and cgi-bin directory there
  3. create a database called fabeliodb
  4. create the table by executing the products.sql

  
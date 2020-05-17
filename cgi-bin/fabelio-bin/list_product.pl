#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use LWP;
use HTTP::Request;


#read product from database

my %dbConfig = readConfig();
my $dbName = $dbConfig{"dbname"};
my $username = $dbConfig{"username"};
my $password = $dbConfig{"password"};
my $host = $dbConfig{"host"};

print "Content-type: text/html\n\n";
print "<HTML><HEAD><TITLE>"; 
print "Product List\n";
print "</TITLE>";
print "<style> table, th, td { border: 10px solid white; } </style>";
print "</HEAD><body bgcolor=#FFFFFF>\n";
print "<h1>PRODUCT LIST</h1><br>";

my $myConnection = DBI->connect("DBI:mysql:$dbName:$host", $username, $password);


my $sql_query = "select name, products_id from products";

my $stmt = $myConnection->prepare($sql_query);
$stmt->execute() || die ("Error query to database");

while(my @row = $stmt->fetchrow_array()){
    my $productName = substr($row[0], 1);
    chop($productName);
    my $url = "http://localhost/cgi-bin/fabelio-bin/get_details.pl?productid=" . $row[1];
    print "<a href=$url>$productName</a><br><br>";
}  
$stmt->finish();
$myConnection->disconnect();
print "<br><p><a href=http://localhost/fabelio-test/add.html>Add product</a></p>";
print "\n</BODY></HTML>";


sub readConfig {
    my %dbConfig;
    my $configPath = "./config/db.conf";
    if (open(my $fh, '<:encoding(UTF-8)', $configPath)) {
        foreach my $line (<$fh>) {
            my ($key, $value) = split (/=/, $line);
            chomp $value;
            $dbConfig{$key} = $value;
        }
    }
    else {
        warn "DB config is not found\n";
    }
    return %dbConfig;
}
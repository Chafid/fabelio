#!/usr/bin/perl

use strict;
use warnings;
use DBI;

use CGI qw(:standard);

my $query = new CGI;

my $productname = $query->param('productid');

my %dbConfig = readConfig();
my $dbName = $dbConfig{"dbname"};
my $username = $dbConfig{"username"};
my $password = $dbConfig{"password"};
my $host = $dbConfig{"host"};

my $get_detail_query = "select name, `desc`, price, image from products where products_id = ?";

my $myConnection = DBI->connect("DBI:mysql:$dbName:$host", $username, $password);
my $stmt = $myConnection->prepare($get_detail_query);

$stmt->bind_param(1, $productname);

$stmt->execute() or die "execution failed: $myConnection->errstr()"; 

my ($name, $desc, $price, $image) = $stmt->fetchrow();

print "Content-type: text/html\n\n";
print "<HTML><HEAD><TITLE>";    

print "Product Detail\n";
print "</TITLE>";
print "<style> table, th, td { border: 10px solid white; } </style>";
print "</HEAD><body bgcolor=#FFFFFF>\n";
print "<h1>PRODUCT DETAIL</h1><br>";
print "<table style=width:70%>";
print "<tr><td><p>Product Name:<br>$name</p></td></tr>";
print "<tr><td><p>Product Desc:<br>$desc</td></p></tr>";
print "<tr><td><p>Price:<br>Rp $price</td></p></tr>";
print "<tr><td><img src=$image></td></tr>";
print "</table>";
print "<p><a href=http://localhost/fabelio-test/add.html>Add more product</a></p>";
print "<p><a href=http://localhost/cgi-bin/fabelio-bin/list_produc.plt>Product list</a></p>";
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
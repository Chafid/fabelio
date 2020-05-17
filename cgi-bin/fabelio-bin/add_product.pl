#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use LWP;
use HTTP::Request;
use HTML::TokeParser;
use Data::Dumper;



#parse input from form
my %formdata;

&parsing;

#my $url = "https://fabelio.com/ip/meja-makan-cessi-new.html";
my $url = $formdata{'producturl'}; 

addtoDB();


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

sub getDataFromURL {
    #print "URL: $url\n";
    my $content;
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0');
    my $response = $ua->get($url);    
    $content = $response->content;
    #print "$content\n";
    return $content;
}

sub parseContent {
    no warnings;
    my $content = $_[0];
    my $token;
    my %hashContent;
    my $stream = HTML::TokeParser->new(\$content);

    while ($token = $stream->get_token) {
        next if ($token->[1] ne 'meta property' && $token->[0] ne 'S');  
        if ($token->[2]{'property'} eq 'product:price:amount') {
            $hashContent{'price'} = $token->[2]{content};
        }
        elsif ($token->[2]{property} eq 'og:title') {
            $hashContent{'title'} = $token->[2]{content};
        }        
        elsif ($token->[2]{property} eq 'og:image') {
            $hashContent{'image'} = $token->[2]{content};
        }

    }

    $stream = HTML::TokeParser->new(\$content);
    while (my $div = $stream->get_tag('div')) {
        my $id = $div->[1]{'id'};
        next unless defined($id) and $id eq 'description';
        $hashContent{'desc'} = $stream->get_text('/div');

    }

    return %hashContent;

}

sub addtoDB  {
    my %dbConfig = readConfig();
    my $dbName = $dbConfig{"dbname"};
    my $username = $dbConfig{"username"};
    my $password = $dbConfig{"password"};
    my $host = $dbConfig{"host"};

    my $myConnection = DBI->connect("DBI:mysql:$dbName:$host", $username, $password);

    my $content = getDataFromURL();

    my %hashResult = parseContent($content);
    
    my $name = $hashResult{'title'};
    my $image = $hashResult{'image'};
    my $desc = $hashResult{'desc'};
    my $price = $hashResult{'price'};

 
    #display added product
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
    print "<p><a href=http://localhost/cgi-bin/fabelio-bin/list_product.pl>Product list</a></p>";
    print "\n</BODY></HTML>";

    $name = '"' . $name . '"';
 
    my $sql_insert = "insert into products (name, price, `desc`, image) values (?,?,?,?);";

    my $stmt = $myConnection->prepare($sql_insert);
    $stmt->execute($name, $price, $desc, $image) || die ("Error insert to database");
    $stmt->finish();
    $myConnection->disconnect();
}

sub parsing {
    my (@pairs, $buffer);
    if ($ENV{'REQUEST_METHOD'} eq 'GET') {
        @pairs = split(/&/, $ENV{'QUERY_STRING'});
    } elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
        read (STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
        @pairs = split(/&/, $buffer);
    } else {
        print "Content-type: text/html\n\n";
        print "<P>Use Post or Get";
    }

    foreach my $pair (@pairs) {
        my ($key, $value) = split (/=/, $pair);
        $key =~ tr/+/ /;
        $key =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

        $value =~s/<!--(.|\n)*-->//g;

        if ($formdata{$key}) {
                $formdata{$key} .= ", $value";
        } else {
                $formdata{$key} = $value;
        }
    }
  return;
}

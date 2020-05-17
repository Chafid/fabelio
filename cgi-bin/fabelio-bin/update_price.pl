#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use LWP;
use HTTP::Request;
use POSIX 'strftime';
use HTML::TokeParser;
use Data::Dumper;

#read product from database

my %dbConfig = readConfig();
my $dbName = $dbConfig{"dbname"};
my $username = $dbConfig{"username"};
my $password = $dbConfig{"password"};
my $host = $dbConfig{"host"};

my $url;

#get list of urls from database.
my $myConnection = DBI->connect("DBI:mysql:$dbName:$host", $username, $password);

my $sql_query = "select url, UNIX_TIMESTAMP(insert_time) from products";

my $stmt = $myConnection->prepare($sql_query);

$stmt->execute() || die $stmt->errstr;

print $stmt->execute(), "\n";
#print $stmt->fetchrow_array(), "\n";

my $i = 0;
my (@timestamp, @url_array);
while(my @row = $stmt->fetchrow_array()){
    $url_array[$i] = $row[0];
    $timestamp[$i] = $row[1];
    ++$i;
}

print @url_array , "\n";

$i = 0;
my $lengtharray = @url_array;


while ($i < $lengtharray) {
    my $current_time = time();
    $url = $url_array[$i];
    print "current time: $current_time\n";
    print "timestamp: $timestamp[$i]\n";
    if ($current_time - $timestamp[$i] >= 3600) {
        #update price in table
        my $content = getDataFromURL();
        my %hashResult = parseContent($content);
    
        my $name = $hashResult{'title'};
        my $price = $hashResult{'price'};

        $name = '"' . $name . '"';

        my $sql_update = "update products set price = ?, insert_time = ? where name = ?";

        my $new_insert_time = strftime '%Y-%m-%d %H:%M:%S', localtime $current_time;

        $stmt = $myConnection->prepare($sql_update);
        $stmt->bind_param(1, $price);
        $stmt->bind_param(2, $new_insert_time);
        $stmt->bind_param(3, $name);

        print "price: $price\n";
        print "name: $name\n";
        print "new time: $new_insert_time\n";


        $stmt->execute() || die ("Error update to database");
        $stmt->finish();
    }
    ++$i;
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

sub getDataFromURL {
    my $content;
    my $ua = LWP::UserAgent->new();
    $ua->agent('Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0');
    my $response = $ua->get($url);    
    $content = $response->content;

    return $content;
}

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
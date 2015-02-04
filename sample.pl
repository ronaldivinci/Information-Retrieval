#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 5 



use LWP::Simple;
use LWP::UserAgent;
use HTML::LinkExtor;
use HTTP::Request;
use HTTP::Response;
use CAM::PDF;
use CAM::PDF::PageText;
use List::MoreUtils;



print"You may enter a query for word(s) you would like to retrieve DF, TF for:"; 
my $query = <>; 
chomp($query); 
my @wordsToQuery = split(' ', $query); 

foreach (@wordsToQuery){
	print "$_\n"; 
}

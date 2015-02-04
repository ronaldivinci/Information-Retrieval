#!/usr/bin/perl


use diagnostics;
use LWP::Simple;
use LWP::UserAgent;
use HTML::LinkExtor;
use HTTP::Request;
use HTTP::Response;
use CAM::PDF;
use CAM::PDF::PageText;
use List::MoreUtils;
use Storable;


my @docs;  
my $dir = "/usr/lib/cgi-bin/corpus";
my $url = "/usr/lib/cgi-bin/corpus/urls.txt";      	#read url txt file to create hash for inverted index
my $file = "/usr/lib/cgi-bin/urls";			# save hash into urls



#traverse through all documents, manifest the hash to store frequency of words for each documents 
#------------------------------------------------------------------------------------------------
my %urls; 

open(INPUT,"<$url") or die "Could not open document $document: $!";
	 
while(<INPUT>) {
  my @line = (split('\|', $_));
  #print "$line[0] : $line[1]\n"; 
  my $index = int($line[0]) + 1; 
  $urls{$index} = $line[1]; 
	
}

close(INPUT);

store \%urls, $file; 

=begin
	while(<INPUT>) {
		for my $word (split('\|', $_)) {
			print "$word\n";  
		}
	}
=cut

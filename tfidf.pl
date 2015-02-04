#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 6

# i have to run this to set up variables as instructed when using Porter Stemmer


#----------------------------------------------------------------------------------------------------#
# I will be feeding into this module of our assignment the DIR created from the previous module.
# And then creating an inverted index which I will store in a hash map (%count)
#----------------------------------------------------------------------------------------------------#


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

my $inverted_index_file = "/usr/lib/cgi-bin/inverted_Index";              	   
my $doc_length_file = "/usr/lib/cgi-bin/doc_Length";
my $updatedhashfile = "/usr/lib/cgi-bin/urlsupdated";
my $stopwordfile = "/usr/lib/cgi-bin/stopwords";

my %counts = %{ retrieve($inverted_index_file) }; 
my %docLength = %{ retrieve($doc_length_file) }; 
my %urlsupdated = %{ retrieve($updatedhashfile) }; 
my %stopwordsHash = %{ retrieve($stopwordfile) }; 


foreach my $word (sort keys %inverted_index_file) {
		my $idF = 0; 
		
		foreach my $document (sort keys %counts){
			if($counts{$document}{$word} > 0){
				my $txt = substr $urlsupdated{$document}, 0, 40;
				print "<tr><td></td><td> <a href=$urlsupdated{$document}> $txt: </a> $counts{$document}{$word} </td>";
				
				$idF += 1;
			}
			
		}
		$idF = int($docSize / $idF);
		$idF = &log10($idF); 
		
		print "<td> DF: $idF </td></tr>";
	


}

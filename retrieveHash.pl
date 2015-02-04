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




#traverse through all documents, manifest the hash to store frequency of words for each documents 
#------------------------------------------------------------------------------------------------
my $hashfile = "/usr/lib/cgi-bin/urls";
my %urls = %{ retrieve($hashfile) }; 

my $updatedhashfile = "/usr/lib/cgi-bin/urlsupdated";
my $dir = "/usr/lib/cgi-bin/corpus"; #use to recreate another more useful hash
my %urlsupdated; 

#-------------------Push the list of all our documents into this array @docs----------------------#
foreach my $FP (glob("$dir/*.txt")) {	
	push @docs, $FP; 		 
}

unless(open WP, '>>', 'hashurl.txt'){        #write to a document since terminal cannot display entire lines
			die "Unable to create wordFrequency.txt";
}

foreach my $doc (@docs){
  my $docNum = $doc; 
  $docNum =~ tr/0-9/ /c;
  $docNum =~ s/\s//g; 
  $docNum = int($docNum); 
  #$docNUm = int($docNum); 
  print WP $docNum."\n"; 
  $urlsupdated{$doc} = $urls{$docNum};                      #using one hash to build another. 
}

store \%urlsupdated, $updatedhashfile; 

#store \%urls, "\home\vince\Documents\IRHW";
foreach (keys %urlsupdated){
	print WP $_." : ".$urlsupdated{$_}."\n";
}

close(WP); 

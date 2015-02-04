#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 6

# i have to run this to set up variables as instructed when using Porter Stemmer
initialise(); 

#----------------------------------------------------------------------------------------------------#
# I will be feeding into this module of our assignment the DIR created from the previous module.
# And then creating an inverted index which I will store in a hash map (%count)
#----------------------------------------------------------------------------------------------------#


#use diagnostics;
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
my $inverted_index_file = "/usr/lib/cgi-bin/inverted_Index";              
my $doc_length_file = "/usr/lib/cgi-bin/doc_Length";

#print "Please enter the directory containing the list of preprocessed documents documents: ";
#my $dir = <>; 
#chomp ($dir); 


#-------------------------First store stop words in an array
my $url = "http://www.cs.memphis.edu/~vrus/teaching/ir-websearch/papers/english.stopwords.txt"; 
my @stopwords; 
 
my $content = get $url || die "Couldn't get $url" ;
$content =~ tr/A-Z/a-z/;               # convert to lowercase

foreach my $word (split /\n/, $content){  # for each item in the content split by new line 
	              			  # i dont want it to consider the single alphabets or else output comes out bad! 
		push @stopwords, $word;
}

%stopwordsHash=();                        # using a hash will make it quicker for me to search and delete stop words
foreach my $word (@stopwords){
   $stopwordsHash{$word}=1;
}
#--------------------------end of portion pertaining to storing stop words------------------------#


#-------------------Push the list of all our documents into this array @docs----------------------#
foreach my $FP (glob("$dir/*.txt")) {	
	push @docs, $FP; 		 
}

$docSize = @docs; 
#We will use this Hash to create a hash map
my %counts;
my %docLength; 


#traverse through all documents, manifest the hash to store frequency of words for each documents 
#------------------------------------------------------------------------------------------------
foreach my $document (@docs) {
	open(INPUT,"<$document") or die "Could not open document $document: $!";
	
	my $len = 0; 
	while(<INPUT>) {
		for my $word (split(' ', $_)) {
			$counts{$document}{$word}++;
			$len++; 
		}
	}
	$docLength {$document} = $len;
	close(INPUT);
	 
}

store \%counts, $inverted_index_file; 

store \%docLength, $doc_length_file; 

foreach (sort keys %docLength){
	unless(open WINPUT, '>>', 'idfResult.txt'){        #write to a document since terminal cannot display entire lines
			die "Unable to create wordFrequency.txt";
	}
	print WINPUT "$_ : $docLength{$_}\n\n"; 
}
close(WINPUT);

=begin
#-----------Prompt user for input to display output-----------------#
print"You may enter a query for word(s) you would like to retrieve DF, TF for:"; 
my $query = <>; 
chomp ($query); 
$query =~ tr/A-Za-z/ /cs;          	#remove anything that isnt a word
$query =~ tr/[A-Z]/[a-z]/;		#remove uppercase
$query = &DeleteStopWords($query); 
$query = &StemDocument($query); 


my @wordsToQuery = split(' ', $query); 
&RetrieveInvertedIndex(@wordsToQuery); 


sub RetrieveInvertedIndex{
	#print counts for each document, and total
	my @words = @_; 
	 
	foreach my $word (@words) {
		my $dF = 0;
		
		unless(open WINPUT, '>>', 'idfResult.txt'){        #write to a document since terminal cannot display entire lines
			die "Unable to create wordFrequency.txt"; 
		}
		print "======$word======\n";
		printf WINPUT "%-40s", "$word";
		my $totPerWord = 0;
		foreach my $document (sort keys %counts){
			if($counts{$document}{$word} > 0){
				print "$document, $counts{$document}{$word}\n";
				printf WINPUT "%-8s", "$document, $counts{$document}{$word}\n";
		
				$dF += 1;                                #-------------   $totalPerWord = $counts{$document}{$word}          was used to ad up all frequency
			}
			
		}
		print $dF."\n"; 
		print int($docSize/$dF)."\n";
		
		$dF = int($docSize / $dF);
		$dF = &log10($dF); 
		print "\tDF: $dF over $docSize\n\n";
		printf WINPUT "%-8s\n", "\tDF: $dF\n\n";

	}
}	

close(WINPUT);


#---------------Use to get log base 10

sub log10(){
    my $n = shift;
    return log($n)/log(10);
 }

#------------------------use to remove stop words from query-----------#
sub DeleteStopWords(){
   $fileContent=shift;
   @fileContentArray=split(" ", $fileContent);
   $fileContent="";
   foreach $word(@fileContentArray){
      if ($stopwordsHash{$word}>0){
           
      }
      else {
         $fileContent= $fileContent." ".$word;
      }
   }
   return $fileContent;
  }

 
 #-------------------------use to stem the words in the query to match the words in preprocessed documents-------------#
  sub StemDocument(){
  
   $fileContent = shift;
   @words = split(" ", $fileContent );

   # loop through all words
   $stemmedDoc="";
   foreach $word (@words) {

		#if it is a valid word
		if ( $word =~ /\w+/ ) {
			$word = stem($word);
			$stemmedDoc=$stemmedDoc.$word." ";
		}
	}

   return $stemmedDoc;

}

=cut

# Porter stemmer in Perl. Few comments, but it's easy to follow against the rules in the original
# paper, in
#
#   Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
#   no. 3, pp 130-137,
#
# see also http://www.tartarus.org/~martin/PorterStemmer

# Release 1

local %step2list;
local %step3list;
local ($c, $v, $C, $V, $mgr0, $meq1, $mgr1, $_v);


sub stem
{  my ($stem, $suffix, $firstch);
   my $w = shift;
   if (length($w) < 3) { return $w; } # length at least 3
   # now map initial y to Y so that the patterns never treat it as vowel:
   $w =~ /^./; $firstch = $&;
   if ($firstch =~ /^y/) { $w = ucfirst $w; }

   # Step 1a
   if ($w =~ /(ss|i)es$/) { $w=$`.$1; }
   elsif ($w =~ /([^s])s$/) { $w=$`.$1; }
   # Step 1b
   if ($w =~ /eed$/) { if ($` =~ /$mgr0/o) { chop($w); } }
   elsif ($w =~ /(ed|ing)$/)
   {  $stem = $`;
      if ($stem =~ /$_v/o)
      {  $w = $stem;
         if ($w =~ /(at|bl|iz)$/) { $w .= "e"; }
         elsif ($w =~ /([^aeiouylsz])\1$/) { chop($w); }
         elsif ($w =~ /^${C}${v}[^aeiouwxy]$/o) { $w .= "e"; }
      }
   }
   # Step 1c
   if ($w =~ /y$/) { $stem = $`; if ($stem =~ /$_v/o) { $w = $stem."i"; } }

   # Step 2
   if ($w =~ /(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/)
   { $stem = $`; $suffix = $1;
     if ($stem =~ /$mgr0/o) { $w = $stem . $step2list{$suffix}; }
   }

   # Step 3

   if ($w =~ /(icate|ative|alize|iciti|ical|ful|ness)$/)
   { $stem = $`; $suffix = $1;
     if ($stem =~ /$mgr0/o) { $w = $stem . $step3list{$suffix}; }
   }

   # Step 4

   if ($w =~ /(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/)
   { $stem = $`; if ($stem =~ /$mgr1/o) { $w = $stem; } }
   elsif ($w =~ /(s|t)(ion)$/)
   { $stem = $` . $1; if ($stem =~ /$mgr1/o) { $w = $stem; } }


   #  Step 5

   if ($w =~ /e$/)
   { $stem = $`;
     if ($stem =~ /$mgr1/o or
         ($stem =~ /$meq1/o and not $stem =~ /^${C}${v}[^aeiouwxy]$/o))
        { $w = $stem; }
   }
   if ($w =~ /ll$/ and $w =~ /$mgr1/o) { chop($w); }

   # and turn initial Y back to y
   if ($firstch =~ /^y/) { $w = lcfirst $w; }
   return $w;
}

sub initialise {

   %step2list =
   ( 'ational'=>'ate', 'tional'=>'tion', 'enci'=>'ence', 'anci'=>'ance', 'izer'=>'ize', 'bli'=>'ble',
     'alli'=>'al', 'entli'=>'ent', 'eli'=>'e', 'ousli'=>'ous', 'ization'=>'ize', 'ation'=>'ate',
     'ator'=>'ate', 'alism'=>'al', 'iveness'=>'ive', 'fulness'=>'ful', 'ousness'=>'ous', 'aliti'=>'al',
     'iviti'=>'ive', 'biliti'=>'ble', 'logi'=>'log');

   %step3list =
   ('icate'=>'ic', 'ative'=>'', 'alize'=>'al', 'iciti'=>'ic', 'ical'=>'ic', 'ful'=>'', 'ness'=>'');


   $c =    "[^aeiou]";          # consonant
   $v =    "[aeiouy]";          # vowel
   $C =    "${c}[^aeiouy]*";    # consonant sequence
   $V =    "${v}[aeiou]*";      # vowel sequence

   $mgr0 = "^(${C})?${V}${C}";               # [C]VC... is m>0
   $meq1 = "^(${C})?${V}${C}(${V})?" . '$';  # [C]VC[V] is m=1
   $mgr1 = "^(${C})?${V}${C}${V}${C}";       # [C]VCVC... is m>1
   $_v   = "^(${C})?${v}";                   # vowel in stem

}

# that's the definition. Run initialise() to set things up, then stem($word) to stem $word, as here:



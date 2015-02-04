#!/usr/bin/perl

# The Processes Query Program  -  engine.cgi

# This includes a library module written by Steven Brenner
# that allows the use of a nice function called "ReadParse"
# that is now part of the CGI Perl Module.

use CGI qw(:cgi-lib :standard);
# i have to run this to set up variables as instructed when using Porter Stemmer
initialise(); 



# The function returns a hash of the input from a "CGI form".  The
# hash keys are the variable names identified in that original form.
# The hash values contain the information submitted by the user.

&ReadParse(%in);  



# The next routine attempts to solve a serious security problem in this program.  If the user enters the year, followed by a 
# semi-colon, another UNIX command can be put on the same line. Potentially evil things could happen!  So we scan to see if 
# there is a semi colon if there is we display another page.

if ( $in{"query"} =~ ";") 
{
	print <<ERR;
Content-type: text/html

<HTML>
<BODY BGCOLOR=WHITE TEXT=BLACK>
<H3>Hello, Your query includes semi colon SORRY!! go back.<br>
</BODY>
</HTML>

ERR
}

# If the input is "OK", then the "else" 
else{

# The next few lines concatenates month and year into a single string
# and use "cal" to generate both monthly and yearly calendars.

use LWP::Simple;
use LWP::UserAgent;
use HTML::LinkExtor;
use HTTP::Request;
use HTTP::Response;
use CAM::PDF;
use CAM::PDF::PageText;
use List::MoreUtils;


my @docs;  
my $dir = '/home/vince/Documents/IRHW/corpus';

#-------------------------First store stop words in an array---------------------------------------#
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
#--------------------------end of portion pertaining to storing stop words-------------------------#



#-------------------Push the list of all our documents into this array @docs-----------------------#
foreach my $FP (glob("$dir/*.txt")) {	
	push @docs, $FP; 		 
}

#We will use this Hash to create a hash map
my %counts;


#traverse through all documents, manifest the hash to store frequency of words for each documents 
#------------------------------------------------------------------------------------------------
for my $document (@docs) {
	open(INPUT,"<$document") or die "Could not open document $document: $!";
	
	while(<INPUT>) {
		for my $word (split(' ', $_)) {
			$counts{$document}{$word}++;
		}
	}
	close(INPUT);
}


#-----------split user input into array and pass to function-----------------# 
my $query = $in{"query"}; 

$query =~ tr/A-Za-z/ /cs;          	#remove anything that isnt a word
$query =~ tr/[A-Z]/[a-z]/;		#remove uppercase
$query = &DeleteStopWords($query); 
$query = &StemDocument($query);

my @wordsToQuery = split(' ', $query); 

&RetrieveInvertedIndex(@wordsToQuery); 




sub RetrieveInvertedIndex{
	#print counts for each document, and total
	my @words = @_; 


print<<EOF;
Content-type: text/html


<!DOCTYPE html>
<head>
<style>
body{
    text-align: center;
    background: url("http://i.imgur.com/MVCOmnP.jpg");
    background-size: cover; 
    background-position: center center; 
    background-repeat: no-repeat; 
    background-attachment: fixed; 
    color: black;
    font-family: Helvetica; 
}
p{
    font-size: 18px;
}
h6{
    color: black
    font-size: 24px
}
input{
    border:0;
    padding: 12px;
    font-size: 18px; 
}
input[type="submit"]{
    background: limegreen;
    color:black; 
}
</style>
</head>
<body>
<img src="http://i.imgur.com/sAe6mGP.jpg" height="250" width="250">
<h1>Vincent Nkawu</h1>
EOF

	foreach my $word (@words) {
		my dF = 0; 
		print "<p> $word </p>";
		
		my $totPerWord = 0;
		foreach my $document (sort keys %counts){
			if($counts{$document}{$word} > 0){
				
				print "<p> $document, $counts{$document}{$word} </p>";
				
				$dF += 1;
			}
		}
		print "<p> DF: $dF </p>";
	}

print "</BODY>\n";
print "</HTML>\n";

}	

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



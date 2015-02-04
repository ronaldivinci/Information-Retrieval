#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 5 


use diagnostics;
use LWP::Simple;
use LWP::UserAgent;
use HTML::LinkExtor;
use HTTP::Request;
use HTTP::Response;
use CAM::PDF;
use CAM::PDF::PageText;
use List::MoreUtils;



# i have to run this to set up variables as instructed when using Porter Stemmer
initialise(); 


$currDocuments=0;
$minToken=50;
$maxDocument=10000;
$badPDF = "memphis.edu/admissions/pdfs"; 
$badPDF2 = "memphis.edu/gradschool/pdfs"; 



my $seedUrl="http://www.memphis.edu";
my $htmlParser = HTML::LinkExtor->new(undef, $seedUrl);# initialize object to extract all links from the page of base url.
$htmlParser->parse(get($seedUrl))->eof;
@seedlinks = $htmlParser->links;



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
#--------------------------end of portion pertaining to storing stop words-------------------------




#----------------------initialize the queueLinks and links with homepage links----------------------
%links=();                                #links contains all the links: visited or yet to be visited
@queueLinks;                              #queueLinks to store links as they are crawled so we can visit later

&ManageUpdateLinks(@seedlinks);


#----------------------Create new directory --------------------------------------------------------
my $newdir = "/home/vince/Documents/IRHW/crawled_docs";
unless(-e $newdir or mkdir $newdir) {
	die "Unable to create $newdir";
}
chdir("crawled_docs");    #now we are in "C:\Documents" directory 






#----------------------------get the contents of home page and process it---------------------------
&preprocessFile($seedUrl);

#while we have less than 10,000 documents
while(@queueLinks && ($currDocuments<=$maxDocument)) {       
	
	$nextLink= shift @queueLinks;
	select(undef, undef, undef, 1 );
	
	
	if($nextLink=~ /(\.html|\.txt|\.htm|\.pdf)$/ ){
		#print "\n $nextLink \n";
		if($nextLink=~ /(\.txt)$/ ){
			&preprocessFile($nextLink);
			next;
		}
		if($nextLink=~ /(\.pdf)$/ ){							# (index($nextLink, $badPDF) == -1)) Cool for checking substring
			if(CAM::PDF->new(get $nextLink)->getPageContentTree(1) != undef){      	# my crawler kept getting kicked out when this was undef. I am guessing the webmaster may have some security feature causing memphis.edu domain to do this when being crawled.
				&preprocessFile($nextLink);
				print "\n=Pdf FILE Printed=\n";
				next;
			}
		}
		if($nextLink=~ /(\.html|\.htm)$/ ){
			&preprocessFile($nextLink);
			
			$html_Parser = HTML::LinkExtor->new(undef, $nextLink);
			$html_Parser->parse(get($nextLink))->eof;
			@linksoflink = $html_Parser->links;
			
			&ManageUpdateLinks(@linksoflink);
			print scalar(@queueLinks)." links have been added to queueLinks\n";
			next;
		}		
	}
	else {
		next;
	}
	
}

#print the links
 print "All crawled Links\n";

 foreach $key (keys %links){
 	print "$key : $links{$key}  \n";

 }

 
 
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

  
#-----------------------------------keep track of visited links and links to be visited--------------------------------
sub ManageUpdateLinks {
	@givenLinks=@_;
	foreach (@givenLinks) {
		$type=shift @$_;
		while (($name, $value) = splice(@$_, 0, 2)) {
			if(exists($links{$value})){
				$links{$value}++;
			}
			else {
				$links{$value}=1;
				push @queueLinks, "$value";
			}			
		}
	}
}


sub preprocessFile {
	#$websiteLinkContent = get($seedUrl);
	my $linkName = shift;
	print "\n$linkName \n";
	my $file_c= get $linkName;
	my $file_content = ""; 
	
	if($linkName=~ /(\.pdf)$/ ){
		my $pdf = CAM::PDF->new($file_c);
		foreach(1..($pdf->numPages())){
			my $pdfContent = $pdf->getPageContentTree($_);
			my $file_sub_content= CAM::PDF::PageText->render($pdfContent);
			$file_content = $file_content."\n".$file_sub_content; 
			
		}
	}
	#--------------
	#foreach my $file(@pdfdocs){
	#	$file =~ s/\\/\\\\/g;   # to put the file name string in the correct form so i can pass to numPages
	#	 
	#	unless(open PDFINPUT, '>', "$file.txt"){
	#		die "Unable to create $file.txt";
	#	}
#    my $pdf = CAM::PDF->new($file);
#	foreach (1..($pdf->numPages())){
#		my $pdfContent = $pdf->getPageContentTree($_);
#		#print CAM::PDF::PageText->render($pdfContent);
#		print PDFINPUT CAM::PDF::PageText->render($pdfContent); 
#	}
	
	#--------------
	
	
	#remove all new line character with single space
	$file_content=~ s/[\n\r]/ /g;

	#remove all digits
	$file_content =~ s/[0-9]+//g;
	
	# remove urls 
	$file_content =~ s/\s\?\w\+\.\(com\|org\|edu\)//g;
	
	#convert all contents to lowercase
	$file_content =~ s/(\w)/lc($1)/ge;

	# remove HTML tags both start and close tags
	$file_content =~ s/<.+?>/ /g;

	#Truncating multiple spaces to one space
	$file_content =~ s/\s+/ /g;

	#remove all punctuation symbols
	$file_content =~ s/[[:punct:]]/ /g;
   
	#remove stop_words
	$file_content=&DeleteStopWords($file_content);
	#Do morphological variations
	$file_content=&StemDocument($file_content);
		
	#save the file
	@total_tokens = split(/\s+/, $file_content);
	if(scalar (@total_tokens)>=$minToken){
		$currDocuments++;
		$total_file_content=$file_content;
		$linkName_newline=$currDocuments.":".$linkName."\n"; 
		$outputFileName=$currDocuments.".txt";
		open(WOUTPUT, ">$outputFileName") or die "Can't openfile";
		open(WOUTPUTURL, ">>URL.txt") or die "Can't openfile URL file";
		print WOUTPUT $total_file_content;
		print WOUTPUTURL $linkName_newline;
		close (WOUTPUTURL);
		close(WOUTPUT);
}
	 
	
}



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





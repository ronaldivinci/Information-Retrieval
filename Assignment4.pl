#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 4  


use English;
use List::MoreUtils qw(uniq);
use PDF::API2;
use CAM::PDF;
use CAM::PDF::PageText;
use LWP::Simple;
use HTML::LinkExtor;
use File::Copy qw(copy); 
#use Porter;           no matter what I did, my program seemed to be unable to find the saved file Porter.pm so I just copied the code and added it to my program 


# i have to run this to set up variables as instructed when using Porter Stemmer
initialise();   


#-------------------------First store stop words in an array
my $url = "http://www.cs.memphis.edu/~vrus/teaching/ir-websearch/papers/english.stopwords.txt"; 
my @stopwords; 
 
my $content = get $url;
$content =~ tr/A-Z/a-z/;

foreach my $word (split /\n/, $content){  # for each item in the content split by new line 
	if(length($word) > 1){    # i dont want it to consider the single alphabets or else output comes out bad! 
		push @stopwords, $word; 
	}
}
#--------------------------end of portion pertaining to storing stop words 


my @docs;  
#my $dir = 'C:\Users\vincent.nkawu\Documents\IRDOCSS';

print "Please enter the directory containing the list of documents: ";
my $dir = <>; 
chomp ($dir); 

#make a new directory where I will store the stemmed versions of my document. Original versions will remain in original directory 
my $dirWPreprocessedDoc = $dir."StemmedVersion";
my $newDir = "StemmedVersion"; 
unless(-e $dirWPreprocessedDoc or mkdir $dirWPreprocessedDoc) {
	die "Unable to create $directoryn";
}

#----------------------Extracting pdf to text. You'll notice I saved all the txt version by just appending .txt to the original file name.
#----------------------Probably no need for this, just used here incase you wanted to test on pdf files as well
#my @pdfdocs;
#foreach my $pdfFP (glob("$dir/*.pdf")){
#	push @pdfdocs, $pdfFP; 
#}

#foreach my $file(@pdfdocs){
#		$file =~ s/\\/\\\\/g;   # to put the file name string in the correct form so i can pass to numPages
#		 
#		unless(open PDFINPUT, '>', "$file.txt"){
#			die "Unable to create $file.txt";
#		}
#    my $pdf = CAM::PDF->new($file);
#	foreach (1..($pdf->numPages())){
#		my $pdfContent = $pdf->getPageContentTree($_);
#		#print CAM::PDF::PageText->render($pdfContent);
#		print PDFINPUT CAM::PDF::PageText->render($pdfContent); 
#	}
    

#	close(PDFINPUT);
#}
#----------------------end of converting pdfs to text 


my $stemmedDoc = ""; 
#------------------------------------------traverse through all txt files then create a stemmed version of each file--------------------
  foreach my $FP (glob("$dir/*.txt")) {
	unless(open WINPUT, '>>', "$FP.StemmedVersion.txt"){        #write to a document since terminal cannot display entire lines
		die "Unable to create wordFrequency.txt"; 
		}
	
	open my $fh, "<", $FP or die "can't read open '$FP': $OS_ERROR";
	while ($line = <$fh>) {
		$line =~ tr/A-Z/a-z/;  		 #remove upper case 
		$line =~ tr/A-Za-z'/ /cs;    # remove digits, punctuation
				
		foreach my $word (@stopwords){
			$line = str_replace("$word",'',$line); # i found this to work faster than using regex 
		}
		
#--------------split each word in each line by spaces and stem them-------------------------		
		for my $word (split(' ', lc $line)) {

			$word = stem($word);                     #function stem is specified at the bottom
			$stemmedDoc = $stemmedDoc.$word." "; 
		}
		
		$stemmedDoc = $stemmedDoc."\n"; 
  }
  
  print WINPUT "$stemmedDoc\n";
  close $fh or die "can't read close '$FP': $OS_ERROR";
  close(WINPUT);
  
}



#Replace a string without using RegExp.
# Got part of it from: http://www.bin-co.com/perl/scripts/str_replace.php and manipulated to fit my need. 
# Wanted something faster than regex 
sub str_replace {
	my $replace_this = shift;
	my $with_this  = shift; 
	my $string   = shift;
	
	my $length = length($string);
	my $target = length($replace_this);
	
	for(my $i=0; $i<$length - $target + 1; $i++) {
		if(substr($string,$i,$target) eq $replace_this) {
			if((substr($string,$i-1,1) eq substr($string,$i+$target, 1)) && substr($string,$i-1,1) eq " "){    # used to check if the substring is actually a word. spaces before and after the word. 
				$string = substr($string,0,$i) . $with_this . substr($string,$i+$target);
				#return $string; #Comment this if you what a global replace
			}
		}
	}
	return $string;
}



#!/usr/bin/perl -w

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


#!/usr/bin/perl -w
=begin
@array        = ("a", "e", "i", "o", "u");
@removedItems = splice(@array, 0 , 3, ("A", "E", "I"));



foreach(@$sztring) {
	print "$_";
	}		
print "Removed items: @removedItems\n";
print "Original itmes: @array\n"; 

#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 4  

use diagnostics; 
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
#initialise();   


#-------------------------First store stop words in an array
my $url = "http://www.memphis.edu/cris/pdfs/swimschool08.pdf"; 
my @stopwords; 
 
my $content = get $url;

#print "$content";

if(CAM::PDF->new(get $url)->getPageContentTree(1) != undef){
 my $pdf = CAM::PDF->new($content);
	foreach (1..($pdf->numPages())){
		my $pdfContent = $pdf->getPageContentTree($_);
		#print CAM::PDF::PageText->render($pdfContent);
		print CAM::PDF::PageText->render($pdfContent); 
	}
}


$str = "http://memphis.edu/admissions/pdfs/acc_ba_ma_form.pdf";
$substr = "memphis.edu/admissions/pdfs/acc_ba_ma_form.pdf";
	
if (index($str, $substr) == -1) {
    print "$str contains $substr\n";
}

=cut


$query = "123 thrhe t1 two2 3 ! HHGHG3G4HG4 H5G6H7 7H7JKJ8H8 88988JJJ  g)*(*(** 9898 9898 9897y ug y YGy3ye23 r3rgh3gg5hthy6hfy6y7ju7huukj kku7 u8jkuj";
$query =~ tr/0-9/ /cs;          #remove anything that isnt a word
$query =~ tr/[A-Z]/[a-z]/; 

print $query; 

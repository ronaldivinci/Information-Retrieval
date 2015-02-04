#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 3. Part 2


use English;
use List::MoreUtils qw(uniq);
use PDF::API2;
use CAM::PDF;
use CAM::PDF::PageText;

my @docs;  
#my $dir = 'C:\Users\vincent.nkawu\Documents\IRDocs';

print "Please enter the directory containing the list of documents: ";
my $dir = <>; 
chomp ($dir); 


#Extracting pdf to text. You'll notice I saved all the txt version by just appending .txt to the original file name.
my @pdfdocs;
foreach my $pdfFP (glob("$dir/*.pdf")){
	push @pdfdocs, $pdfFP; 
}

foreach my $file(@pdfdocs){
		$file =~ s/\\/\\\\/g;   # to put the file name string in the correct form so i can pass to numPages
		 
		unless(open PDFINPUT, '>', "$file.txt"){
			die "Unable to create $file.txt";
		}
    my $pdf = CAM::PDF->new($file);
	foreach (1..($pdf->numPages())){
		my $pdfContent = $pdf->getPageContentTree($_);
		#print CAM::PDF::PageText->render($pdfContent);
		print PDFINPUT CAM::PDF::PageText->render($pdfContent); 
	}
    

	close(PDFINPUT);
}









foreach my $FP (glob("$dir/*.txt")) {
push @docs, $FP; 
	unless(open WINPUT, '>>', 'WordFrequency.txt'){        #write to a document since terminal cannot display entire lines
		die "Unable to create WordFrequency.txt"; 
		}
 # printf "%s\n", FP;
  #printf WINPUT "%s\n", $FP;      # print the actual urls that i've converted to documents
  
  open my $fh, "<", $FP or die "can't read open '$FP': $OS_ERROR";
  while (<$fh>) {
	# Print them out
   	
    #printf "  %s", $_;
	#printf WINPUT "  %s", $_;
  }
  close $fh or die "can't read close '$FP': $OS_ERROR";
  
}
#Display heading for my ouput
my $i = 0; 
printf WINPUT "List of documents\n\n";
printf WINPUT "%-70s %s\n", "URL Converted Documents", "Document #";
foreach (@docs){
	printf WINPUT "%-70s %s\n", "$_ ", "Doc $i";
	$i++; 
}
print"\n\n";

my %counts;

#traverse through all documents, using hash, hash out the words using first document as 
#key then for each document using words as key and record the frequency of words
for my $document (@docs, @pdfdocs) {
	open(INPUT,"<$document") or die "Could not open document $document: $!";
	
	while(<INPUT>) {
		tr/A-Za-z/ /cs;

		for my $word (split(' ', lc $_)) {

			$counts{$document}{$word}++;
		}
	}
	close(INPUT);

}


#traverses through all documents, then retrieve words from all of them an put them
#into this word bag called @allWords
my @allWords;

for my $document (keys %counts) {
	for my $word (keys %{$counts{$document}}) {
		push(@allWords, $word);
	}
}

#remove duplicates. I am using a built in method within the perl library List::MoreUtils qw(uniq)
#my frequency WAS generating duplicated results for duplicate words
@allWords = uniq(sort(@allWords));


#print a header line for my frequency display
my $i=0; 
printf "\n\n%-40s", "Word";
printf WINPUT "\n\n%-40s", "Word";
foreach(@docs, @pdfdocs){
	printf "%-8s", "Doc $i";
	printf WINPUT "%-8s", "Doc $i";
	$i++; 	
}
 
print "%-8s\n", "Total";
printf WINPUT "%-8s\n", "Total";



#print counts for each document, and total
for my $word (@allWords) {
	unless(open WINPUT, '>>', 'WordFrequency.txt'){        #write to a document since terminal cannot display entire lines
		die "Unable to create wordFrequency.txt"; 
		}
	print "$word\t\t";
	printf WINPUT "%-40s", "$word";
	my $totPerWord = 0;
	for my $document (sort keys %counts) {
		print "$counts{$document}{$word}\t";
		printf WINPUT "%-8s", "$counts{$document}{$word}";
		
		$totPerWord += $counts{$document}{$word};
	}
	print "\t$totPerWord\n";
	printf WINPUT "%-8s\n", "$totPerWord";

}
print "Total Number of Words are: ". scalar(@allWords);
print WINPUT "Total Number of Words are: ". scalar(@allWords); 

close(WINPUT);

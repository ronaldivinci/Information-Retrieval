#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 2. Part 2

print "Please enter a file path to read from: ";
my $file = <>;

chomp $file; 

open(FH, "<$file")|| die "Could not open file $file\n";

my %count;
while(my $line = <FH>){
chomp $line;
$line =~ tr/[A-Z]/[a-z]/;

foreach my $word (split /[^A-Z|^a-z&&^']/, $line){
	$wordSS++; 
	$count{$word}++;
	}
}
$totalWords = $wordSS - $count{''}; 
foreach my $word (sort keys %count){
	printf "%-25s %s\n", $word, $count{$word};
	
	        
	#write to an output file since terminal cannot display all lines at once
	unless(open WINPUT, '>>', output123.txt){
		die "Unable to create output.txt"; 
	}
	printf WINPUT "%-25s %s\n", $word, $count{$word};
	close(WINPUT);
}

print"Total number of words is $totalWords \n"; 

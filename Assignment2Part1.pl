#!/usr/local/bin/perl
#Vincent Nkawu
#Information Retrieval
#Assignment 2. Part 1


#If the file to read from and write to are not provided as arguments
#in command prompt, then prompt the user to enter it during program execution

my ($document1, $document2) = @ARGV; 
if ($#ARGV !=1){
	print "Please enter a file to read from: ";
	$document1 = <>; 
	
	print "Now enter a file to write to: ";
	$document2 = <>;
}

chomp($document1);
chomp($document2);

open(INPUT, "<$document1")|| die "Could not open file $document1\n";

$count = 0; 
while($line = <INPUT>){
	print".";
	unless(open WINPUT, '>>', $document2){
		die "Unable to Create $document2";
	}
	print WINPUT "$line";
	close (WINPUT);
	$count++;
}

print "FINISHED\n$count line of text have been copied from:\n $document1 --> $document2\n";

 

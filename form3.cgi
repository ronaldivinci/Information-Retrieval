#!/usr/bin/perl

# The FORM Program:  form3.pl

# This program is just one very long print statement written in Perl.  
# When it is run from the web-server, however, it will send the text
# starting with the HTML headings after the first EOF marker, all the
# all the way to the last EOF marker.  The stuff between is standard
# HTML code that will be displayed properly as a web page by the browser.

print<<EOF;
Content-type: text/html

<HTML>
<BODY BGCOLOR=WHITE TEXT=BLACK>
<CENTER>
<H1> Creating a Dynamic Calendar<br>
 with CGI and Perl </H1>
</CENTER>
This simple web page prints out a form requesting a name and date from 
a user.  When the submit button is pressed, it will call a second Perl 
program that generates a presonalized calendar using that information.
 These two Perl Scripts must reside in a special "<B>CGI</B>"directory 
called <B>cgi-bin</B> which is created as a sub-directory off of 
<B>web-docs</B>, and must have the proper permissions in order for the
pages to work on the web server. <br>
<p>
<H3> Let's get some information:</H3>
<FORM METHOD = "GET" ACTION="answer3.pl">
<br>
Enter your name:<br>
<INPUT TYPE = "TEXT" NAME = "name" SIZE = "30">
<br>
<br>

Enter a month:
<SELECT NAME = "month" VALUE="Month" >
<OPTION SELECTED>1
<OPTION>2
<OPTION>3
<OPTION>4
<OPTION>5
<OPTION>6
<OPTION>7
<OPTION>8
<OPTION>9
<OPTION>10
<OPTION>11
<OPTION>12
</SELECT>
 
&nbsp &nbsp
&nbsp &nbsp
Enter a year:
<INPUT TYPE = "TEXT" NAME = "year" SIZE = "4">
<br>
<br>
<br>
<INPUT TYPE = "RESET" NAME = "reset" VALUE = "Clear Entries"> 
<br>
<br>
<br>
<INPUT TYPE = "SUBMIT" NAME = "submit" VALUE = "Submit Calendar Request">
<br>
</BODY>
</HTML>
EOF


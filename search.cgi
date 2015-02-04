#!/usr/bin/perl

# The FORM Program:  search.cgi

# This program simply promts a query from the user and then returns relevant   
# documents that satisfy that query. It will pass query items to another
# program that will do some processing against those query and return output
# documents, that are ranked.
# 

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
    font-size: 24px;
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

<p>

</p>
<input type="text" placeholder = "search" name = "query">
<input type="submit" value = "Search">
</body>
</html>
EOF

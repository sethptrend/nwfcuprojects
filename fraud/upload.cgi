#!/usr/bin/perl

use warnings;
use strict;



use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;



my $query = new CGI;

my $filename = $query->param("fileupload");
#my $upload_filehandle = $query->upload("fileupload");

#open ( my $upload, ">", "$filename" ) or die "$!";
#binmode $upload;

#while ( <$upload_filehandle> )
#{
#print $upload;
#}

#close $upload;
#if($filename =~ /\.xlsx$/i){
#the umask didn't work
#`umask 117`;
my $tmpfilename = $query->tmpFileName($filename);
my $tarname = join('',localtime(time)) . '.xlsx';
`mv $tmpfilename /home/sphillips/fraudfiles/today/$tarname`;
`chmod 660 /home/sphillips/fraudfiles/today/$tarname`;
#}
print $query->header ( );
print <<END_HTML;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Thanks!</title>
<style type="text/css">
img {border: none;}
</style>
</head>
<body>
File uploaded.
</body>
</html>
END_HTML

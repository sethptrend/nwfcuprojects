#!/usr/bin/perl

use lib '/home/sphillips/lib/';
use Test::More;


use_ok('JSON');
use_ok('DBI');
use_ok('Text::Levenshtein');
use_ok('Data::Dumper');
use_ok('Spreadsheet::WriteExcel');
done_testing();

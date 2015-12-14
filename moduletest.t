#!/usr/bin/perl

use lib '/home/sphillips/lib/';
use Test::More;


use_ok('JSON');
use_ok('DBI');
use_ok('Text::Levenshtein');
done_testing();

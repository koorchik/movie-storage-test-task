#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Test::Most;

use FindBin;
use lib "$FindBin::Bin/../lib/";

use MovieStorage::Movie;

my $m1 = new_ok( 'MovieStorage::Movie' => [{ 
    title  => '2001: A Space Odyssey',                         
    year   => 1968,             
    id     => 1,          
    format => 'DVD',    
    stars  =>  ['Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain']
}]);

can_ok($m1, qw/
    get_title  set_title 
    get_year   set_year 
    get_format set_format 
    get_stars  set_stars 
    get_id     set_id
    to_string
/);

# Test getters
is( $m1->get_title(), '2001: A Space Odyssey', '"title" passed to constructor should be set in attr' );
is( $m1->get_year(), 1968, '"year" passed to constructor should be set in attr' );
is( $m1->get_format(), 'DVD', '"format" passed to constructor should be set in attr' );
is( $m1->get_id(), 1, '"id" passed to constructor should be set in attr' );
cmp_bag( 
    $m1->get_stars(), 
    ['Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain'] , 
    '"stars" passed to constructor should be set in attr' 
);

# Test "title" setter and getter with valid data
foreach my $valid_title ('A Space Odyssey 2002', 'A', 0, ('A' x 200) ) {  
    is( $m1->set_title($valid_title), $m1, "new title [$valid_title]. 'set_title' should return \$self" );
    is( $m1->get_title(), $valid_title, "Checking 'get_title' that new value [$valid_title] was set" );
}

# Test "year" setter and getter with valid data
foreach my $valid_year (1984, 2020, 1985, 2050 ) {  
    is( $m1->set_year($valid_year), $m1, "new year [$valid_year]. 'set_year' should return \$self" );
    is( $m1->get_year(), $valid_year, "Checking 'get_year' that new value [$valid_year] was set" );
}

# Test "format" setter and getter with valid data
foreach my $valid_format ('DVD', 'VHS', 'Blu-Ray') {  
    is( $m1->set_format($valid_format), $m1, "new format [$valid_format]. 'set_format' should return \$self" );
    is( $m1->get_format(), $valid_format, "Checking 'get_format' that new value [$valid_format] was set" );
}

# Test "id" setter and getter with valid data
foreach my $valid_id (1, 120, 1_000_000) {  
    is( $m1->set_id($valid_id), $m1, "new id [$valid_id]. 'set_id' should return \$self" );
    is( $m1->get_id(), $valid_id, "Checking 'get_id' that new value [$valid_id] was set" );
}

# Test "stars" setter and getter with valid data
my @valid_stars_sets = (
    ['Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary'],
    ['Carl Reiner'],
    ['Eva Marie Saint Eva Marie Saint', 'Brian']
);

foreach my $valid_stars (@valid_stars_sets) {  
    is( $m1->set_stars($valid_stars), $m1, "new stars [$valid_stars]. 'set_stars' should return \$self" );
    cmp_bag( $m1->get_stars(), $valid_stars, "Checking 'get_stars' that new value [$valid_stars] was set");
}

done_testing();
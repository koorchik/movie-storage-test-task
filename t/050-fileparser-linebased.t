#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Test::Most;
use FindBin;
use File::Temp qw/tempfile/;


use lib "$FindBin::Bin/../lib/";
use MovieStorage::FileParser::LineBased;

######################### PREPARE SECTION #########################
my ( $fh, $filename ) = tempfile();

my $data = <<'DATA';
Title: Blazing Saddles 1111
Release Year: 1974
Format: VHS
Stars: Mel Brooks, Clevon Little, Harvey Korman, Gene Wilder, Slim Pickens, Madeline Kahn

Title: Casablanca
Release Year: 1942
Format: DVD
Stars: Humphrey Bogart 2, Ingrid Bergman, Claude Rains, Peter Lorre

Title: Charade: Next
Release Year: 2021
Format: Blu-Ray
Stars: Audrey Hepburn
DATA

print $fh $data;
close $fh;

############################## TESTING ###########################

my $fileparser = new_ok('MovieStorage::FileParser::LineBased');

can_ok( $fileparser, 'get_movies_from_file' );
isa_ok( my $iter = $fileparser->get_movies_from_file($filename), 'Iterator' );
can_ok( $iter, 'value' );

# Get and check movie 1
isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', 'movie object $m1' );
is( $m1->get_title(),  'Blazing Saddles 1111', 'getting parsed "title" for $m1' );
is( $m1->get_year(),   1974,                   'getting parsed "year" for $m1' );
is( $m1->get_format(), 'VHS',                  'getting parsed "format" for $m1' );
cmp_bag(
    $m1->get_stars(), 
    [ 'Mel Brooks', 'Clevon Little', 'Harvey Korman', 'Gene Wilder', 'Slim Pickens', 'Madeline Kahn' ],
    'getting parsed "stars" for $m1'
);

# Get and check movie 2
isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', 'movie object $m2' );
is( $m2->get_title(),  'Casablanca', 'getting parsed "title" for $m2' );
is( $m2->get_year(),   1942,         'getting parsed "year" for $m2' );
is( $m2->get_format(), 'DVD',        'getting parsed "format" for $m2' );
cmp_bag(
    $m2->get_stars(),
    [ 'Humphrey Bogart 2', 'Ingrid Bergman', 'Claude Rains', 'Peter Lorre' ],
    'getting parsed "stars" for $m2'
);

# Get and check movie 3
isa_ok( my $m3 = $iter->value(), 'MovieStorage::Movie', 'movie object $m1' );
is( $m3->get_title(),  'Charade: Next', 'getting parsed "title" for $m3' );
is( $m3->get_year(),   2021,            'getting parsed "year" for $m3' );
is( $m3->get_format(), 'Blu-Ray',       'getting parsed "format" for $m3' );
cmp_bag(
    $m3->get_stars(),
    ['Audrey Hepburn'],
    'getting parsed "stars" for $m3'
);

# 
is( $iter->value(), undef, 'Iterator should return undef when out of items' );

done_testing;

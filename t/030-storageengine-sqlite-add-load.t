#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Test::Most;
use File::Temp qw/tmpnam/;
use FindBin;

use lib "$FindBin::Bin/../lib/";
use MovieStorage::Movie;
use MovieStorage::StorageEngine::SQLite;

# We can do black-box testing because
# 1. Test will be applicable for other storage engines with minimal modifications.
# 2. Storage has single dependency wich can be mocked in constructor

# Initialize new empty storage
my $storage = new_ok( 'MovieStorage::StorageEngine::SQLite', [ { db_path => scalar(tmpnam()) } ] );

can_ok( $storage, qw/ add_movie load_movie_by_id / );

################################ add_movie + load_movie_by_id ##################
{

    # Save movie 1
    my $m1 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => '2001: A Space Odyssey',
                year   => 1968,
                format => 'DVD',
                stars  => [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ] } ] );

    ok( my $id1 = $storage->add_movie($m1), '"add_movie" should return movie 1 id (positive integer)' );
    like( $id1, qr/^\d+$/, 'movie 1 id should be a positive integer' );

    # Load and check movie 1
    isa_ok( my $m1_l = $storage->load_movie_by_id($id1), 'MovieStorage::Movie', 'loaded movie 1' );

    is( $m1_l->get_title(),  '2001: A Space Odyssey', '"get_title" for movie 1' );
    is( $m1_l->get_year(),   1968,                    '"get_year" for movie 1' );
    is( $m1_l->get_format(), 'DVD',                   '"get_format" for movie 1' );
    is( $m1_l->get_id(),     $id1,                    '"get_id" for movie 1' );
    cmp_bag(
        $m1_l->get_stars(),
        [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ],
        '"get_stars" for movie 1'
    );
}

{

    # Save movie 2
    my $m2 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'XJaws',
                year   => 2050,
                format => 'Blu-Ray',
                stars  => [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ] } ] );

    ok( my $id2 = $storage->add_movie($m2), '"add_movie" should return movie 2 id (positive integer)' );
    like( $id2, qr/^\d+$/, 'movie 2 id should be a positive integer' );

    # Load and check movie 2
    isa_ok( my $m2_l = $storage->load_movie_by_id($id2), 'MovieStorage::Movie', 'loaded movie 2' );
    is( $m2_l->get_title(),  'XJaws',   '"get_title" for movie 2' );
    is( $m2_l->get_year(),   2050,      '"get_year" for movie 2' );
    is( $m2_l->get_format(), 'Blu-Ray', '"get_format" for movie 2' );
    is( $m2_l->get_id(),     $id2,      '"get_id" for movie 2' );
    cmp_bag(
        $m2_l->get_stars(),
        [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ],
        '"get_stars" for movie 2'
    );
}

{

    # Save movie 3
    my $m3 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'Real Genius',
                year   => 1900,
                format => 'VHS',
                stars  => [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ] } ]
    );
    ok( my $id3 = $storage->add_movie($m3), '"add_movie" should return movie 3 id (positive integer)' );
    like( $id3, qr/^\d+$/, 'movie 3 id should be a positive integer' );

    # Load and check movie 3
    isa_ok( my $m3_l = $storage->load_movie_by_id($id3), 'MovieStorage::Movie', 'loaded movie 3' );
    is( $m3_l->get_title(),  'Real Genius', '"get_title" for movie 3' );
    is( $m3_l->get_year(),   1900,          '"get_year" for movie 3' );
    is( $m3_l->get_format(), 'VHS',         '"get_format" for movie 3' );
    is( $m3_l->get_id(),     $id3,          '"get_id" for movie 3' );
    cmp_bag(
        $m3_l->get_stars(),
        [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ],
        '"get_stars" for movie 3'
    );
}


done_testing();

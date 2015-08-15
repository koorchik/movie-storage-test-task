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
# this test depend on $storege->add_movie but this is acceptable for this app

# Initialize new empty storage
my $storage = new_ok( 'MovieStorage::StorageEngine::SQLite', [ { db_path => scalar(tmpnam()) } ] );

can_ok(
    $storage, qw/
        add_movie
        load_movie_by_id
        list_movies
        find_movies
        /
);

# Add movies
{

    # Save movie 1
    my $m1 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => '2001: A Space Odyssey',
                year   => 1968,
                format => 'DVD',
                stars  => [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ] } ] );

    ok( my $id1 = $storage->add_movie($m1), '"add_movie" should return movie 1 id (positive integer)' );

    # Save movie 2
    my $m2 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'XJaws',
                year   => 2050,
                format => 'Blu-Ray',
                stars  => [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ] } ] );

    ok( my $id2 = $storage->add_movie($m2), '"add_movie" should return movie 2 id (positive integer)' );

    # Save movie 3
    my $m3 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'Real Genius',
                year   => 1900,
                format => 'VHS',
                stars  => [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ] } ]
    );
    ok( my $id3 = $storage->add_movie($m3), '"add_movie" should return movie 3 id (positive integer)' );

}

# Test list_movies
{

    # list by title
    isa_ok( my $iter = $storage->list_movies('title'), 'Iterator' );
    can_ok( $iter, 'value' );

    # Get and check movie 1
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', '[list_movies("title")]movie object 1' );
    is( $m1->get_title(),  '2001: A Space Odyssey', '[list_movies("title")]"get_title" for movie 1' );
    is( $m1->get_year(),   1968,                    '[list_movies("title")]"get_year" for movie 1' );
    is( $m1->get_format(), 'DVD',                   '[list_movies("title")]"get_format" for movie 1' );
    cmp_bag(
        $m1->get_stars(),
        [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ],
        '[list_movies("title")]"get_stars" for movie 1'
    );

    # Get and check movie 2
    isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', '[list_movies("title")]movie object 2' );
    is( $m2->get_title(),  'Real Genius', '[list_movies("title")]"get_title" for movie 2' );
    is( $m2->get_year(),   1900,          '[list_movies("title")]"get_year" for movie 2' );
    is( $m2->get_format(), 'VHS',         '[list_movies("title")]"get_format" for movie 2' );
    cmp_bag(
        $m2->get_stars(),
        [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ],
        '[list_movies("title")]"get_stars" for movie 2'
    );

    # Get and check movie 3
    isa_ok( my $m3 = $iter->value(), 'MovieStorage::Movie', '[list_movies("title")]movie object 3' );
    is( $m3->get_title(),  'XJaws',   '[list_movies("title")]"get_title" for movie 3' );
    is( $m3->get_year(),   2050,      '[list_movies("title")]"get_year" for movie 3' );
    is( $m3->get_format(), 'Blu-Ray', '[list_movies("title")]"get_format" for movie 3' );
    cmp_bag(
        $m3->get_stars(),
        [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ],
        '[list_movies("title")]"get_stars" for movie 3'
    );

    #
    is( $iter->value(), undef, 'Iterator should return undef when out of items' );

}

{

    # list by year
    isa_ok( my $iter = $storage->list_movies('year'), 'Iterator' );
    can_ok( $iter, 'value' );

    # Get and check movie 1
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', '[list_movies("year")]movie object 1' );
    is( $m1->get_title(),  'Real Genius', '[list_movies("year")]"get_title" for movie 2' );
    is( $m1->get_year(),   1900,          '[list_movies("year")]"get_year" for movie 3' );
    is( $m1->get_format(), 'VHS',         '[list_movies("year")]"get_format" for movie 3' );
    cmp_bag(
        $m1->get_stars(),
        [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ],
        '[list_movies("year")]"get_stars" for movie 3'
    );

    # Get and check movie 2
    isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', '[list_movies("title")]movie object 2' );
    is( $m2->get_title(),  '2001: A Space Odyssey', '[list_movies("year")]"get_title" for movie 1' );
    is( $m2->get_year(),   1968,                    '[list_movies("year")]"get_year" for movie 1' );
    is( $m2->get_format(), 'DVD',                   '[list_movies("year")]"get_format" for movie 1' );
    cmp_bag(
        $m2->get_stars(),
        [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ],
        '[list_movies("year")]"get_stars" for movie 1'
    );

    # Get and check movie 3
    isa_ok( my $m3 = $iter->value(), 'MovieStorage::Movie', '[list_movies("year")]movie object 3' );
    is( $m3->get_title(),  'XJaws',   '[list_movies("year")]"get_title" for movie 3' );
    is( $m3->get_year(),   2050,      '[list_movies("year")]"get_year" for movie 3' );
    is( $m3->get_format(), 'Blu-Ray', '[list_movies("year")]"get_format" for movie 3' );
    cmp_bag(
        $m3->get_stars(),
        [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ],
        '[list_movies("year")]"get_stars" for movie 3'
    );

    #
    is( $iter->value(), undef, 'Iterator should return undef when out of items' );

}

done_testing();

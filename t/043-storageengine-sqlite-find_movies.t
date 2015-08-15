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
                title  => 'XJaws Space',
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

# Test find_movies - search "eal" in title
{

    
    isa_ok( my $iter = $storage->find_movies('title', 'eal'), 'Iterator' );
    can_ok( $iter, 'value' );

    # Get and check movie 1
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', '[find_movies(title eal)]movie object 1' );
    is( $m1->get_title(),  'Real Genius', '[find_movies(title eal)]"get_title" for movie 1' );
    is( $m1->get_year(),   1900,          '[find_movies(title eal)]"get_year" for movie 1' );
    is( $m1->get_format(), 'VHS',         '[find_movies(title eal)]"get_format" for movie 1' );
    cmp_bag(
        $m1->get_stars(),
        [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ],
        '[find_movies(title eal)]"get_stars" for movie 1'
    );

    #
    is( $iter->value(), undef, 'Iterator should return undef when out of items' );

}

# Test find_movies - search "space" in title
{
    isa_ok( my $iter = $storage->find_movies('title', 'space'), 'Iterator' );
    can_ok( $iter, 'value' );

    # Get and check movie 1
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', '[find_movies(title space)]movie object 1' );
    is( $m1->get_title(),  '2001: A Space Odyssey', '[find_movies(title space)]"get_title" for movie 1' );
    is( $m1->get_year(),   1968,                    '[find_movies(title space)]"get_year" for movie 1' );
    is( $m1->get_format(), 'DVD',                   '[find_movies(title space)]"get_format" for movie 1' );
    cmp_bag(
        $m1->get_stars(),
        [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ],
        '[find_movies(title space)]"get_stars" for movie 1'
    );

    # Get and check movie 2
    isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', '[find_movies(title space)]movie object 2' );
    is( $m2->get_title(),  'XJaws Space',   '[find_movies(title space)]"get_title" for movie 2' );
    is( $m2->get_year(),   2050,      '[find_movies(title space)]"get_year" for movie 2' );
    is( $m2->get_format(), 'Blu-Ray', '[find_movies(title space)]"get_format" for movie 2' );
    cmp_bag(
        $m2->get_stars(),
        [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ],
        '[find_movies(title space)]"get_stars" for movie 2'
    );

    #
    is( $iter->value(), undef, 'Iterator should return undef when out of items' );

}


# Test find_movies - search "Gary" in stars
{
    isa_ok( my $iter = $storage->find_movies('star', 'gary'), 'Iterator' );
    can_ok( $iter, 'value' );

    # Get and check movie 1
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', '[find_movies(star gary)]movie object 1' );
    is( $m1->get_title(),  '2001: A Space Odyssey', '[find_movies(star gary)]"get_title" for movie 1' );
    is( $m1->get_year(),   1968,                    '[find_movies(star gary)]"get_year" for movie 1' );
    is( $m1->get_format(), 'DVD',                   '[find_movies(star gary)]"get_format" for movie 1' );
    cmp_bag(
        $m1->get_stars(),
        [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ],
        '[find_movies(star gary)]"get_stars" for movie 1'
    );

    # Get and check movie 2
    isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', '[find_movies(star gary)]movie object 2' );
    is( $m2->get_title(),  'XJaws Space',   '[find_movies(star gary)]"get_title" for movie 2' );
    is( $m2->get_year(),   2050,      '[find_movies(star gary)]"get_year" for movie 2' );
    is( $m2->get_format(), 'Blu-Ray', '[find_movies(star gary)]"get_format" for movie 2' );
    cmp_bag(
        $m2->get_stars(),
        [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ],
        '[find_movies(star gary)]"get_stars" for movie 2'
    );

    #
    is( $iter->value(), undef, 'Iterator should return undef when out of items' );

}
done_testing();

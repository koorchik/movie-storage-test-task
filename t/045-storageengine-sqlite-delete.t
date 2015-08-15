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
my ( $id1, $id2, $id3 );
{

    # Save movie 1
    my $m1 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => '2001: A Space Odyssey',
                year   => 1968,
                format => 'DVD',
                stars  => [ 'Keir Dullea', 'Gary Lockwood', 'William Sylvester', 'Douglas Rain' ] } ] );

    ok( $id1 = $storage->add_movie($m1), '"add_movie" should return movie 1 id (positive integer)' );

    # Save movie 2
    my $m2 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'XJaws',
                year   => 2050,
                format => 'Blu-Ray',
                stars  => [ 'Roy Scheider', 'Robert Shaw', 'Richard Dreyfuss', 'Lorraine Gary' ] } ] );

    ok( $id2 = $storage->add_movie($m2), '"add_movie" should return movie 2 id (positive integer)' );

    # Save movie 3
    my $m3 = new_ok(
        'MovieStorage::Movie' => [ {
                title  => 'Real Genius',
                year   => 1900,
                format => 'VHS',
                stars  => [ 'Val Kilmer: 22', 'Gabe Jarret', 'Michelle Meyrink', 'William Atherton' ] } ]
    );
    ok( $id3 = $storage->add_movie($m3), '"add_movie" should return movie 3 id (positive integer)' );
}

############################# TEST DELETION #####################
# Delete first movie 
{
    $storage->delete_movie_by_id($id2);
    throws_ok(
        sub { $storage->load_movie_by_id($id2) },
        qr/no movie with id \[$id2\]/,
        'load movie should generate exception if movie does not exists'
    );
    
    isa_ok( my $iter = $storage->list_movies('title'), 'Iterator' );
    
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', 'movie object 1' );
    isnt( $m1->get_id(), $id2, 'no object should have id as deleted object' );
    
    isa_ok( my $m2 = $iter->value(), 'MovieStorage::Movie', 'movie object 2' );
    isnt( $m2->get_id(), $id2, 'no object should have id as deleted object' );
    
    is( $iter->value(), undef, 'Only two objects in list' );
}

{
    $storage->delete_movie_by_id($id1);
    throws_ok(
        sub { $storage->load_movie_by_id($id1) },
        qr/no movie with id \[$id1\]/,
        'load movie should generate exception if movie does not exists'
    );
    
    isa_ok( my $iter = $storage->list_movies('year'), 'Iterator' );
    
    isa_ok( my $m1 = $iter->value(), 'MovieStorage::Movie', 'movie object 1' );
    isnt( $m1->get_id(), $id1, 'no object should have id as deleted object' );

    is( $iter->value(), undef, 'Only one object in list' );
}

{
    $storage->delete_movie_by_id($id3);
    throws_ok(
        sub { $storage->load_movie_by_id($id3) },
        qr/no movie with id \[$id3\]/,
        'load movie should generate exception if movie does not exists'
    );
    
    isa_ok( my $iter = $storage->list_movies('year'), 'Iterator' );
    is( $iter->value(), undef, 'No objects in list' );
}

done_testing;

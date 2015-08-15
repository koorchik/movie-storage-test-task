#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use Test::Most;
use DBI;
use FindBin;
use File::Temp qw/tmpnam/;

use lib "$FindBin::Bin/../lib/";
use MovieStorage::CLI;
use MovieStorage::StorageEngine::SQLite;
use MovieStorage::FileParser::LineBased;

# Initialzie dependencies. Mock objects are not needed here (SQLite DB itself a good mock)
my $fileparser = new_ok( 'MovieStorage::FileParser::LineBased');
my $storage = new_ok( 'MovieStorage::StorageEngine::SQLite', [ { db_path => scalar(tmpnam()) } ] );

my $cli = new_ok( 'MovieStorage::CLI', [{
    storage    => $storage,
    fileparser => $fileparser  
}]);
   
can_ok($cli, qw/
    run
    _command_main_menu
    _command_add_movie
    _command_delete_movie
    _command_dispay_movie
    _command_list_movies_by_title
    _command_list_movies_by_year
    _command_find_movies_by_title
    _command_find_movies_by_star
    _command_import_movies
    _command_quit
/);


done_testing();
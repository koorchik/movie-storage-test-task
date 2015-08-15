#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

use MovieStorage::CLI;
use MovieStorage::StorageEngine::SQLite;
use MovieStorage::FileParser::LineBased;

main();

sub main {
    # by default we save movies in "$HOME/.moviestorage/movies.dat"
    my $settings_folder  = "$ENV{HOME}/.moviestorage";
    if (! -e $settings_folder ) {
        mkdir $settings_folder or die "$!";
    }

    my $cli = MovieStorage::CLI->new({
        storage => MovieStorage::StorageEngine::SQLite->new({
            db_path => "$settings_folder/sqlite.db"
        }),
        fileparser  => MovieStorage::FileParser::LineBased->new()
    });

    $cli->run();
}

use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MovieStorage',
    VERSION             => 0.02,
    AUTHOR              => q{Viktor Turskyi <koorchik@cpan.org>},
    MIN_PERL_VERSION    => 5.010,
    PREREQ_PM => {
        'Test::Most'  => 0,
        'DBI'         => 1.38,
        'DBD::SQLite' => 0,
        'Iterator'    => 0.03,
        'Test::Most'  => 0,
        'Test::UI'    => 0
    },
    EXE_FILES => [ 'bin/movie_storage.pl' ],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MovieStorage-*' },
);

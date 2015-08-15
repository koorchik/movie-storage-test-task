package MovieStorage::FileParser::LineBased;

use v5.10;
use strict;
use warnings;
use Iterator;
use Carp;

use MovieStorage::Movie;

use base 'MovieStorage::FileParser';

our $VERSION = '0.01';

sub new {
    return bless {}, $_[0];
}

sub get_movies_from_file {
    my ($self, $filename) = @_;
    
    open( my $fh, '<', $filename ) or die "Cannot open file [$filename]. [$!]";
    my $data = do {local $/; <$fh>};
    close $fh;
    
    my $re = qr{
        ^Title:\s*         (?<title>  [\S ]+)          \s*
        ^Release\sYear:\s* (?<year>   \d+)             \s*
        ^Format:\s*        (?<format> VHS|DVD|Blu-Ray) \s*
        ^Stars:\s*         (?<stars>  [\S ]+)          \s*
    }ixsm;
    
    my @movies;
    while ($data =~ /$re/gs) {
        push @movies, MovieStorage::Movie->new({
            title  => $+{title},
            year   => $+{year},
            format => $+{format},
            stars  => [ split(/,\s?/, $+{stars}) ]
        });
    }

    my $i = 0;
    return Iterator->new(sub{ $movies[$i++] }); 
}


1; 

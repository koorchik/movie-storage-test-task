package MovieStorage::FileParser;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

MovieStorage::FileParser - abstract class which only describes StorageEngine API

=head1 METHODS

To implement parser inherit this class and implement next methods:

=cut


=head2 $CLASS->new( )
    
    constructor
    
    RETURNS: $SELF
    
=cut 

sub new {
    my $class = ref $_[0] || $_[0];
    die "METHOD [new] not implemented in [$class]";
}

=head2 $SELF->get_movies_from_file($FILEPATH)
    
    Parses passed file ($FILEPATH)
    
    RETURNS:  "Iterator" object for MovieStorage::Movie objects
    
=cut


sub get_movies_from_file {
    my $class = ref $_[0] || $_[0];
    die "METHOD [get_movies_from_file] not implemented in [$class]";
}


1; 

package MovieStorage::StorageEngine;

use v5.10;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

MovieStorage::StorageEngine - abstract class which only describes StorageEngine API

=head1 METHODS

To implement storage engine inherit this class and implement next methods:

=cut


=head2 $CLASS->new( )
    
    constructor
    
    RETURNS: $SELF
    
=cut
 
sub new {
    my $class = ref $_[0] || $_[0];
    die "METHOD [new] not implemented in [$class]";
}

=head2 $SELF->add_movie( MovieStorage::Movie $MOVIE )
    
    stores $MOVIE pemanently (on error raises exception)
    
    RETURNS: $movie_id
    
=cut

sub add_movie {
    my $class = ref $_[0] || $_[0];
    die "METHOD [add_movie] not implemented in [$class]";
}

=head2 $SELF->load_movie_by_id( $MOVIE_ID )
    
    loads movie by its id ($MOVIE_ID) (on error raises exception)
    
    RETURNS: MovieStorage::Movie $MOVIE
    
=cut

sub load_movie_by_id {
    my $class = ref $_[0] || $_[0];
    die "METHOD [load_movie_by_id] not implemented in [$class]";
}

=head2 $SELF->delete_movie_by_id( $MOVIE_ID )
    
    deletes movie by its id ($MOVIE_ID) (on error raises exception)
    
    RETURNS: VOID
    
=cut

sub delete_movie_by_id {
    my $class = ref $_[0] || $_[0];
    die "METHOD [delete_movie_by_id] not implemented in [$class]";
}

=head2 $SELF->list_movies( $SORT_ORDER )
    
    returns movie list in certain order($SORT_ORDER) (on error raises exception)
    
    RETURNS:  "Iterator" object for MovieStorage::Movie objects
    
=cut

sub list_movies {
    my $class = ref $_[0] || $_[0];
    die "METHOD [list_movies] not implemented in [$class]";
}

=head2 $SELF->find_movies( $SEARCH_ATTR, $SEARCH_STRING)
    
    searches movies by $SEARCH_STRING in movie atts($SEARCH_ATTR)(on error raises exception)
    
    RETURNS:  "Iterator" object for MovieStorage::Movie objects sorted by id
    
=cut

sub find_movies {
    my $class = ref $_[0] || $_[0];
    die "METHOD [find_movies] not implemented in [$class]";
}


1; 

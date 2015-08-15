package MovieStorage::Movie;

use v5.10;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

=head1 NAME

MovieStorage::Movie - represents movie object data type

=head1 DESCRIPTION


This class provides Movie datatype and nothing else 


=head1 METHODS/ATTRIBUTES


=cut


=head2 $CLASS->new( \%ATTRS )
    
    constructs movie object
    
    %ATTRS = (
        title  - String                         
        year   - Integer 1985..2050             
        id     - Integer          
        format - 'VHS' or 'DVD' or 'Blu-Ray'    
        stars  - ref to array with stars names  
    )
    
    RETURNS: $SELF
    
=cut

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
    
    # Fill object 
    foreach my $attr (qw/id title year format stars/) {
        eval {
            $self->${\"set_$attr"}($args->{$attr});
        };
        croak $@ if $@;
    }
    
    return $self;
}

=head2 $SELF->get_id(  )
    
    RETURNS: Integer
    
=cut

sub get_id { return $_[0]->{id} }

=head2 $SELF->set_id( Integer $MOVIE_ID )
    
    (on  error raises exception)
    
    RETURNS: $SELF
    
=cut

sub set_id {
    my ($self, $id)= @_;
    $self->{id} = $id;
    return $self; 
}

=head2 $SELF->get_title(  )
    
    RETURNS: String
    
=cut

sub get_title { return $_[0]->{title} }

=head2 $SELF->set_title( String $MOVIE_TITLE )

    (on  error raises exception)
    
    RETURNS: $SELF
    
=cut

sub set_title {
    my ($self, $title)= @_;
    $self->{title} = $title;
    return $self;
}


=head2 $SELF->get_year(  )
    
    RETURNS: Integer
    
=cut

sub get_year { return $_[0]->{year} }

=head2 $SELF->set_year( Integer $RELEASE_YEAR )
    
    $RELEASE_YEAR must be [1985..2050]

    (on  error raises exception)
    
    RETURNS: $SELF
    
=cut

sub set_year {
    my ($self, $year)= @_;
    
    if ( $year =~ /\D/ || $year < 1895 || $year > 2050 ) {
        croak "Wrong year [$year]. Year should be number from 1895 to 2050!";
    }
    
    $self->{year} = $year;
    return $self;
}

=head2 $SELF->get_format(  )
    
    RETURNS: String ('VHS' or 'DVD' or 'Blu-Ray')
    
=cut

sub get_format { return $_[0]->{format} }

=head2 $SELF->set_format( String $FORMAT )
    
    $FORMAT must be 'VHS' or 'DVD' or 'Blu-Ray'

    (on  error raises exception)
    
    RETURNS: $SELF
    
=cut

sub set_format {
    my ($self, $format)= @_;
    
    if ( ! grep { $format eq $_ } qw/VHS DVD Blu-Ray/ ) {
        croak "Wrong format [$format]!";
    }
    
    $self->{format} = $format;
    return $self;
}


=head2 $SELF->get_stars(  )
    
    RETURNS: ref to array with stars names
    
=cut

sub get_stars { return $_[0]->{stars} }

=head2 $SELF->set_stars( \@STARS )
    
    @STARS contains list of stars names

    (on  error raises exception)
    
    RETURNS: $SELF
    
=cut

sub set_stars {
    my ($self, $stars)= @_;
    
    if ( !$stars || ref($stars) ne 'ARRAY') {
        croak "Wrong stars. Should be arrayref with stars names!";
    }
    
    $self->{stars} = $stars;
    return $self;
}

=head2 $SELF->to_string(  )
    
    Stringifies all movie attributes
    
    RETURNS: String
    
=cut

sub to_string {
    my ($self) = @_;

    my $stringified = 
         "\nID:           " . ($self->get_id()//'N/A')
        ."\nTitle:        " . $self->get_title()
        ."\nRelease year: " . $self->get_year() 
        ."\nFormat:       " . $self->get_format()
        ."\nStars:        " . join(', ', @{$self->get_stars()})
        ."\n";

    return $stringified;
}

1;

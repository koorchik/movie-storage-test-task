package MovieStorage::StorageEngine::SQLite;

use v5.10;
use strict;
use warnings;
use DBI;
use Carp;
use Iterator;
use MovieStorage::Movie;

use base 'MovieStorage::StorageEngine';

our $VERSION = '0.01';


sub new {
    my ( $class, $args ) = @_;
    croak 'db_path required' unless $args->{db_path};
    
    my $dbh = DBI->connect( 
        "dbi:SQLite:dbname=$args->{db_path}", 
        "", 
        "", 
        {
            RaiseError     => 1,
            sqlite_unicode => 1,
        } 
    )  or die DBI->error;
    
    my $self = { dbh => $dbh, prepared_sth => {} };         
    bless $self, $class;
    
    $self->_create_db_structure_if_needed();
    
    return $self; 
}


sub add_movie {
    my ($self, $movie)  = @_;
    my $dbh = $self->_get_dbh();
    my $movie_id;
    
    # Start transaction
    $dbh->begin_work();

    eval {
        # Insert movie and get its id
        $self->{prepared_sth}{insert_movie} ||= $dbh->prepare(
            "INSERT INTO movies(title, year, format) VALUES(?,?,?)"
        );
        $self->{prepared_sth}{insert_movie}->execute($movie->get_title(), $movie->get_year(), $movie->get_format()); 
        $movie_id = $dbh->last_insert_id('','','','')  or die $dbh->error();
    
        # Insert movie's stars    
        $self->{prepared_sth}{insert_stars} ||= $dbh->prepare(
            "INSERT INTO stars(movie_id, name) VALUES(?,?)"
        );
        
        foreach my $star_name (@{$movie->get_stars}) {
            $self->{prepared_sth}{insert_stars}->execute($movie_id, $star_name);
        } 
    };
        
    if ($@) { 
        $dbh->rollback();
        die "Cannot store movie. Error [$@]";
    } else {
        $dbh->commit();
        return $movie_id;
    }

}

sub load_movie_by_id {
    my ($self, $movie_id)  = @_;
    my $dbh = $self->_get_dbh();
    
    my $sth = $self->{prepared_sth}{select_movie_by_id} ||= $dbh->prepare(
        "SELECT m.movie_id, m.title, m.year, m.format, group_concat(s.name, '\n') AS star_name 
         FROM movies m LEFT JOIN stars s ON m.movie_id = s.movie_id 
         WHERE m.movie_id = ? 
         GROUP BY m.movie_id"
    );
    
    $sth->execute($movie_id);
    my $row = $sth->fetchrow_hashref() or die "There is no movie with id [$movie_id]\n";

    my %movie_data = (
        id     => $row->{movie_id},
        title  => $row->{title},
        year   => $row->{year},
        format => $row->{format},
        stars  => [ split(/\n/, $row->{star_name}) ]
    );
    
    return MovieStorage::Movie->new(\%movie_data);
}

sub delete_movie_by_id {
    my ($self, $movie_id)  = @_;
    my $dbh = $self->_get_dbh();
    
    my $sth = $self->{prepared_sth}{delete_movie_by_id} ||= $dbh->prepare(
        "DELETE  FROM movies WHERE movie_id = ?;"
    );
    
    $sth->execute($movie_id);
}

sub list_movies {
    my ($self, $order) = @_;
    
    if ( ! grep { $order eq $_ } qw/title year/ ) {
        croak 'Only "title" and "year" orders are supported'    
    }
    
    my $dbh = $self->_get_dbh();
    
    my $sth = $self->{prepared_sth}{"list_movies_$order"} ||= $dbh->prepare(
        "SELECT m.movie_id, m.title, m.year, m.format, group_concat(s.name, '\n') AS star_name 
         FROM movies m LEFT JOIN stars s ON m.movie_id = s.movie_id 
         GROUP BY m.movie_id 
         ORDER BY m.$order ASC"
    );
    
    $sth->execute();
    
    my $iter = Iterator->new(sub {
        my $row = $sth->fetchrow_hashref();
        return unless $row;  
        my %movie_data = (
            id     => $row->{movie_id},
            title  => $row->{title},
            year   => $row->{year},
            format => $row->{format},
            stars  => [ split(/\n/, $row->{star_name}) ]
        );
    
        return MovieStorage::Movie->new(\%movie_data);
    }); 
    
    return $iter;
}

sub find_movies {
    my ($self, $search_field, $search_string) = @_;

    if ( ! grep { $search_field eq $_ } qw/title star/ ) {
        croak 'Only "title" and "star" search fields are supported'    
    }
    
    my $dbh = $self->_get_dbh();

    my $where_clause = '';
    if ($search_field  eq 'star') {
        $where_clause = "WHERE m.movie_id IN (SELECT movie_id FROM stars WHERE name LIKE ?)";
    } else {
        $where_clause = "WHERE m.$search_field LIKE ?";
    }
    
    my $sth = $self->{prepared_sth}{"search_movies_$search_field"} ||= $dbh->prepare(
        "SELECT m.movie_id, m.title, m.year, m.format, group_concat(s.name, '\n') AS star_name 
        FROM movies m LEFT JOIN stars s ON m.movie_id = s.movie_id
        $where_clause 
        GROUP BY m.movie_id
        ORDER BY m.movie_id
        " 
    );
    
    $sth->execute('%' . ($search_string//'') . '%' );
    
    my $iter = Iterator->new(sub {
        my $row = $sth->fetchrow_hashref();
        return unless $row;  
        my %movie_data = (
            id     => $row->{movie_id},
            title  => $row->{title},
            year   => $row->{year},
            format => $row->{format},
            stars  => [ split(/\n/, $row->{star_name}) ]
        );
    
        return MovieStorage::Movie->new(\%movie_data);
    }); 
    
    return $iter;
}


########################################### INTERNAL METHODS ########################################## 
sub _get_dbh {
    return $_[0]->{dbh}
}

sub _create_db_structure_if_needed {
    my $self = shift;
    return if $self->_get_dbh->selectrow_array("select count(*) from sqlite_master");
    
    $self->_get_dbh->do(
            q{CREATE TABLE movies (
                movie_id INTEGER NOT NULL PRIMARY KEY ASC AUTOINCREMENT,
                title    TEXT    NOT NULL,
                year     INTEGER NOT NULL,
                format   TEXT    NOT NULL )}
    );

    $self->_get_dbh->do(
            q{CREATE TABLE stars (
                star_id  INTEGER NOT NULL PRIMARY KEY ASC AUTOINCREMENT,
                movie_id INTEGER NOT NULL 
                                 CONSTRAINT fk_movie_id 
                                 REFERENCES movies(movie_id) 
                                 ON DELETE CASCADE,
                name     TEXT    NOT NULL DEFAULT(''))}
    );
}

1;

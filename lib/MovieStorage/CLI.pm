package MovieStorage::CLI;

use v5.10;
use strict;
use warnings;

use Term::UI;
use Term::ReadLine;
use Term::ANSIColor;

use MovieStorage::Movie;

our $VERSION = '0.01';


sub new {
    my ( $class, $args ) = @_;

    my $self = {
        storage    => $args->{storage},
        fileparser => $args->{fileparser},
        term       => Term::ReadLine->new('MovieStorage')
    };

    return bless $self, $class;
}

sub run {
    my ($self) = @_;

    while ( 1 ) {
        $self->_command_main_menu()
    }
}

########################################### INTERNAL METHODS ##########################################

sub _get_term { return $_[0]->{term} }
sub _get_storage { return $_[0]->{storage} }
sub _get_fileparser { return $_[0]->{fileparser} }

sub _command_main_menu {
    my ($self) = @_;
    state $actions = {
        'add movie'            => '_command_add_movie',
        'delete movie'         => '_command_delete_movie',
        'display movie'        => '_command_dispay_movie',
        'list movies by title' => '_command_list_movies_by_title',
        'list movies by year'  => '_command_list_movies_by_year',
        'find movies by title' => '_command_find_movies_by_title',
        'find movies by star'  => '_command_find_movies_by_star',
        'import movies'        => '_command_import_movies',
        'quit'                 => '_command_quit'
    };

    my $reply = $self->_get_term->get_reply(
        print_me => "\n*** MAIN MENU ***\n",
        prompt   => 'Choose option? ',
        choices  => [ sort keys %$actions ] );

    eval {
        $self ->${ \"$actions->{$reply}" }();
    };

    say( colored( $@, 'BOLD RED' )) if $@;

}

sub _command_add_movie {
    my ($self) = @_;

    my %movie_data = (
        title => '',
        year  => '',
        format =>'',
        stars => []
    );

    # Get movie title
    local $Term::UI::INVALID = 'Title should be 2-250 characters: ';
    $movie_data{title} = $self->_get_term->get_reply(
        prompt => 'Enter the movie title: ',
        allow => sub { length($_) >= 2 && length($_) <= 250 }
    );

    # Get movie release year
    local $Term::UI::INVALID = 'Release year should be number from 1895 to 2050: ';
    $movie_data{year} = $self->_get_term->get_reply(
        prompt => 'Enter the movie release year: ',
        allow => sub { $_ && /^\d+$/ && $_ >= 1895 &&  $_ <= 2050 }
    );

    # Get movie format
    local $Term::UI::INVALID = 'Supported formats are "VHS", "DVD", "Blu-Ray. Please choose one of them: "';
    $movie_data{format} = $self->_get_term->get_reply(
        prompt  => 'Choose the movie format: ',
        choices => ['VHS', 'DVD', 'Blu-Ray']
    );

    # Get stars
    local $Term::UI::INVALID = 'Star name should be 2-250 characters: ';
    my $star = $self->_get_term->get_reply(
        prompt => 'Enter star name: ',
        allow => sub { length($_) >= 2 && length($_) <= 250 }
    );

    push @{$movie_data{stars}}, $star;

    while (1) {
        $star = $self->_get_term->get_reply(
            print_me => 'Just press enter if you do not want add another star.',
            prompt => 'Enter another star name: ',
            allow => sub { length($_) == 0 || (length($_) >= 2 && length($_) <= 250) }
        );
        if ($star) {
            push @{$movie_data{stars}}, $star;
        } else {
            last;
        }
    }

    # Construct movie object and confirm saving
    my $movie_object = MovieStorage::Movie->new({
         title  => $movie_data{title},
         year   => $movie_data{year},
         format => $movie_data{format},
         stars =>  $movie_data{stars}
    });

    local $Term::UI::INVALID = 'Do you want to save the movie? ';
    my $is_do_save = $self->_get_term->ask_yn(
        print_me => $movie_object->to_string(),
        prompt => 'Do you want to save the movie?',
        default => 'y',
    );

    if ($is_do_save) {
        my $movie_id = $self->_get_storage->add_movie($movie_object);
        say( colored( "Movie with id=[$movie_id] was created!", 'BOLD GREEN' ));
    }
}

sub _command_delete_movie {
    my ($self) = @_;

    # Get movie id
    local $Term::UI::INVALID = 'Movie id should be positive integer value: ';
    my $movie_id = $self->_get_term->get_reply(
        prompt => 'Enter the movie id to delete (or just press enter to return to the main menu): ',
        allow => sub { length($_) == 0 || /^\d+$/ } );

    if ( $movie_id ) {
        my $movie_object = $self->_get_storage->load_movie_by_id($movie_id);
        my $is_do_save = $self->_get_term->ask_yn(
            print_me => $movie_object->to_string(),
            prompt => 'Do you really want to delete this movie?',
            default => 'y',
        );

        $self->_get_storage->delete_movie_by_id($movie_id);
        say( colored( "Movie with id [$movie_id] was deleted!", 'BOLD GREEN' ));
    }
}

sub _command_dispay_movie {
    my ($self) = @_;

    # Get movie id
    local $Term::UI::INVALID = 'Movie id should be positive integer value: ';
    my $movie_id = $self->_get_term->get_reply(
        prompt => 'Enter the movie id to display (or just press enter to return to the main menu): ',
        allow => sub { length($_) == 0 || /^\d+$/ } );

    if ( $movie_id ) {
        my $movie_object = $self->_get_storage->load_movie_by_id($movie_id);
        say $movie_object->to_string();
    }
}

sub _command_list_movies_by_title {
    my ($self) = @_;

    my $iter = $self->_get_storage->list_movies('title');
    while (my $movie_object = $iter->value()) {
        say $movie_object->get_id() . ': ' . $movie_object->get_title();
    }
}

sub _command_list_movies_by_year {
    my ($self) = @_;

    my $iter = $self->_get_storage->list_movies('year');
    while (my $movie_object = $iter->value()) {
        say $movie_object->get_id() . ': ' . $movie_object->get_title();
    }

}

sub _command_find_movies_by_title {
    my ($self) = @_;

    my $search_string = $self->_get_term->get_reply(
        prompt => 'Enter search string: '
    );

    my $iter = $self->_get_storage->find_movies('title', $search_string);
    while (my $movie_object = $iter->value()) {
        say $movie_object->get_id() . ': ' . $movie_object->get_title();
    }
}

sub _command_find_movies_by_star {
    my ($self) = @_;

    my $search_string = $self->_get_term->get_reply(
        prompt => 'Enter search string: '
    );

    my $iter = $self->_get_storage->find_movies('star', $search_string);
    while (my $movie_object = $iter->value()) {
        say $movie_object->get_id() . ': ' . $movie_object->get_title();
    }
}

sub _command_import_movies {
     my ($self) = @_;

    local $Term::UI::INVALID = 'Cannot read provided file: ';
    my $file = $self->_get_term->get_reply(
        prompt => 'Enter path to file (or just press enter to return to the main menu): ',
        allow => sub { length($_) == 0 || (-r $_ && -f $_) }
    );

    if ( $file ) {
        my $iter = $self->_get_fileparser->get_movies_from_file($file);
        my $cnt_movies_stored = 0;
        my $cnt_movies_total  = 0;

        while (my $movie_object = $iter->value()) {
            my $movie_id = eval {
                 $cnt_movies_total++;
                 $self->_get_storage->add_movie($movie_object);
            };

            if ($@) {
                say( colored( "Cannot store movie! $@", 'BOLD RED' ));
            } else {
                $cnt_movies_stored++;
                say( colored( "Movie with id=[$movie_id] was created!", 'BOLD GREEN' ));
            }
        }

        say "Parsed [$cnt_movies_total] movies. [$cnt_movies_stored] of them were added.";
    }
}

sub _command_quit {
    exit;
}



1;

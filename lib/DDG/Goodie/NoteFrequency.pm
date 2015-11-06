package DDG::Goodie::NoteFrequency;
# ABSTRACT: Return the frequency (Hz) of the note given in the query

use DDG::Goodie;
use strict;

zci answer_type => "note_frequency";
zci is_cached   => 1;

name "NoteFrequency";
description "Calculate the frequency of a musical note";
primary_example_queries "notefreq a4", "notefreq gb5";
secondary_example_queries "notefreq c3 432";
category "conversions";
topics "music";
code_url "https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/NoteFrequency.pm";
attribution github => ["sublinear", "sublinear"];

# Triggers
triggers any => "notefreq", "notefrequency", "note frequency", "note frequency of", "frequency of note";

# Handle statement
handle remainder => sub {

    return unless $_;

    # must be a note letter, optional sharp or flat, octave number, and optional tuning frequency for A4
    # e.g. "g#3 432"

    if ( $_ =~ /^([A-Ga-g])([b#])?([0-8])(\s+[0-9]{1,5})?$/ ) {

        my( $letter, $accidental, $octave, $tuning, $pitchClass, $midi, $frequency );

        # regex captures
        if (defined $1) { $letter     = uc($1); } else { $letter     = ""; }
        if (defined $2) { $accidental = $2;     } else { $accidental = ""; }
        if (defined $3) { $octave     = $3 + 0; } else { $octave     = 0;  }
        if (defined $4) { $tuning     = $4 + 0; } else { $tuning     = 0;  }

        # assume 440Hz tuning unless otherwise specified
        if ( $tuning == 0 ) { $tuning = 440; }

        # convert note letter to pitch class number
        if    ( $letter eq "C" ) { $pitchClass = 0;  }
        elsif ( $letter eq "D" ) { $pitchClass = 2;  }
        elsif ( $letter eq "E" ) { $pitchClass = 4;  }
        elsif ( $letter eq "F" ) { $pitchClass = 5;  }
        elsif ( $letter eq "G" ) { $pitchClass = 7;  }
        elsif ( $letter eq "A" ) { $pitchClass = 9;  }
        else                     { $pitchClass = 11; }

        # apply accidental to pitch class number
        if    ( $accidental eq "b" ) { $pitchClass -= 1; }
        elsif ( $accidental eq "#" ) { $pitchClass += 1; }

        # calculate MIDI number
        $midi = ( 12 * ($octave + 1) ) + $pitchClass;

        # fix pitch class number
        $pitchClass %= 12;

        # validate note is between C0 and B8
        if ( $midi >= 12 && $midi <= 119 ) {
            # calculate frequency
            $frequency = $tuning * ( 2 ** (($midi-69)/12) );

            # result
            return $frequency,
                structured_answer => {
                    input => [html_enc($letter.$accidental.$octave." in A".$tuning." tuning")],
                    operation => "Note Frequency",
                    result => html_enc($frequency." Hz"),
                };
        }

        # failed midi range validation
        return;
    }

    else {

        # failed regular expression
        return;

    }
};

1;

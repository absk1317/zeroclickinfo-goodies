package DDG::Goodie::ExampleDate;

# ABSTRACT: Generate random dates from given formats.

use DDG::Goodie;
use strict;

use DateTime;
use List::Util qw(first);

zci answer_type => 'example_date';

zci is_cached => 0;

triggers start => 'random';
triggers any   => 'date';

my %standard_queries = (
    'week ?day|day( of the week)?' => ['%A', 'Weekday'],
    'month( of the year)?'         => ['%B', 'Month'],
    'date'                         => ['%x', 'Date'],
    'time'                         => ['%X', 'Time'],
    'week'                         => ['%W', 'Week'],
);

my $standard_re = join '|', map { "($_)" } (keys %standard_queries);

handle query => sub {
    my $query = shift;
    my $format;
    my $type = 'format';
    if ($query =~ /^random ($standard_re)$/i) {
        my $standard_query = $1;
        my $k = first { $standard_query =~ qr/^$_$/i } (keys %standard_queries);
        ($format, $type) = @{$standard_queries{$k}};
    } else {
        return unless $query =~ /^((random|example) )?date for (?<format>.+)$/i;
        $format = $+{'format'};
    }
    my $random_date = get_random_date($lang->locale);
    my $formatted = $random_date->strftime($format);

    return if $formatted eq $format;

    return "$formatted",
        structured_answer => {

            data => {
              title => "$formatted",
              subtitle => $type eq 'format'
                ? "Random date for: $format" : "Random $type",
            },

            templates => {
                group => "text",
            }
        };
};

# 9999-12-31T23:59:59Z
my $MAX_DATE = 253_402_300_799;
# 0000-01-01T00:00:00Z
my $MIN_DATE = -62_167_219_200;
my $MAX_RAND = $MAX_DATE - $MIN_DATE;
sub get_random_date {
    my $locale = shift;
    my $rand_num = int(rand($MAX_RAND));
    return DateTime->from_epoch(
        epoch => ($rand_num + $MIN_DATE), locale => $locale
    );
}

1;

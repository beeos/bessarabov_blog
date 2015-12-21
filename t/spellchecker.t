use Test::More;

# https://tech.yandex.ru/speller/

use strict;
use warnings FATAL => 'all';
use utf8;
use open qw(:std :utf8);

use File::Slurp;
use HTTP::Tiny;
use JSON::PP;
use Text::Markdown qw(markdown);

my @IGNORE = qw(
    PSGI
);

my %IGNORE_HASH = map { $_ => 1 } @IGNORE;

sub get_content {
    my ($file_name) = @_;

    my $content = read_file(
        $file_name,
        {
            binmode => ':utf8',
        },
    );

    return $content;
}

sub remove_meta_information {

    $_[0] =~ s/date_time: .*//;

    return 1;
}

sub remove_code {

    $_[0] =~ s/^\s{4}.*//mg;

    return 1;
}

sub remove_ignore_words {

    $_[0] = [
        grep {
            not $IGNORE_HASH{$_->{word}}
        } @{$_[0]}
    ];

    return 1;
}

sub get_check_result_from_yandex_speller {
    my ($html) = @_;

    my $response = HTTP::Tiny->new()->post_form(
        'https://speller.yandex.net/services/spellservice.json/checkText',
        {
            text => $html,
            ie => 'utf-8',
            format => 'html',
        }
    );

    is($response->{status}, 200, 'Got 200 status code from speller.yandex.net');

    my $check_result = decode_json $response->{content};

    return $check_result;
}

sub main_in_test {

    binmode Test::More->builder->output, ":utf8";
    binmode Test::More->builder->failure_output, ":utf8";

    pass('Loaded ok');

    my @files = <*_ru.md>;

    # TODO
    @files = (qw(rfc_2119_ru.md));

    foreach my $file_name (@files) {

        my $content = get_content($file_name);

        remove_meta_information($content);
        remove_code($content);

        my $html = markdown($content);

        my $check_result = get_check_result_from_yandex_speller($html);

        remove_ignore_words($check_result);

        if (scalar @{$check_result} == 0) {
            pass('Speller found no errors in file "' . $file_name . '"');
        } else {
            fail('Speller found errors in file "' . $file_name . '"');
            foreach my $element (@{$check_result}) {
                note(
                    sprintf(
                        'Unknown word: "%s". (Suggestions: "%s")',
                        $element->{word},
                        join('", "', @{$element->{s}}),
                    )
                );
            }
        }
    }

    done_testing();
}
main_in_test();

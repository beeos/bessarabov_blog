use Test::More;

# https://tech.yandex.ru/speller/

# TODO
# * ignore list
# * remove code

use strict;
use warnings FATAL => 'all';
use utf8;
use open qw(:std :utf8);

use File::Slurp;
use HTTP::Tiny;
use JSON::PP;
use Text::Markdown qw(markdown);

sub main_in_test {

    binmode Test::More->builder->output, ":utf8";
    binmode Test::More->builder->failure_output, ":utf8";

    pass('Loaded ok');

    my @files = <*_ru.md>;

    # TODO
    @files = (qw(rfc_2119_ru.md));

    foreach my $file_name (@files) {

        my $content = read_file(
            $file_name,
            {
                binmode => ':utf8',
            },
        );
        $content =~ s/date_time: .*//;

        my $html = markdown $content;

        my $response = HTTP::Tiny->new()->post_form(
            'https://speller.yandex.net/services/spellservice.json/checkText',
            {
                text => $html,
                ie => 'utf-8',
                format => 'html',
            }
        );

        is($response->{status}, 200, 'Got 200 status code from speller.yandex.net when checking "' . $file_name . '"');

        my $check_result = decode_json $response->{content};

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

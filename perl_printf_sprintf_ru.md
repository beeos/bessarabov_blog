# Работа в Perl с функциями printf и sprintf

date_time: 2015-05-05 21:55:07 MSK

В Perl есть функции printf и sprintf, которые иногда бывают очень удобны в
работе.

Пример:

    printf('Hello, %s.', 'Bob'); # выводет на экран строку 'Hello, Bob.'

Разница между printf и sprintf заключается в том что printf выводит результат
на экран, а sprintf сохраняет значение в переменной:

    my $bar = sprintf('Hello, %s.', 'Bob');
    # теперь в переменной $bar содержится строка 'Hello, Bob.'

%s - это плейсхолдер, который просто подставляет вместо себя значение, но
есть более интересные плейсхолдеры, которые можно настраивать. Примеры:

    # добавить нули перед числом
    sprintf("%03d", 7); # 007
    sprintf("%03d", 70); # 070
    sprintf("%03d", 700); # 700
    sprintf("%03d", 7000); # 7000

    # округлисть число до нужной точности
    sprintf("%0.2f", 3.1415926); # 3.14
    sprintf("%0.4f", 3.1415926); # 3.1416

У плейсхолдера %s есть интересная возможность менять порядок:

    sprintf('%s - %s', 'one', 'two'); # 'one - two'
    sprintf('%2$s - %1$s', 'one', 'two'); # 'two - one'

Полная документация про эти функции есть на сайте [perldoc.perl.org](http://perldoc.perl.org/):

 * [printf](http://perldoc.perl.org/functions/printf.html)
 * [sprintf](http://perldoc.perl.org/functions/sprintf.html)

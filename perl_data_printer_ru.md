# Как в Perl посмотреть значение переменной

## date_time: 2014-09-24 11:33:57 MSK

Задача: хочется понять что находится в переменной внутри Perl программы.
Например, есть [вот такой код][sample_code]. В нем определяется и используется
переменная $person — хочется понять что там содержится.

## Old-school решение — использовать Data::Dumper

Чаще всего эта задача решается с помощью подключения модуля
[Data::Dumper][dd]:

    use Data::Dumper;

    print Dumper $person;

[Код][code_dd].

В ответ мы увидем что-то вроде:

![Как Data::Dumper выводит скаляр с объектом][dd_img]

Ну да, что-то тут видно, но это как-то совсем не user-friendly вывод. Вместо
unicode символов пишется \x{...}, да и весь вывод какой-то унылый.

## Современное решение — использование Data::Printer

В мире соременного Perl есть чудесный и замечательный модуль
[Data::Printer][dp] (вместо длинного названия Data::Printer гораздо удобнее
использовать сокращение DDP). Вот как решается эта же задача с помощью DDP:

    use DDP;

    p $person;

Вот [код][code_dp]. При использовании DDP нужно вводить почти в 3 раза меньше
текста, но самое главное — это то как выглядит вывод:

![Как DDP выводит скаляр с объектом][dp_img]

Вот список почему этот вывод лучше чем вывод Data::Dumper:

 * unicode, а не крякозябры
 * цвета!
 * интроспекция обекта — показыатся не только класс объекта, но и методы этого
   класса, а еще и родители класса

Вот еще пример сравнения Data::Dumper и DDP. Вот как эти 2 модуля выводят [хеш
и массив][hash_array_code].

Унылый вариант Data::Dumper:

![Как Data::Dumper выводит хеш и массив][hash_array_dd]

И мега вывод DDP:

![Как DDP выводит хеш и массив][hash_array_dp]

## Конфиг

DDP может быть очень гибко настроен. Мне не совсем подошли настройки DDP из
коробки, поэтому у меня есть вот конфиг файл ~/.dataprinter со следующим
содержимым:

    {
        use_prototypes => 0,
        hash_separator => ' => ',
        index          => 0,
        return_value   => 'void',
        end_separator  => 1,
    }

## Недостатки DDP

При всем великолепии модуля DDP у него есть недостаки, про которые стоит
знать.

 1. Модуль DDP нужно устанавливать. Модуль Data::Dumper идет вместе с Perl.
    Если установлен perl, то модуль Data::Dumper сразу доступен. А для того
    чтобы на машине появился модуль DDP нужно предпринять дополнительне
    действия.
 2. Вывод модуля DDP предназначен только для просмотра человеком, модуль
    Data::Dumper можно использовать в качестве серелизатора/десерилизатора, но
    модуль DDP нельзя использовать для этих целей.

## Заметки

А почему модуль Data::Printer сокращается до DDP? Мне стало интересно, [я
задал вопрос и получит ответ][why_such_alias].

## Резюме

DDP — прекрасная вещь, которой обязательно нужно пользоваться при разработке и
дебаге. А еще:

 * DDP очень удобно использовать в однострочниках
 * DDP можно подключить в perl debugger
 * у DDP есть такая офигенная вещь как [фильтры][f]

 [sample_code]: https://gist.github.com/bessarabov/7da22d2e656bb89f2858
 [code_dd]: https://gist.github.com/bessarabov/650c0099e7a14ed18c5e
 [code_dp]: https://gist.github.com/bessarabov/4b00b896b2d4e9921c6c
 [dd]: https://metacpan.org/pod/Data::Dumper
 [dp]: https://metacpan.org/pod/Data::Printer
 [dd_img]: https://upload.bessarabov.ru/bessarabov/GVuoA3e0IZb_twnmHnERm8Sri3c.png
 [dp_img]: https://upload.bessarabov.ru/bessarabov/FsUGhXccsBPt5NqwGO5shZY9b-Y.png
 [why_such_alias]: https://github.com/garu/Data-Printer/issues/15
 [hash_array_code]: https://gist.github.com/bessarabov/0fe07b50fab2f09f50ff
 [hash_array_dd]: https://upload.bessarabov.ru/bessarabov/FwKOH2d80gbTPll1Vad3aT8Lfkc.png
 [hash_array_dp]: https://upload.bessarabov.ru/bessarabov/qmoi56U3wohZHf2AJRXItEaA8JU.png
 [f]: https://metacpan.org/pod/Data::Printer#FILTERS

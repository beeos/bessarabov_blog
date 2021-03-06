# Выбор Perl модуля для повторения кода

date_time: 2014-07-02 12:55:29 MSK

## Задача

В моем Perl объекте у меня есть метод, который взаимодействует с внешним
интернет сервисом. Этот интернет сервис не всегда доступен и если он
недоступн, то мне нужно повторить вызов метода.

Задачка-то не сложная, но мне не хочется писать код для ее решения, а хочется
найти уже готовый Perl модуль для ее решения (моя идея что использовать уже
готовые решения это более эффективная стратегия чем писать все самому).

Чуть более подробное описание задачи. Есть метод do_work(), в том случае
если при выполении этого метода бросается исключение TemporaryError, то нужно
повторно выполнить метод. Если же бросается исключение друго типа, то
повторения нужно прекрашать. Если же исключения не было, то код отработал
правильно и повторы больше не нужны. Повторять не более трех раз, паузы между
повторами — 5 секунд.

## Сравнение модулей

У меня есть скрипт [comparator][ac], который я использую для сравнения разных
Perl модулей.

Я поискал по CPAN, нашел модули, которые вроде как должны решать мою задачу
повторения кода и отдал этот список моему скриптпу. Вот сводная таблица,
которую выдал скрипт:

    Name               Releaser    ▼ Latest     Latest  #    pass   fa- na  un-
    Attempt            MARKF       2003-10-09   1.01    2    510    3   0   2
    Retry              TJC         2011-05-10   0.12    3    1174   0   0   1
    Sub::Retry         TOKUHIROM   2013-08-14   0.06    6    358    0   0   0
    Try::Tiny::Retry   DAGOLDEN    2014-01-21   0.003   3    631    0   0   0
    Action::Retry      DAMS        2014-05-21   0.24    15   316    0   0   0

В этой таблице следующие колонки:

 * Name — понятное дело, это название модуля.
 * Releaser — CPAN автор, кто зарелизил последнюю версию этого модуля (на CPAN
   возможна ситуация что роазные версии модуля релизят разные люди).
 * Latest — дата последнего релиза.
 * Второй Latest — это номер последней версии модуля.
 * # — это общее количетво релизов.
 * pass — это количество успешно пройденных тестов у последнего релиза
 * fa- — количество тестов последнего релиза которые упали,
 * na и un- — количетсво тестов по которым нет данных.

Список отсортирован по дате последнего релиза.

Из этой таблицы сразу становится понятно что на модуль Attemt можно вообще не
смотреть — он обновлялся 10 лет назад и у него есть падающие тесты. А на
оставшиеся модули вполе можно посмотреть.

## Тестовый стенд

Для того чтобы можно было сравнивать работу разных модулей, я [подготовил
код][gh], который воссоздает уловия задачи. Я сдела 4 класса, в каждом
из которых есть метод do_work():

 * Класс Success — метод do_work() с первого раза успешно отрабатывает —
   код для повторения должен запустить метод do_work() один раз и
   больше не повторять запуск этого метода — он успешно отработал
 * Класс Fail — метод do_work() с первого раза глобально падает — код
   для повторения должен запустить метод do_work() один раз и больше не
   повторять запуск — метод фатально упал
 * Класс TwoErrorsAndSuccess — метод do_work() сначала два раза выдает
   ошибку и код для повторения должен повторить вызов метода (
   после каждого неуспеха код должен ждать 5 секунд). С третьего
   раза метод do_work() выдает правильный ответ.
 * Класс TempErrorAndFail — метод do_work() сначала выдает ошибку
   после которой нужно повторить выполнение, а во второй раз метод
   do_work() выдает фатальную ошибку.

В тестовом стенде я считаю сколько времени заняло выполнение кода
(поскольку есть большие паузы в 5 секунд, то из времени выполнения
становится понятно, корректно ли повторятельный код работал). А еще
метод do_work() выдает текст с описание что происходит.

Вот лог того как должен работать повторятельный код для всех 4-х
классов:

![Ожидаемая работа модулей][i]

## Action::Retry

Это первый модуль, который я попробовал для решения моей задачи.

Модуль оказался отличным. Мне с легкостью удалось решить мою задачу.
Мне не пришлоись залезать в иходник этого модуля чтобы понять как он работает —
у него совершенно отличная документация из которой все понятно.

В модуле совершенно отлично проработан вопрос "сколько времени ждать между
попытками" — в состав модуля сразу входит несколько совершенно разных
алгоритмов из которых можно собрать кучу разных вариантов.

Код для повторения который получился выглядит совершенно понятно, даже если
ты никогда раньше не работал с этим модулем.

Очень доволен этим модулем.

Вот код, который решает изначальную задачу:

    my $action = Action::Retry->new(
        attempt_code => sub {
            $obj->do_work();
        },
        strategy => {
            Linear => {
                initial_sleep_time => 5000,
                multiplicator => 1,
            }
        },
        retry_if_code => sub {
            my ($error) = @_;

            if (ref($error) eq 'TemporaryError') {
                return true;
            } else {
                return false;
            }
        },
    );
    $action->run();

## Try::Tiny::Retry

Из доки ничего не понял. Пришлось заглядывать в тесты для того чтобы написать
код. Стал разбираться, почему я ничего не понял, оказалось что из доки я не
осознал что этот код:

    use Try::Tiny::Retry;

    retry     { ... }
    on_retry  { ... }
    catch     { ... };

это не три разные команды, а одна команда, написанная в три строчки.

Решение получилось вот такое:

    my $count = 0;

    my $obj = $class->new();

    retry {
        $obj->do_work();
        die "ick" if ++$count < 3;
    }
    delay {
        sleep 5;
    }
    retry_if {
        ref($_) eq 'TemporaryError'
    };

Мне не нравится код, который получился у решения. Мне приходится
самому делать проверку на макисмальное количество повтореней. И мне все-таки
не нравится синтаксис try {} catch {};

### Sub::Retry

Из документации я не понял как написать кастомную проверку — пришлось лезть
в исходник модуля.

    my $obj = $class->new();

    retry(
        3,
        5,
        sub {
            $obj->do_work();
        },
        sub {
            if (ref($@) eq 'TemporaryError') {
                return true;
            } else {
                return false;
            }
        },
    );

Код получился очень кратким и аккуратным, но из кода непонятны что
означают цифры 3 и 5. Какое число означает количество повторений, а какой
паузу между ними?

### Retry

Нет, к сожалению, мне не удалось решить мою задачу с помощью этого модуля.
Я остановился после того как написал что-то вроде:

        my $obj = $class->new();

        my $agent = Retry->new(
            retry_delay => 5,
            max_retry_attempts => 2,
        );

        $agent->retry(
            sub {
                eval {
                    $obj->do_work();
                };
            }
        );

Этот модуль меня не устроил по нескольким причинам. Во первых (и самое
главное), мне не удалось ему прописать условие по которому нужно повторять
попытку или же прекращать повторения. У модуля нет встроенных инструментов
с помощью которого можно ему рассказать про логику. Я пытался релизовать
это руками, оборачивая мой падающий метод в eval, а потом руками обрабатывать
ошибку, но что-то у меня не получилось сделать то что нужно.

Кроме основной пробелмы, то что мне не удалось написать работающий код, есть
еще момент из-за которого этот модуль мне не подходит — в модуль жестко зашито
что каждая следующая пауза после ошибки в 2 раза болье чем предыдущая, а я
хочу каждый раз после ошибки ждать одно и то же время (5 секунд).

И еще один мелкий момент. Для того чтобы метод повторялся 3 раза нужно
передать конструктору max_retry_attempts => 2, что, на мой взгляд, совершенно
нелогично.

## Резюме

Больше всего мне понравился модуль Action::Retry. Но когда я попытался
подключить его в свой проект, оказалось что у него сликом много зависимостей.
Я начал все их собирать в deb пакеты, но через некоторе время понял что я
провожусь слишком долго. Поэтому я взял модуль Sub::Retry у которого вообще
нет никакх зависимостей кроме perl.

 [ac]: https://github.com/bessarabov/App-Comparator
 [gh]: https://github.com/bessarabov/perl_choose_retry_module
 [i]: https://upload.bessarabov.ru/bessarabov/zoU4Eyllq9i-wnV4I7EaWH8zSn0.png


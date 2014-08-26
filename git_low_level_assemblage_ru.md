# Низкоуровневая работа с git репозиторием

date_time: 2014-08-26 23:02:03 MSK

У меня появилась интересная задача — сконверсить некие версионные данные
в формат git репозитория. Для решения этой задачи я чуть-чуть разобрался
как храняться данные в git репозитории и как их можно формировать руками.

## Задача

Я сформировал для себя следующую задачу, которую я хочу научиться решать.
Я хочу сделать git репозтоторий с несколькими комитами:

 * первый комит от 2001-01-01 от пользователя robot_1@example.com
   создан файл aaa.md, содержимое:

<pre><code>
line 1
line 2
line 3
</code></pre>

 * второй комит от 2002-01-01 от пользователя robot_2@example.com
   файл aaa.md изменен. Новое содержимое:

<pre><code>
line 1
line 22 АБВ
line 3
</code></pre>

 * третий комит от 2003-01-01 от пользователя robot_2@example.com
   добавлено 2 новых файл bbb.md и ccc.md оба нулевой длины

## Решение

Я нашел в интернете замечательную [серию статей про внутренности
git][git_guts]. В этих статья совершенно прекрасно объяснено как
git хранит данные и как с ними работать. Огромный респект и уважуха
автору.

В этих статьях сильно больше информации чем мне нужно для того чтобы решить
мою задачу. Вот тезисы из этих статей, которые мне важны для решения задачи:

 * объекты в git бывают четырех типов — blob, tree, commit и tag
 * Расположены все объекты в каталоге .git/objects.
 * .git/objects/a4/b7fce097055c3cbd6879db9625f9a3890cc409 — это объект
   a4b7fce097055c3cbd6879db9625f9a3890cc409
 * Объект blob (Binary Large Object) — это содержимое файла без имени
 * Пример низкоуровневого создания blob:

<pre><code>
$ mkdir ~/tmp/gitguts
$ cd ~/tmp/gitguts

$ git init
Initialized empty Git repository in .git/

$ echo 'Hello, World!' > tutorial.txt

$ git hash-object -w tutorial.txt
8ab686eafeb1f44702738c8b0f24f2567c36da6d

$ find .git/objects -type f
.git/objects/8a/b686eafeb1f44702738c8b0f24f2567c36da6d
</code></pre>

 * Объект tree — описывает какие файлы с какими правами находятся в каталоге
 * Пример низкоуровневое создания tree:

<pre><code>
$ mkdir ~/tmp/gitgut3
$ cd ~/tmp/gitgut3

$ git init
Initialized empty Git repository in .git/

$ echo "File1" > file1
$ echo "File2" > file2

$ git hash-object -w file1
03f128cf48cb203d938805e9f3e13b808d1773e9
$ git hash-object -w file2
b973e639605e63466ea5ba09b04a545f16946ca8

$ echo -e "100640 blob 03f128cf48cb203d938805e9f3e13b808d1773e9\tfile1
100640 blob b973e639605e63466ea5ba09b04a545f16946ca8\tfile2" | git mktree
b2efb2a7e48025c4d185080412a6ba1121ee6c59

$ ls .git/objects/b2/efb2a7e48025c4d185080412a6ba1121ee6c59
.git/objects/b2/efb2a7e48025c4d185080412a6ba1121ee6c59
</code></pre>

 * На любой комит можно сказат 'git ls-tree commit_sha1' и посмотреть
   содержимое объекта tree
 * Объект tree может содержать ссылки как на blob, так и на другие tree
 * Объект commit содержит ссылку на один объект tree, а так же ссылки на
   родительские комиты, информацию о коммитере и commit message
 * Посмотреть содержимое commit объекта можно с помощью комманды
   'git cat-file commit commit_sha1'
 * Пример ручного создания объекта commit:

<pre><code>
$ mkdir ~/tmp/gitguts4
$ cd ~/tmp/gitguts4
$ git init
Initialized empty Git repository in .git/

$ echo "file1" > file1
$ echo "file2" > file2
$ git hash-object -w file1
e2129701f1a4d54dc44f03c93bca0a2aec7c5449
$ git hash-object -w file2
6c493ff740f9380390d5c9ddef4af18697ac9375

$ echo -e "10644 blob e2129701f1a4d54dc44f03c93bca0a2aec7c5449\tfile1
10644 blob 6c493ff740f9380390d5c9ddef4af18697ac9375\tfile2" | git mktree
eaa27839f1ccaa6e087202ec96c479ee2c93b71e

$ export GIT_AUTHOR_NAME="Git Guts"
$ export GIT_AUTHOR_EMAIL="gitguts@localhost"
$ export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
$ export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

$ echo "Initial commit" | faketime 20000101 git commit-tree  eaa27839f1ccaa6e087202ec96c479ee2c93b71e
6d8e5c7bab119e7b746e76259b37513cb5cc84e9

$ git cat-file commit 6d8e5c7bab119e7b746e76259b37513cb5cc84e9
tree eaa27839f1ccaa6e087202ec96c479ee2c93b71e
author Git Guts <gitguts@localhost> 946684800 +0000
committer Git Guts <gitguts@localhost> 946684800 +0000

Initial commit
</code></pre>

 * Ветка — это ссылка на определенный комит. Физически это просто файл,
   лежащий в .git/refs/heads/ в котором записана sha1 комита
 * В последнем примере ветку можно было создать так

<pre><code>
$ echo '6d8e5c7bab119e7b746e76259b37513cb5cc84e9' > .git/refs/heads/master
$ git branch -a
* master
</code></pre>

Все. Этих данных достаточно для того чтобы решить мою задачу. Теперь мне нужно
написать скрипт, который будет создавать репозиторий с комитами из условия
задачи.

## Perl

Пошел искать как бы успросить всю эту работу из Perl. Нашел библиотеку
[Git::Raw][gr]. Про нее есть [отзыв][review]:

> I really recommend this module if you have to handle git repository
> directly! :-)

Побробовал этот модуль, но он не подошел — возникли сложности со сборкой его и
всех его зависимостей в deb пакеты. Нашел другой модуль
[Git::Repository][git_repository], оказалось что он уже запакетирован в deb
и есть в репозитории ubutnu. Поставил — и это оказался очень хороший модуль.

И с помощью [Git::Repository][git_repository] я написал [perl скрипт][github],
которы выполняет ровно ту задачу, которую я собирался решить.

Получилось достоточно забавно — я руками создаю все фалый в базе данных git,
создаю комиты и создаю ветку master, но настоящие файлы в рабочей копии я не
создаю, поэтому после выполнения скрипта git status говорит что рабочая копия
отличается от комита, но для моей задачи это не важно, поэтому я не стал
это исправлять.

    bessarabov@rofl:/tmp/nSUTrsQ7gU$ git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #       deleted:    aaa.md
    #       deleted:    bbb.md
    #       deleted:    ccc.md
    #

[git_guts]: http://los-t.livejournal.com/tag/git%20guts
[git_raw]: https://metacpan.org/pod/Git::Raw
[git_repository]: https://metacpan.org/release/Git-Repository
[review]: http://cpanratings.perl.org/dist/Git-Raw
[github]: https://github.com/bessarabov/git_internals_experiment

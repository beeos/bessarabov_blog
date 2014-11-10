# Эксперименты с докерными volumes

date_time: 2014-11-11 01:49:01 MSK

Я понял что я не до конца понимаю как все устроно в docker volumes, поэтому
решил провести пару экспериментов.

В [документации][d] написано что бываеют 2 штуки:

 * Data volumes
 * Data volume containers

## Эксперимент 1. Пробрасывание локальной папки в докер.

Итак, у меня есть хост машина по имени air и на ней я запускаю контейнер. Хочу
сделать так чтобы папка /Users/bessarabov/e1 из хост машины была доступна в
контейнере как /e1

    docker run \
        -it \
        --volume /Users/bessarabov/e1:/e1 \
        ubuntu:14.04 \
        /bin/bash

Создаю в контейнере файл:

    root@6c9da8f68a9e:/# echo 'from container' > /e1/1

И убеждаюсь что он виден на хост машине:

    bessarabov@5:~/e1$ cat 1
    from container

И проверяю что это работает в обратную сторону. Создаю файл на хост машине:

    bessarabov@5:~/e1$ echo 'from host' > 2

И в контейнере он появился:

    root@6c9da8f68a9e:/# cat /e1/2
    from host

## Эксперимент 2. Какие настройки контейнера?

Продолжаю работать с контейнером из эксперимента 1. На хост машине запускаю
команду чтобы посмотреть настройки контейнера:

    $ docker inspect --format="{{.Volumes}}" 6c9da8f68a9e
    map[/e1:/Users/bessarabov/e1]

А вот [полный вывод команды][inspect1] 'docker inspect 6c9da8f68a9e'.

## Эксперимент 3. --volumes-from

Продолжаю работать с тем же конейнером. Хочу понять как будет действовать
команда --volumes-from. Запускаю новый контейнер:

    docker run \
        -it \
        --volumes-from 6c9da8f68a9e \
        ubuntu:14.04 \
        /bin/bash

Смотрю на хост машине его настроки:

    $ docker inspect --format="{{.Volumes}}" 27f31c5bc0ee
    map[/e1:/Users/bessarabov/e1]

А вот [полный вывод команды][inspect2] 'docker inspect 27f31c5bc0ee'.

А вот [diff этих двух inspect][diff].

## Эксперимент 4. --volume с одним параметром

Создаю новый контейнер. Но в отличии от эксперимента 1, передаю только один
параметр в --volume:

    docker run \
        -it \
        --volume /e4 \
        ubuntu:14.04 \
        /bin/bash

Вот его настройки:

    $ docker inspect --format="{{.Volumes}}" d1849bdd9153
    map[/e4:/mnt/sda1/var/lib/docker/vfs/dir/56ce42d7366c198780ed3aa3dfed0a1c194a89cbfc6fa83121f07a58a28ff7ef]

И полный вывод команды [docker inspect][inspect4].

В контенере создаю файл

    root@d1849bdd9153:/# echo 'from container e4' > /e4/4

Папки по имени /mnt/sda1/var/lib/docker/vfs/dir/56ce42d7366c198780ed3aa3dfed0a1c194a89cbfc6fa83121f07a58a28ff7ef
на моем маке не оказалось. Я залез в виртуальную машину докера 'boot2docker ssh'
и там такая папка обнаружилась (только пришлось сделать sudo su):

    root@boot2docker:~# cat /mnt/sda1/var/lib/docker/vfs/dir/56ce42d7366c198780ed3aa3dfed0a1c194a89cbfc6fa83121f07a58a28ff7ef/4
    from container e4

## Эксперимент 5. Еще один контейнер и --volumes-from

Создаю новый, но подключаю к новому все volumes из контенера, созданного в
эксперименте 4.

    docker run \
        -it \
        --volumes-from d1849bdd9153 \
        ubuntu:14.04 \
        /bin/bash

В этом новом контенере я вижу то же что и прошлый раз:

    root@77431816df7d:/# cat /e4/4
    from container e4

Смотрю на хост машине данне об про этот контенер и вижу точно такие же
настройки, как и в случае эксперимента 4:

    $ docker inspect --format="{{.Volumes}}" 77431816df7d
    map[/e4:/mnt/sda1/var/lib/docker/vfs/dir/56ce42d7366c198780ed3aa3dfed0a1c194a89cbfc6fa83121f07a58a28ff7ef]

Ну и полный вывод команды [docker inspect][inspect5].

## Резюме и TODO

После того как я провел все эти небольшие эксперименты и еще раз прочитал
[доку][d], все стало понятнее.

Но еще остались моменты, которые я хочу прояснить.

Во первых, можно ли создать контенер в котором создан volume /data, а потом
прикрутить этот volume в другой контенер по другому пути (например, /site).

Во вторых, хочу проэксперементирвать, чтобы убедится что вот эта фраза правда:

> If you remove containers that mount volumes, including the initial dbdata
> container, or the subsequent containers db1 and db2, the volumes will not be
> deleted. To delete the volume from disk, you must explicitly call docker rm -v
> against the last container with a reference to the volume. This allows you to
> upgrade, or effectively migrate data volumes between containers.

(у меня, нет причин не доверять документации докера, но если это правда, то
получается что все что все volumes продолжают хранится на машине на которой
живет докер).

 [d]: https://docs.docker.com/userguide/dockervolumes/
 [inspect1]: https://gist.github.com/bessarabov/a349b0fc1357b1f54df6
 [inspect2]: https://gist.github.com/bessarabov/82849ff6819955ef9d5f
 [diff]: https://gist.github.com/bessarabov/561a32831416abb9614f
 [inspect4]: https://gist.github.com/bessarabov/0d2c70529705e79729d6
 [inspect5]: https://gist.github.com/bessarabov/a0fc58f8ae396a381d8d

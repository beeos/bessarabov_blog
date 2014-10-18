# Команды для работы с докером

date_time: 2014-10-19 01:22:45 MSK

## Образы

    # Скачать образ ubuntu с тегом latest
    docker pull ubuntu

    # То же самое, но указанное явно
    docker pull ubuntu:latest

    # Скачать все теги образа ubuntu
    docker pull --all-tags ubuntu

    # Получить список образов, которые есть на локальной машине
    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    ubuntu              14.04               9cbaf023786c        4 days ago          192.8 MB

    # Удалить образ ubuntu:latest (так же можно удалять используя IMAGE ID)
    docker rmi ubuntu

## Работа с контейнерами

    # Запустить контенейр в интерактивном режиме
    # (ключи -i -t можно объединить в -it)
    $ docker run -i -t ubuntu:14.04 /bin/bash
    root@b9ee3d48bf59:/#

    # Получить список контенеров
    # (если не указать ключ -a, то будет показаны только работающие контенеры)
    $ docker ps -a
    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
    7aacffdfb531        ubuntu:14.04        "/bin/bash"         3 seconds ago       Exited (0) 1 seconds ago                       silly_hopper

    # Удалить контенер (можно удалить только остановленный контейнер).
    # Команде можно передать как CONTAINER ID, так и NAME
    docker rm 7aacffdfb531

    # Запустить контейнер и автоматически удалить его после того как он
    # остановится
    docker run --rm -it ubuntu:14.04 /bin/bash

    # Запустить контейнер и указать ему имя 'sample'. Если явно не указывать
    # имя, то оно будет создано автоматически, типа 'silly_hopper'
    docker run -it --name sample ubuntu:14.04 /bin/bash

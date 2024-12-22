FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Описание пакетов:
# 'openssh-client'         - для работы с Qnap и для команды ssh-keyscan   
# 'libcurl4-openssl-dev'   - для сборки проектов с использованием зависимости на библиотеку curl (в частности сабмодулем fcurl)
# 'libgl1-mesa-dev'        - дополнительный пакет для сборки гуишный проектов
# 'wget'                   - инструмент для скачивания зависимостей по сети, из локального репозитория
# 'libssl-dev''libssh-dev' - для установки platform2
# 'build-essential' 'ninja-build' 'libglib2.0-0' - набор инструментов для сборки проектов

RUN apt update && \
        apt install -y \
                openssh-client \
                git \
                build-essential \
                ninja-build \
                python3 \
                libglib2.0-0 \
                libgl1-mesa-dev \
                wget \
                libssl-dev \
                libssh-dev \
                libcurl4-openssl-dev \
                ccache

RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh
COPY id_rsa /root/.ssh/
RUN ssh-keyscan internal.rtp.by >> /root/.ssh/known_hosts
RUN ssh-keyscan 192.168.1.1 >> /root/.ssh/known_hosts
RUN ssh-keyscan 192.168.1.2 >> /root/.ssh/known_hosts

#Заходим в каталог, куда установился ccache и копируем ccache в каталог /usr/local/bin
RUN cd /usr/bin/ && cp ccache /usr/local/bin/

#Прописываем линки для gcc, g++, cc и c++
RUN ln -s /usr/local/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/local/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/local/bin/ccache /usr/local/bin/cc
RUN ln -s /usr/local/bin/ccache /usr/local/bin/c++

#Указываем максимальный размер памяти на диске, используемый ccache:
ENV CCACHE_MAXSIZE=15G
ENV CCACHE_DIR=/ccache/u22/project

RUN wget http://192.168.1.3:8250/u22/qt-libpack/5.12.12.ver.84/qt-libpack-5.12.12-Ubuntu22.04-amd64-ver_84.deb
RUN dpkg -i qt-libpack-5.12.12-Ubuntu22.04-amd64-ver_84.deb

RUN wget http://192.168.1.3:8150/cmake/3.27.7/cmake-3.27.7_u22_amd64.deb
RUN dpkg -i cmake-3.27.7_u22_amd64.deb

#Все пакеты 'libevent' необходимы для установки tmll
#Пакет 'libfftw3-3' необходим для df-pf-libs. Пакет 'libfftw3-dev' необходим для сборки проекта
#Пакеты 'libportaudio*' необходимы для сборки проекта. Это 'libportaudio2 libportaudiocpp0 libportaudio-ocaml libportaudio-ocaml-dev'
#Пакеты 'libnss3 libxss1 libxslt1.1' необходимы для сборки проекта
#Пакет libssl1.1 необходим для tmll и platform, WebEngine. Также необходим для корректной работы qt5.12.12.
#libnotify4 - библиотека для отправки уведомлений рабочего стола службе уведомлений, необходима для Platform2-2.5

RUN apt install -y \
            libevent-2.1-7 \
            libevent-core-2.1-7 \
            libevent-extra-2.1-7 \
            libevent-pthreads-2.1-7 \
            libevent-openssl-2.1-7 \
            python3-pip \
            libqt5network5 \
            libqt5gui5 \
            libfftw3-dev \
            libfftw3-3 \
            libportaudio* \
            libnss3 \
            libxss1 \
            libxslt1.1 \
            libre2-9 \
            libvpx7 \
            libnotify4

RUN pip install requests

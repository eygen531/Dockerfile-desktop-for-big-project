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

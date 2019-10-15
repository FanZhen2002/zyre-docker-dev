FROM ubuntu:xenial
MAINTAINER zyre Developers <zeromq-dev@lists.zeromq.org>

# 国内镜像
COPY ./sources.list /etc/apt/
RUN chown root:root /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes build-essential git-core libtool autotools-dev autoconf automake pkg-config unzip libkrb5-dev cmake software-properties-common fonts-powerline zsh tmux curl wget clang-format ccache openssh-client sudo 

# install vim8
RUN add-apt-repository ppa:jonathonf/vim
RUN apt-get update && apt-get install -y vim-nox-py2


RUN useradd -d /home/zmq -m -s /bin/bash zmq && \
    adduser zmq sudo && \
    adduser root sudo && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

USER zmq

# Prepend ccache into the PATH
RUN echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc

# install oh-my-zsh
ENV TERM xterm
ENV ZSH_THEME agnoster
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN mkdir /home/zmq/tmp-deps
WORKDIR /home/zmq/tmp-deps
RUN git clone https://github.com/zeromq/libzmq.git libzmq
WORKDIR /home/zmq/tmp-deps/libzmq
RUN ./autogen.sh 2> /dev/null
RUN ./configure --quiet --without-docs
RUN make
RUN sudo make install
RUN sudo ldconfig

WORKDIR /home/zmq/tmp-deps
RUN git clone https://github.com/zeromq/czmq.git czmq
WORKDIR /home/zmq/tmp-deps/czmq
RUN ./autogen.sh 2> /dev/null
RUN ./configure --quiet --without-docs
RUN make
RUN sudo make install
RUN sudo ldconfig

WORKDIR /home/zmq
RUN git clone https://github.com/zeromq/zyre zyre
WORKDIR /home/zmq/zyre
RUN ./autogen.sh 2> /dev/null
RUN ./configure --quiet --without-docs
RUN make
RUN sudo make install
RUN sudo ldconfig

# start zsh
CMD ["zsh"]

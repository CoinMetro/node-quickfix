FROM ubuntu:xenial

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update 
RUN apt install git make g++ libxml2-dev zlib1g-dev \
    libtool m4 autoconf unittest++ curl psmisc ruby checkinstall -y

ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN . $NVM_DIR/nvm.sh && nvm install 10 && npm install -g node-gyp node-pre-gyp

RUN apt install wget

RUN wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz \
    && tar -xf openssl-1.1.1g.tar.gz \
    && cd openssl-1.1.1g \
    && ./config shared zlib \
    && make \
    # && make test \
    && make install \
    && echo "/usr/local/ssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1c.conf \ 
    && ldconfig -v

RUN openssl version -a

RUN git clone https://github.com/karopawil/quickfix.git \
    && cd quickfix \
    && ./bootstrap \
    && ./configure \
    && cd UnitTest++ \
    && make

ENV CXXFLAGS=-fPIC
ENV CFLAGS=-fPIC
RUN cd quickfix \
    && ./bootstrap \
    && ./configure --enable-static=yes --enable-shared=no --with-openssl \
    && make \
    # && make check \
    && make install \
    && cp config.h /usr/local/include/quickfix

RUN mkdir /output-files

COPY . /node-quickfix

ENV LD_LIBRARY_PATH=/usr/local/lib 

RUN cd node-quickfix \
    && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh \
    && nvm use 10 \
    && npm install \
    && npm run configure \
    && npm run build \
    && npm run test \
    && npm run package

RUN cd node-quickfix \
    && find -name *.tar.gz -exec cp {} /output-files/ \;

RUN ls /output-files
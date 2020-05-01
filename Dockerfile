FROM ubuntu:xenial

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update 
RUN apt install git make g++ openssl libssl-dev libxml2-dev zlib1g-dev \
    libtool m4 autoconf unittest++ curl psmisc ruby -y

ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN . $NVM_DIR/nvm.sh && nvm install 6 && nvm install 7 \
    && nvm install 8 && nvm install 9 && nvm install 10 \
    && nvm use 6 && npm install -g node-gyp node-pre-gyp;

RUN git clone https://github.com/karopawil/quickfix.git
RUN cd quickfix \
    && git reset a4b1af3 --hard \
    && ./bootstrap \
    && ./configure \
    && cd UnitTest++ \
    && make

ENV CXXFLAGS=-fPIC
ENV CFLAGS=-fPIC
RUN cd quickfix \
    && ./bootstrap \
    && ./configure \
    --enable-static=yes --enable-shared=no \
    --with-openssl \
    && make \
   # && make check \
    && make install \
    && cp config.h /usr/local/include/quickfix

RUN mkdir /output-files

COPY . /node-quickfix

ENV LD_LIBRARY_PATH=/usr/local/lib 

RUN cd node-quickfix && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh && nvm use 6 \ 
    && npm install && npm run configure && npm run build && npm run test \
    && npm run package && find -name *.tar.gz -exec cp {} /output-files/ \;

RUN cd node-quickfix && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh && nvm use 7 && nvm reinstall-packages 6 \
    && npm install && npm run configure && npm run build && npm run test \
    && npm run package && find -name *.tar.gz -exec cp {} /output-files/ \;

RUN cd node-quickfix && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh && nvm use 8 && nvm reinstall-packages 6 \
    && npm install && npm run configure && npm run build && npm run test \
    && npm run package && find -name *.tar.gz -exec cp {} /output-files/ \;

RUN cd node-quickfix && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh && nvm use 9 && nvm reinstall-packages 6 \
    && npm install && npm run configure && npm run build && npm run test \
    && npm run package && find -name *.tar.gz -exec cp {} /output-files/ \;

RUN cd node-quickfix && rm -rf build node_modules \
    && . $NVM_DIR/nvm.sh && nvm use 10 && nvm reinstall-packages 6 \
    && npm install && npm run configure && npm run build && npm run test  \
    && npm run package && find -name *.tar.gz -exec cp {} /output-files/ \;
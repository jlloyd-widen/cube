FROM rustembedded/cross:x86_64-unknown-linux-musl

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y curl pkg-config wget llvm libclang-dev musl-tools clang

RUN ln -s /usr/include/x86_64-linux-gnu/asm /usr/include/x86_64-linux-musl/asm && \
    ln -s /usr/include/asm-generic /usr/include/x86_64-linux-musl/asm-generic && \
    ln -s /usr/include/linux /usr/include/x86_64-linux-musl/linux && \
    ln -s /usr/bin/g++ /usr/bin/musl-g++

RUN mkdir /musl

RUN wget https://www.openssl.org/source/openssl-1.1.1i.tar.gz -O - | tar -xz &&\
    cd openssl-1.1.1i && \
    CC="musl-gcc -fPIE -pie" ./Configure no-shared no-async --prefix=/musl --openssldir=/musl/ssl linux-x86_64 && \
    make depend && \
    make -j $(nproc) && \
    make install_sw && \
    make install_ssldirs && \
    cd .. && rm -rf openssl-1.1.1i

ENV PKG_CONFIG_ALLOW_CROSS=true
ENV PKG_CONFIG_ALL_STATIC=true
ENV RUSTFLAGS="-C target-feature=-crt-static"

ENV OPENSSL_STATIC=true
ENV OPENSSL_DIR=/musl


ENV PATH="/cargo/bin:$PATH"

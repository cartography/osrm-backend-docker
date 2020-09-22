FROM ubuntu:xenial
MAINTAINER Alex Newman <alex@newman.pro>

# Let the container know that there is no TTY
ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages for proper system state
RUN apt-get -y update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libboost-all-dev \
    libbz2-dev \
    libstxxl-dev \
    libstxxl-doc \
    libstxxl1v5 \
    libtbb-dev \
    libxml2-dev \
    libzip-dev \
    lua5.1 \
    liblua5.1-0-dev \
    libluabind-dev \
    libluajit-5.1-dev \
    pkg-config

RUN mkdir -p /osrm-build \
 && mkdir -p /osrm-data

WORKDIR /osrm-build

RUN curl --silent -L https://github.com/Project-OSRM/osrm-backend/archive/v5.4.0.tar.gz -o v5.4.0.tar.gz \
 && tar xzf v5.4.0.tar.gz \
 && mv osrm-backend-5.4.0 /osrm-src
COPY profiles/* /osrm-src/profiles/
RUN cmake /osrm-src \
 && make \
 && mv /osrm-src/profiles/ profiles \
 && mv profiles/lib/ lib \
 && echo "disk=/tmp/stxxl,25000,syscall" > .stxxl \
 && rm -rf /osrm-src  \
 && rm -f v5.4.0.tar.gz

# --------------------------------

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

VOLUME /osrm-build/profiles

# --------------------------------

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000

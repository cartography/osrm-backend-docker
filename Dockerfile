FROM ubuntu:bionic as builder

ENV OSRM_VERSION=5.4.0

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

RUN mkdir -p /osrm-build

WORKDIR /osrm-build

RUN curl --silent -L https://github.com/Project-OSRM/osrm-backend/archive/v${OSRM_VERSION}.tar.gz -o v${OSRM_VERSION}.tar.gz \
 && tar xzf v${OSRM_VERSION}.tar.gz \
 && mv osrm-backend-${OSRM_VERSION} /osrm-src
COPY profiles/* /osrm-src/profiles/
# fix for https://github.com/Project-OSRM/osrm-backend/issues/5143#issuecomment-585481282
RUN sed -i '/#include <utility>/a #undef BLOCK_SIZE' /osrm-src/include/util/range_table.hpp
RUN cmake /osrm-src \
 && make


FROM ubuntu:bionic
WORKDIR /deployments
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh
RUN addgroup appuser && adduser --disabled-password appuser --ingroup appuser --gecos ""
RUN mkdir osrm-data && chown appuser:appuser . && chown appuser:appuser osrm-data

COPY --from=builder /osrm-build/lib* ./
COPY --from=builder /osrm-build/osrm-datastore ./
COPY --from=builder /osrm-build/osrm-extract ./
COPY --from=builder /osrm-build/osrm-routed ./
COPY --from=builder /osrm-build/osrm-contract ./
COPY --from=builder osrm-src/profiles profiles
RUN mv profiles/lib/ lib
RUN echo "disk=/tmp/stxxl,25000,syscall" > .stxxl

RUN apt-get -y update && apt-get install -y \
    curl \
    libstxxl1v5  \
    libtbb2 \
    libluajit-5.1 \
    libboost-all-dev \
    libluabind-dev


RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER appuser

# --------------------------------

VOLUME /deployments/profiles
ENTRYPOINT ["/deployments/docker-entrypoint.sh"]

EXPOSE 5000

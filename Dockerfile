FROM ubuntu:xenial-20210114
MAINTAINER Oliver Gugger <gugger@gmail.com>

ARG USER_ID
ARG GROUP_ID
ARG VERSION

ENV USER htmlcoin
ENV COMPONENT ${USER}
ENV HOME /${USER}

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} ${USER} \
	&& useradd -u ${USER_ID} -g ${USER} -s /bin/bash -m -d ${HOME} ${USER}

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV VERSION ${VERSION:-2.0.0.1}
RUN set -x \
    && mkdir -p /opt/${COMPONENT}/bin 

RUN apt-get update && apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils git cmake libboost-all-dev software-properties-common \
    && apt-add-repository ppa:bitcoin/bitcoin \
    && apt-get update && apt-get install -y libdb4.8-dev libdb4.8++-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler

RUN set -x \
    && cd /tmp \
    && git clone https://github.com/HTMLCOIN/HTML5 --recursive \
    && cd HTML5 \
    && ./autogen.sh \
    && ./configure \
    && make -j2

RUN set -x \
    && mv /tmp/HTML5/src/htmlcoin-cli /opt/${COMPONENT}/bin/ \
    && mv /tmp/HTML5/src/htmlcoin-tx /opt/${COMPONENT}/bin/ \
    && mv /tmp/HTML5/src/htmlcoind /opt/${COMPONENT}/bin/ \
    && mv /tmp/HTML5/src/qt/htmlcoin-qt /opt/${COMPONENT}/bin

RUN set -x && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${HOME}"]
WORKDIR ${HOME}
ADD ./bin /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-unprivileged.sh"]

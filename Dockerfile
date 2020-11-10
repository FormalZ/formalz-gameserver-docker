FROM openjdk:11-jdk-slim

# grab tini for signal processing and zombie killing
ENV TINI_VERSION v0.18.0
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl gpg dirmngr \
        && curl -k -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
        && curl -k -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --keyserver "$server" --recv-keys  595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && break || : ; \
    done \
        && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
        && rm -r "$GNUPGHOME" /usr/local/bin/tini.asc && unset GNUPGHOME \
        && chmod +x /usr/local/bin/tini \
        # installation cleanup
        && apt-get remove --purge -y curl \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./overlay /

ENV FORMALZ_VERSION 1.0.1
ENV FORMALZ_DOWNLOAD_BASE_URL https://github.com/e-ucm/formalz-game/releases/download/${FORMALZ_VERSION}
ENV FORMALZ_DOWNLOAD_URL_GAMESERVER ${FORMALZ_DOWNLOAD_BASE_URL}/formalz-gameserver_${FORMALZ_VERSION}.tar.gz
ENV FORMALZ_GAMESERVER_SHA256 aeb8a0472ff1b2f4b74a625728f6b5fbf3957423b8920067d061d31ec7c96dea

RUN set -ex; \
    buildDeps='curl'; \
    apt-get update; \
    apt-get install -y --no-install-recommends $buildDeps; \
    curl -fsSL "$FORMALZ_DOWNLOAD_URL_GAMESERVER" -o /tmp/formalz-gameserver.tar.gz; \
    echo "$FORMALZ_GAMESERVER_SHA256 /tmp/formalz-gameserver.tar.gz" | sha256sum -c -; \
    mkdir /app; \
    tar -xzf /tmp/formalz-gameserver.tar.gz --strip-components=1 -C /app > /dev/null 2>&1; \
    useradd -s /bin/bash formalz; \
    chown formalz: -R /app; \
    apt-get purge -y --auto-remove $buildDeps; \
    rm -fr /tmp/*;

WORKDIR /app

USER formalz
ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/bin/entrypoint"]
CMD ["/usr/bin/server", "start"]

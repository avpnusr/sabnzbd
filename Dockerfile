FROM alpine:3.10
LABEL maintainer="avpnusr"
ARG PAR2TAG=v0.8.1
ARG GITTAG=2.3.9

COPY ./requirements.txt /

RUN buildDeps="gcc g++ git mercurial make automake autoconf python-dev openssl-dev libffi-dev musl-dev" \
  && apk --update --no-cache add $buildDeps \
  && apk --no-cache add \
    python \
    py2-pip py2-openssl \
    ffmpeg-libs \
    ffmpeg \
    unrar \
    openssl \
    ca-certificates \
    p7zip \
    libgomp \
&& pip install --upgrade pip --no-cache-dir \
&& pip install -r /requirements.txt --upgrade --no-cache-dir \
&& git clone --depth 1 --branch ${PAR2TAG} https://github.com/Parchive/par2cmdline.git \
&& cd /par2cmdline \
&& sh automake.sh \
&& ./configure \
&& make \
&& make install \
&& cd / \
&& rm -rf par2cmdline \
&& git clone --depth 1 --branch ${GITTAG} https://github.com/sabnzbd/sabnzbd.git \
&& cd /sabnzbd \
&& python tools/make_mo.py \
&& sed -i "/DEF_COMPLETE_DIR/c\DEF_COMPLETE_DIR = os.path.normpath(\"/complete\")" /sabnzbd/sabnzbd/constants.py \
&& sed -i "/DEF_DOWNLOAD_DIR/c\DEF_DOWNLOAD_DIR = os.path.normpath(\"/incomplete\")" /sabnzbd/sabnzbd/constants.py \
&& cd / \
&& rm -rf /yenc \
&& apk del $buildDeps \
&& rm -rf \
    /var/cache/apk/* \
    /par2cmdline \
    /requirements.txt \
    /sabnzbd/.git \
    /tmp/* \
&& addgroup -S sabnzbd \
&& adduser -S sabnzbd -G sabnzbd \
&& mkdir /config /complete /incomplete \
&& chown sabnzbd:sabnzbd /config /complete /incomplete

USER sabnzbd

EXPOSE 8080

HEALTHCHECK --interval=120s --timeout=15s --start-period=120s --retries=3 \
            CMD wget --no-check-certificate --quiet --spider 'http://localhost:8080' && echo "Healthcheck successful." || exit 1

VOLUME ["/config", "/complete", "/incomplete"]

ENTRYPOINT [ "/usr/bin/python", "/sabnzbd/SABnzbd.py", "-f", "/config/sabnzbd.ini", "-b", "0", "-s", "0.0.0.0:8080" ]

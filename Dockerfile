FROM alpine:3.14
LABEL maintainer="avpnusr"
ARG SABTAG=4.5.1

RUN buildDeps="gcc g++ git mercurial make automake autoconf python3-dev openssl-dev libffi-dev musl-dev" \
  && apk --update --no-cache add $buildDeps \
  && apk --no-cache add \
    python3 \
    py3-pip py3-openssl py3-cryptography py3-wheel \
    ffmpeg-libs \
    ffmpeg \
    unrar \
    openssl \
    ca-certificates \
    p7zip \
    libgomp \
&& python3 -m pip install --upgrade pip --no-cache-dir \
&& git clone --branch ${SABTAG} https://github.com/sabnzbd/sabnzbd.git \
&& cat /sabnzbd/requirements.txt | grep -v cryptography > /sabnzbd/requirements_nocrypto.txt \
&& python3 -m pip install -r /sabnzbd/requirements_nocrypto.txt --upgrade --no-cache-dir --ignore-installed six \
&& git clone https://github.com/animetosho/par2cmdline-turbo.git \
&& cd /par2cmdline-turbo \
&& aclocal \
&& automake --add-missing \
&& autoconf \
&& ./configure \
&& make \
&& make install \
&& cd / \
&& rm -rf par2cmdline-turbo \
&& cd /sabnzbd \
&& python3 tools/make_mo.py \
# Changing default constants for matching complete / incomplete volume in this container, if you start from default config
# Thx @ ToCa
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
            CMD wget --no-check-certificate --quiet --spider 'http://localhost:8080' && echo "Everything is fine..." || exit 1

VOLUME ["/config", "/complete", "/incomplete"]

ENTRYPOINT [ "/usr/bin/python3", "/sabnzbd/SABnzbd.py", "-f", "/config/sabnzbd.ini", "-b", "0", "-s", "0.0.0.0:8080" ]

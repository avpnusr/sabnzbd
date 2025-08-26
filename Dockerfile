FROM alpine:3.22
LABEL maintainer="avpnusr"
ARG TARGETARCH TARGETVARIANT SABTAG=4.5.3

RUN CPUARCH=${TARGETARCH}${TARGETVARIANT} \
&& if [ $CPUARCH == "armv6" ]; then export QEMU_CPU="arm1176"; fi \
&& apk add -U --update --no-cache --virtual=build-dependencies \
  libffi-dev \
  openssl-dev \
  python3-dev \
  py3-pip \
  curl \
  git \
  cargo \
  rust \
&& apk add -U --update --no-cache \
    python3 \
    ffmpeg-libs \
    ffmpeg \
    7zip \
    libstdc++ \
    libgcc \
    libc6-compat \
&& UNRARURL=$(curl -sL "https://api.github.com/repos/avpnusr/unrar-alpine/releases/latest" | grep -B1 ${TARGETARCH}${TARGETVARIANT} | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*") \
&& curl -sL $UNRARURL -o /usr/local/bin/unrar \
&& chmod 0755 /usr/local/bin/unrar \
&& pip config set global.break-system-packages true \
&& pip install -U --no-cache-dir pip wheel \
&& git clone --branch ${SABTAG} https://github.com/sabnzbd/sabnzbd.git \
&& sed -i '1 i\--find-links https://pypi.gkkh.de/sabnzbd/' /sabnzbd/requirements.txt \
&& pip install -U --no-cache-dir --find-links https://pypi.gkkh.de/sabnzbd/ -r /sabnzbd/requirements.txt \
&& cd /sabnzbd \
&& python3 tools/make_mo.py \
&& cd / \
&& PAR2URL=$(curl -sL "https://api.github.com/repos/avpnusr/par2cmdturbo-build/releases/latest" | grep -B1 ${TARGETARCH}${TARGETVARIANT} | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*") \
&& curl -sL $PAR2URL -o /usr/local/bin/par2 \
&& chmod 0755 /usr/local/bin/par2 \
&& ln -s /usr/local/bin/par2 /usr/local/bin/par2create \
&& ln -s /usr/local/bin/par2 /usr/local/bin/par2repair \
&& ln -s /usr/local/bin/par2 /usr/local/bin/par2verify \
# Changing default constants for matching complete / incomplete volume in this container, if you start from default config
# Thx @ ToCa
&& sed -i "/DEF_COMPLETE_DIR/c\DEF_COMPLETE_DIR = os.path.normpath(\"/complete\")" /sabnzbd/sabnzbd/constants.py \
&& sed -i "/DEF_DOWNLOAD_DIR/c\DEF_DOWNLOAD_DIR = os.path.normpath(\"/incomplete\")" /sabnzbd/sabnzbd/constants.py \
&& apk del --purge build-dependencies \
&& rm -rf \
    /var/cache/apk/* \
    /par2cmdline-turbo \
    /sabnzbd/.git \
    /tmp/* \
    $HOME/.cache \
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
![SABnzbd Logo](https://www.usenet.com/wp-content/uploads/2017/05/Screenshot_2-1.png)

**SABnzbd in container with multiarch support**
===

Image is automatically updated, when a new version of SABnzbd arrives on GitHub.   
Supported platforms are amd64, arm64, armv7 and armv6

Status from last build
-----
![SABnzbd Docker Build](https://github.com/avpnusr/sabnzbd/workflows/build/badge.svg)

The container is lightweight and based on alpine linux.

You can find the weekly dev-build from SABnzbd in this **[container](https://hub.docker.com/r/avpnusr/sabnzbd-dev)**

Versions in the latest image
-----
- [SABnzbd](https://github.com/sabnzbd/sabnzbd "SABnzbd Project Homepage") version: 4.5.2
- par2cmdturbo from [par2cmdturbo](https://github.com/animetosho/par2cmdline-turbo) version: 1.3.0

Start your container
-----
- For **[/config/location]**, use the folder, where your **sabnzbd.ini** file is stored.
- For **[/complete/folder]**, use the folder, where your completed downloads will be stored.
- For **[/incomplete/folder]**, use the folder, where the temporary files will be stored, until download is finished.

````
docker run -d \
  -v [/config/location]:/config \
  -v [/complete/folder]:/complete \
  -v [/incomplete/folder]:/incomplete \
  -p 8080:8080 \
  --user=[UID:GID] \
  --restart=unless-stopped ghcr.io/avpnusr/sabnzbd:latest

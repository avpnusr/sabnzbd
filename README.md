![SABnzbd Logo](https://www.usenet.com/wp-content/uploads/2017/05/Screenshot_2-1.png)

**SABnzbd in container with multiarch support**
===

Image is automatically updated, when a new version of SABnzbd arrives on GitHub.   
Supported architectures are amd64, arm64, arm.

Status from last build
-----
![SABnzbd Docker Build](https://github.com/avpnusr/sabnzbd/workflows/SABnzbd%20Docker%20Build/badge.svg)

The container is lightweight and based on alpine linux.

You can find the weekly dev-build from SABnzbd in this **[container](https://hub.docker.com/r/avpnusr/sabnzbd-dev)**

Versions in the latest image
-----
- [SABnzbd](https://sabnzbd.org "SABnzbd Project Homepage") Version: 3.2.1
- PAR2 from [par2cmdline](https://github.com/Parchive/par2cmdline) Version: 0.8.1

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
  --restart=unless-stopped avpnusr/sabnzbd

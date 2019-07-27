#! /bin/sh
echo "#### Starting SABnzbd on Port 8080 in container ####"

/usr/bin/python SABnzbd.py -f /config/sabnzbd.ini --browser 0 -s 0.0.0.0:8080

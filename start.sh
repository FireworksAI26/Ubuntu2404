#!/bin/bash

# Remove existing VNC locks
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# Ensure D-Bus is running (Required for GNOME)
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Start VNC server as the user
# We use -localhost no to allow the websockify proxy to connect
sudo -u remoteuser vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Start websockify to bridge VNC (5901) to the web port (6080)
echo "Starting noVNC at http://localhost:6080"
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

# Prevent the container from exiting
tail -f /dev/null

# Keep container alive
sleep infinity

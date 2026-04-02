FROM runpod/base:0.7.0-ubuntu2004

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install Ubuntu Desktop and VNC/noVNC tools
RUN apt update && apt upgrade -y && \
    apt install -y \
    ubuntu-desktop \
    tigervnc-standalone-server \
    novnc websockify \
    wget curl sudo dbus-x11 \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash remoteuser && \
    echo "remoteuser:remoteuser" | chpasswd && \
    usermod -aG sudo remoteuser && \
    echo "remoteuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup noVNC web interface
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Configure the VNC startup script to launch GNOME
WORKDIR /home/remoteuser
RUN mkdir -p .vnc
RUN echo "#!/bin/sh\n\
export XDG_CURRENT_DESKTOP=GNOME\n\
export GNOME_SHELL_SESSION_MODE=ubuntu\n\
export DESKTOP_SESSION=ubuntu\n\
/usr/bin/gnome-session" > .vnc/xstartup && chmod +x .vnc/xstartup

# Set a default VNC password
RUN echo "password" | vncpasswd -f > .vnc/passwd && chmod 600 .vnc/passwd
RUN chown -R remoteuser:remoteuser /home/remoteuser

# Expose port 6080 for noVNC
EXPOSE 6080

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

FROM runpod/base:0.4.0-ubuntu22

ENV DEBIAN_FRONTEND=noninteractive

# Update and install full Ubuntu desktop
RUN apt update -y && apt upgrade -y && \
    apt install -y ubuntu-desktop wget curl sudo expect dbus-x11 && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Download and install Chrome Remote Desktop
RUN wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    dpkg -i chrome-remote-desktop_current_amd64.deb || apt-get install -f -y && \
    rm chrome-remote-desktop_current_amd64.deb

# Configure GNOME session for CRD
RUN echo "exec /usr/bin/gnome-session" > /etc/chrome-remote-desktop-session

# Disable NetworkManager conflict (ubuntu-desktop brings it in, conflicts with container networking)
RUN systemctl disable NetworkManager 2>/dev/null || true && \
    systemctl disable systemd-networkd 2>/dev/null || true

# Create non-root user (CRD refuses to run as root)
RUN useradd -m -s /bin/bash remoteuser && \
    echo "remoteuser:remoteuser" | chpasswd && \
    usermod -aG sudo,chrome-remote-desktop remoteuser && \
    echo "remoteuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]

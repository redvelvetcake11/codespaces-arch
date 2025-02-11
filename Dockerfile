FROM archlinux:latest

# Add Arch Linux CN repository
RUN echo '[archlinuxcn]' >> /etc/pacman.conf && \
    echo 'Server = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf

# Update system and install required packages
RUN pacman-key --recv-keys F9F9FA97A403F63E && \
    pacman-key --lsign-key F9F9FA97A403F63E && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm archlinuxcn-keyring && \
    pacman -S --noconfirm git sudo code-server

# Create the systemd service file for code-server
RUN echo '[Unit]' > /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'Description=code-server' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo '# Start code-server early in the boot process' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'DefaultDependencies=no' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'Before=sysinit.target' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo '' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo '[Service]' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'Type=simple' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'ExecStart=/usr/bin/code-server --auth none --bind-addr 0.0.0.0:23000 --app-name Gitpod /root' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'Restart=always' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'User=root' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo '' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo '[Install]' >> /usr/lib/systemd/system/code-server-gitpod.service && \
    echo 'WantedBy=sysinit.target' >> /usr/lib/systemd/system/code-server-gitpod.service

# Enable systemd inside Docker
ENV container=docker
STOPSIGNAL SIGRTMIN+3

RUN systemctl set-default multi-user

CMD [ "/lib/systemd/systemd" ]

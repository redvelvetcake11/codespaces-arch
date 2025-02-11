FROM archlinux:latest

# Add Arch Linux CN repository
RUN cat << EOF >> /etc/pacman.conf
[archlinuxcn]
Server = https://repo.archlinuxcn.org/\$arch
EOF

# Update system and install required packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archlinuxcn-keyring git sudo code-server

# Create the systemd service file for code-server
RUN cat << EOF > /usr/lib/systemd/system/code-server-gitpod.service
[Unit]
Description=code-server
# Start code-server early in the boot process
DefaultDependencies=no
Before=sysinit.target

[Service]
Type=simple
ExecStart=/usr/bin/code-server --auth none --bind-addr 0.0.0.0:23000 --app-name Gitpod /root
Restart=always
User=root

[Install]
WantedBy=sysinit.target
EOF

# Enable systemd inside Docker
ENV container=docker
STOPSIGNAL SIGRTMIN+3

CMD [ "/lib/systemd/systemd" ]

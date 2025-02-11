FROM archlinux:latest

RUN echo '[archlinuxcn] \
\nServer = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf
RUN pacman -Syu --noconfirm
RUN pacman -S archlinuxcn-keyring
RUN pacman -S git sudo code-server

# Create the systemd service file for code-server
RUN echo '[Unit] \
\nDescription=code-server \
\n# Start code-server early in the boot process \
\nDefaultDependencies=no \
\nBefore=sysinit.target \
\n\n[Service] \
\nType=simple \
\nExecStart=/usr/bin/code-server --auth none --bind-addr 0.0.0.0:23000 --app-name Gitpod /root \
\nRestart=always \
\nUser=root \
\n\n[Install] \
\nWantedBy=sysinit.target' > /usr/lib/systemd/system/code-server-gitpod.service

# COPY install_guest_agent.sh /root/install_guest_agent.sh

# Set up systemd for Docker
ENV container docker
STOPSIGNAL SIGRTMIN+3

CMD [ "/lib/systemd/systemd" ]

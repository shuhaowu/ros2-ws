
FROM osrf/ros:humble-desktop

ARG USERNAME=human

RUN set -xe; \
    adduser --gecos "" --disabled-password $USERNAME; \
    usermod -a -G sudo $USERNAME; \
    usermod -a -G video $USERNAME; \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers;

RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y \
        binutils \
        ca-certificates \
        kmod \
        less \
        mesa-utils \
        nano \
        xterm \
        gdb \
        python3-pip \
        wget \
        vim \
        zsh \
        xz-utils \
    ; \
    chsh -s /bin/zsh $USERNAME

COPY ros-activate.sh /etc/profile.d/ros-activate.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

COPY .zshrc /home/$USERNAME/.zshrc

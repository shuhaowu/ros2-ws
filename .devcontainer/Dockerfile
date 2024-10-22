
FROM osrf/ros:jazzy-desktop

ARG USERNAME=human
ARG uid=1000
ARG gid=1000

RUN set -xe; \
    deluser ubuntu; \
    addgroup --gid $gid $USERNAME; \
    adduser --gecos "" --disabled-password --uid $uid --gid $gid $USERNAME; \
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

RUN set -xe; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -y ca-certificates curl; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" >/etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; \
    usermod -a -G docker $USERNAME;

COPY ros-activate.sh /etc/profile.d/ros-activate.sh
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

COPY .zshrc /home/$USERNAME/.zshrc

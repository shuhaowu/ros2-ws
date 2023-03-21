#!/bin/bash

set -e

# TODO: automatically determine this.
USERNAME=human

# Need to fix user permissions to have access to the proper rendering for gazebo
# https://github.com/linuxserver/docker-plex/blob/b01cd52/root/etc/cont-init.d/50-gid-video
# They have a root clause that I'm not going to worry about. See:
# https://github.com/linuxserver/docker-plex/pull/208#issuecomment-532948347
fix_dri_permissions() {
  local files=$(find /dev/dri -type c -print 2>/dev/null)

  for file in $files; do
    local gid=$(stat -c '%g' $file)
    echo -n "$file has group of $gid... "
    if id -G | grep -q "$gid"; then
      echo "and is already a part of user $USERNAME"
    else
      local gname=$(getent group "$gid" | awk -F: '{print $1}')
      if [ -z "$gname" ]; then
        gname="video${gid}"
        groupadd "$gname"
        groupmod -g "$gid" "$gname"
      fi

      usermod -a -G "$gname" $USERNAME
      echo "and is added to part of $USERNAME"
    fi
  done
}

install_nvidia_drivers() {
  if [ -f /proc/driver/nvidia/version ]; then
    if [ ! -f /usr/bin/nvidia-smi ]; then
      echo "Detected NVIDIA GPU, installing NVIDIA drivers..."
      local opts='--accept-license --no-questions --no-backup --ui=none --no-kernel-module --no-nouveau-check --no-kernel-module-source --no-nvidia-modprobe --install-libglvnd'
      local nvversion="$(head -n1 </proc/driver/nvidia/version | awk '{ print $8 }')"
      wget --progress=dot -e dotbytes=10M "https://http.download.nvidia.com/XFree86/Linux-x86_64/$nvversion/NVIDIA-Linux-x86_64-$nvversion.run" -O /tmp/NVIDIA-installer.run
      sudo sh /tmp/NVIDIA-installer.run $opts
      rm -f /tmp/NVIDIA-installer.run
    fi
  fi
}

generate_ros_domain_id_if_needed() {
  local ros_domain_id_file=$WORKSPACE_FOLDER/.devcontainer/ros-domain-id
  if [ ! -d $WORKSPACE_FOLDER/.devcontainer ]; then
    echo "error: WORKSPACE_FOLDER is not mounted or WORKSPACE_FOLDER environment variable not set: $WORKSPACE_FOLDER" >&2
    exit 1
  fi

  if [ ! -f "$ros_domain_id_file" ]; then
    local r=$(( $RANDOM % 30 + 40 )) # ROS_DOMAIN_ID should be between 0 and 101. We choose between 40 and 70 for good luck
    echo $r > $ros_domain_id_file
    echo "setting ROS_DOMAIN_ID to $r"
  fi
}

fix_dri_permissions
install_nvidia_drivers
generate_ros_domain_id_if_needed
exec sleep infinity

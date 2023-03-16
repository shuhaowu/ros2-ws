
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
      wget "https://http.download.nvidia.com/XFree86/Linux-x86_64/$nvversion/NVIDIA-Linux-x86_64-$nvversion.run" -O /tmp/NVIDIA-installer.run
      sudo sh /tmp/NVIDIA-installer.run $opts
      rm -f /tmp/NVIDIA-installer.run
    fi
  fi
}

fix_dri_permissions
install_nvidia_drivers
exec sleep infinity

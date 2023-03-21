cd $WORKSPACE_FOLDER

ROS_DISTRO=humble

if [ -f /opt/ros/$ROS_DISTRO/setup.zsh ]; then
  . /opt/ros/$ROS_DISTRO/setup.zsh
fi

export HISTFILE=$WORKSPACE_FOLDER/.devcontainer/zsh_history

nvrun() {
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
}

if [ -f $WORKSPACE_FOLDER/.devcontainer/nvidia-always-on ]; then
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
fi

if [ -f $WORKSPACE_FOLDER/.devcontainer/ros-domain-id ]; then
  export ROS_DOMAIN_ID=$(cat $WORKSPACE_FOLDER/.devcontainer/ros-domain-id)
fi
if [ -z "$ROS_DOMAIN_ID" ]; then
  echo "WARNING: ROS_DOMAIN_ID not set. There's a chance that you may pollute others' ROS environments on this network."
  echo "WARNING: check .devcontainer/ros-domain-id to see if it exists or if it is empty."
fi

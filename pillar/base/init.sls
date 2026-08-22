packages:
  - fzf
  - jq
  - socat
  - conntrack
  - ipset
  - kmod

mine_functions:
  network.ip_addrs:
    interface: eth0

kubernetes:
  control_plane_hostname: kubernetes-control-plane

"{{ saltenv }}":
  "*":
    - base

  "kubernetes-control-plane":
    - pki
    - kubectl
    - etcd
    - kube-apiserver
    - kube-controller-manager
    - kube-scheduler
    - kubernetes-coredns

  "kubernetes-node-[0-9]":
    - pki
    - kubectl
    - kubernetes-swap
    - kubernetes-cni
    - containerd
    - kubelet
    - kube-proxy

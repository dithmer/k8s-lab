"{{ saltenv }}":
  "*":
    - base

  "server":
    - pki
    - kubectl
    - etcd
    - kube-apiserver
    - kube-controller-manager
    - kube-scheduler

  "node*":
    - pki
    - kubectl
    - kubernetes-swap
    - kubernetes-cni
    - containerd

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

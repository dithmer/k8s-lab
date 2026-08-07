"{{ saltenv }}":
  "*":
    - base

  "server":
    - pki
    - etcd
    - kube-apiserver

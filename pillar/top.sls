"{{ saltenv }}":
  "*":
    - base

  "kubernetes-control-plane":
    - minions.server

  "kubernetes-node-[0-9]":
    - minions.node0

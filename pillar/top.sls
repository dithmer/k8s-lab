"{{ saltenv }}":
  "*":
    - base

  "server":
    - minions.server

  "node-0":
    - minions.node0

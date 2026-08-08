kubernetes_swap_disable:
  cmd.run:
    - name: swapoff -a
    - unless: free | grep Swap | awk '{print $2}' | grep -q '^0$'

Simply a playground for testing out hcloud terraform, saltstack and setting up a k8s cluster.

Nothing serious. Nothing production grade. Just fun and trying to make things in a way they should probably not be done.

This is heavily based and inspired by [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

# Prerequisites

- tofu/terraform
- Hetzner Cloud account and API token (https://docs.hetzner.com/cloud)

# How to use

1. Create a hcloud.tfvars file in the root of the project with the following content:

```hcl
hcloud_token = "<your_hcloud_api_token>"
```

2. `make start`

3. Create certificates for kubernetes and the node:

```bash
cd ca && bash setup_ca.sh
```

4. `bash connect.sh` - connects you to the saltmaster/control plane, following commands will be 
    executed on the saltmaster.

5. `mkdir /srv/pillar/minions/ -p`

6. Put the minion pillar data in `/srv/pillar/minions/<minion_name>.sls` with the content from the 
    host systems `ca/<minion_name>.sls` file. (do that for server.sls and node<N>.sls)

7. `salt-key -A` - Accept the minion keys.

8. Do some foo for now (everything root is not good):

```bash
git config --global --add safe.directory '*' # Dangerous, but lazy for now
systemctl restart salt-master
salt-run fileserver.update && salt-run git_pillar.update # Fetch latest git ref
salt '*' saltutil.refresh_pillar && salt '*' pillar.ls # Refresh pillar data on all minions and verify
salt '*' mine.update && salt '*' mine.get '*' # Update mine data and verify
salt '*' state.apply # Apply the state to all minions
```

9. Have fun and enjoy your kubernetes cluster!
    - admin configuration for kubectl is in `/var/lib/kubernetes/admin.kubeconfig`
    - verify like this: `kubectl --kubeconfig /var/lib/kubernetes/admin.kubeconfig cluster-info`
    - show everything in the cluster: `kubectl --kubeconfig /var/lib/kubernetes/admin.kubeconfig get all -A -o wide`
    - show nodes: `kubectl --kubeconfig /var/lib/kubernetes/admin.kubeconfig get nodes -o wide`
    - check coredns working: `kubectl --kubeconfig /var/lib/kubernetes/admin.kubeconfig run --rm -it busybox --image=busybox:1.28 --restart=Never -- nslookup kubernetes.default`

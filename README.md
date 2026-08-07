Simply a playground for testing out hcloud terraform, saltstack and setting up a k8s cluster.

Nothing serious. Nothing production grade. Just fun and trying to make things in a way they should probably not be done.

# Prerequisites

- tofu/terraform

# How to use

1. Create a hcloud.tfvars file in the root of the project with the following content:

```hcl
hcloud_token = "<your_hcloud_api_token>"
```

2. `make start`

3. `bash connect.sh` - connects you to the saltmaster/control plane

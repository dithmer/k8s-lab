start:
	@ssh-keygen -t ed25519 -f id_ed25519 -N "" -q
	@tofu -chdir="infra/" init
	@tofu -chdir="infra/" apply -auto-approve -var-file="hcloud.tfvars"

stop:
	@tofu -chdir="infra/" destroy -auto-approve -var-file="hcloud.tfvars"

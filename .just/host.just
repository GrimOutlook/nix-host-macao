flake_host := `nix eval .#nixosConfigurations --apply builtins.attrNames --json | jq .[]`
ssh_host := 'root@' + flake_host

# Build the nix configuration for this host
[group('build')]
build *args="":
  nh os build . -H {{flake_host}} {{args}}

_deploy path host *args:
  nh os switch . \
    -H {{flake_host}} \
    --target-host {{host}} \
    {{args}}

# Rollback to the previously activated build
[group('cleanup')]
rollback *args="":
  nh os rollback {{args}}

# Deploy this host flake for the first time to a new system
[group('deploy')]
deploy-new host=ssh_host *args="":
  just clear-ssh
  nix run github:nix-community/nixos-anywhere -- {{args}} \
    --flake .#{{flake_host}} \
    {{host}}

alias switch := deploy
# Deploy host flake
[group('deploy')]
deploy host=ssh_host *args="":
  just _deploy . {{host}} {{args}}

# Deploy host flake but build locally
[group('deploy')]
deploy-build-local host=ssh_host *args="":
  just deploy {{host}} --build-host {{host}} {{args}}

# Deploy host flake from github repo
[group('deploy')]
deploy-github host=ssh_host *args="":
  just _deploy \
    git+ssh://git@github.com/GrimOutlook/nix-host-{{flake_host}} \
    {{host}} \
    {{args}}

# Connect to nix-host
[group('connect')]
connect host=ssh_host:
  ssh "{{host}}"

# Remove old `.known_hosts` entries for nix-host
[group('connect')]
[group('cleanup')]
clear-ssh host=ssh_host:
  ssh-keygen -R {{host}}

# Update the given flake.nix inputs
[group('helpers')]
eval path *args="":
  nix eval .#nixosConfigurations.{{flake_host}}.{{path}} {{args}}

# Update the homelab flake for this host
[group('homelab')]
update-flake flake="": check-clean
  #!/usr/bin/env bash
  git pull
  nix flake update {{flake}}
  nix flake check
  if ! git diff --quiet || ! git diff --cached --quiet; then
      git commit -am 'fix: Updated [{{flake}}] flake'
      git push
  fi
  echo '[{{flake}}] flake update complete'

# Update the homelab flake and redeploy this host
[group('deploy')]
[group('homelab')]
deploy-update *flakes="":
  #!/usr/bin/env bash
  for flake in {{flakes}}; do
    just update-flake "$flake"
  done
  just deploy-github

[group('git')]
check-clean:
  git diff --quiet && git diff --cached --quiet || (echo "Working tree is dirty" && exit 1)

[group('git')]
commit-update:
  git commit -am "chore(nix): Update flake.lock"

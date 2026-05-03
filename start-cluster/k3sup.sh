#!/bin/bash

# TODO Welcome/briefing message

role="$(gum choose --header="Choose a role for this host:" node server)"

node_ip="$(gum input --header="IP address of the host to set up:")"

if [[ "$role" == "node" ]]; then
  server_ip="$(gum input --header="K3s server IP:")"
fi

user_acct="$(gum input --header="User account on the host (non-root!):" --value="pi")"

case "${role}" in
server)
  k3sup_args=""
  k3s_extra_args=""

  # Always encrypt secrets at rest. Why wouldn't we?
  k3s_extra_args="${k3s_extra_args} --secrets-encryption"

  context="$(gum input --header="Choose a name for your kubectl context:" --value="k3s")"

  if gum confirm "Would you like to merge this context into your existing kubeconfig file?" --default=No; then
    k3sup_args="${k3sup_args} --merge"
  fi

  if gum confirm "Enable the Distributed OCI Registry Mirror?\nSee https://docs.k3s.io/installation/registry-mirror" --default=No; then
    k3s_extra_args="${k3s_extra_args} --embedded-registry"
  fi

  k3sup install \
    --ip "$node_ip" \
    --user "$user_acct" \
    --context "$context" \
    --no-extras \
    ${k3sup_args} \
    --k3s-extra-args "$k3s_extra_args"
  ;;
node)
  server_user_acct="$(gum input --header="Name of user account on k3s server:" --value="${user_acct}")"

  k3sup join \
    --ip "$node_ip" \
    --server-ip "$server_ip" \
    --user "$user_acct" \
    --server-user "$server_user_acct"
  ;;
esac

#!/bin/bash

set -e

export GUM_FORMAT_THEME=pink

if [[ "${SKIP_DD}" != "true" ]]; then
  img_path="$(gum input --header="Path to Armbian or Raspbian Lite image file:")"
else
  gum format "You've set SKIP_DD=true - assuming you've already written your image to an SD card."
fi

distro="$(gum choose --header="What distro are we working with?" Armbian Raspbian)"

device_path="$(ls /dev/mmcblk? | gum choose --header="Which device is your SD card?")"

hostname_new="$(gum input --header="Hostname:" --placeholder="[Use hostname from image]")"

pubkey_file="$(gum choose --header="Choose a public key to authorise for non-root login:" new $(ls ~/.ssh/*.pub))"

if [ "$pubkey_file" == "new" ]; then
  read -r -p "Name of new keypair: " keypair_name

  echo "Generating new keypair..."

  ssh-keygen -t ed25519 -f "${HOME}/.ssh/${keypair_name}"

  pubkey_file="${HOME}/.ssh/${keypair_name}.pub"
fi

if [[ "${SKIP_DD}" == "true" ]]; then
  gum format "SKIP_DD=true. Skipping image write."
else
  gum confirm --default=No "Writing '$img_path' to '$device_path'. BE VERY SURE. Proceed?"

  img_size="$(du -h "${img_path}" | awk '{ print $1 }')"
  gum format "Writing ${img_size} from \`${img_path}\`"
  sudo dd if="$img_path" of="$device_path" status=progress
fi

## Verify line by line beyond this point
case $distro in
Armbian)
  root_dir=root
  boot_dir=root/boot

  user_acct=k3sadmin

  mkdir -p "${root_dir}"

  sudo mount "${device_path}p1" "${root_dir}"

  # Allow passwordless sudo for our non-root user (required for k3sup)
  cat >/etc/sudoers.d/k3sup <<-SUDOERS
# Allow passwordless sudo for ${user_acct} (required for k3sup)
#
${user_acct} ALL = (ALL) NOPASSWD: ALL
SUDOERS
  ;;

Raspbian)
  root_dir=root
  boot_dir=boot

  user_acct=pi

  sudo mount "${device_path}p1" "${root_dir}"
  sudo mount "${device_path}p2" "${boot_dir}"
  gum format "TODO: CHECK THE VOLUME MOUNTS"
  exit 1

  # TODO Double check newline situation

  # Unfortunately, we need `sudo` for all of this, because a ton of files are owned by root.
  #
  # Enable some kernel optimisations for containers.
  # This is already done in Armbian (see /boot/armbianEnv.txt)
  #
  echo ' cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory' | sudo tee -a "${boot_dir}/cmdline.txt"

  # Enable sshd.
  #
  # Only required for Raspbian, because "SSH is enabled oob on all Armbian images."
  # -- https://forum.armbian.com/topic/21210-access-ssh-from-lan/
  #
  sudo touch "${boot_dir}"/ssh

  # Authorize our public key to log in as user pi via SSH.
  #
  # Unfortunately, Armbian does not have a non-root user preinstalled on the image, so this is just for Raspbian.
  #
  mkdir -p "${root_dir}"/home/${user_acct}/.ssh
  # TODO chown
  cat "$pubkey_file" >>"${root_dir}"/home/${user_acct}/.ssh/authorized_keys

  ;;
esac

export user_acct

## Set the hostname
#
hostname_current="$(cat "${root_dir}"/etc/hostname)"

if [ -z "${hostname_new}" ]; then
  hostname_new="${hostname_current}"
fi

if [[ "${hostname_new}" != "${hostname_current}" ]]; then
  sudo sed -i "s/$hostname_current/$hostname_new/g" "${root_dir}"/etc/hosts
  sudo sed -i "s/$hostname_current/$hostname_new/g" "${root_dir}"/etc/hostname
fi

## Add configuration for k3s's Distributed OCI Registry Mirror
#
# This will only be used if we select the option when running k3sup.sh
#
sudo mkdir -p "${root_dir}/etc/rancher/k3s"
sudo cp registries.yaml "${root_dir}/etc/rancher/k3s/registries.yaml"

# Race condition?
sleep 1
sudo umount "${root_dir}"

if [[ "${distro}" == "Raspbian" ]]; then
  sudo umount boot
fi

gum format "Your SD card is ready to boot! :D"

if [[ "${distro}" == "Armbian" ]]; then
  public_key="$(cat "${pubkey_file}")"
  export public_key

  echo
  echo
  <armbian-first-boot.md envsubst "user_acct public_key" | gum format
fi

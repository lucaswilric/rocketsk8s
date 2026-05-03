# rocketsk8s

A gently-opinionated starter kit for running Kubernetes on smaller hardware.

## Getting started

1. Use `asdf` or `mise` to install the project dependencies:

   ```shell
   mise install

   # or

   asdf install
   ```

## Preparing a host to add to (or start!) the cluster

> [!INFO]
> **Assumptions & limitations**
>
> I've used this procedure to set up hosts running [Raspberry Pi OS](https://www.raspberrypi.com/software/operating-systems/) and [Armbian](https://www.armbian.com/).
>
> I am running Manjaro Linux, and the scripts here have been tested on that, but nothing else.
>
> As a result, the scripts contain some assumptions that I made because I could get away with it, and because they helped me make fewer mistakes. For example, limiting the hardware addresses you can select from `/dev`.

### You will need

- A MicroSD card (I suggest 128GB or greater. I ran into trouble when trying this with only 32GB.)
- A Raspberry Pi (I have used a 4B+ with no issues. A 3B worked OK as an agent, but didn't have enough memory to run the `k3s` server.), or an ARM-based computer (I used a Pine64 Rock64 rev2.)
- Wired network access for your new host.
  - If you are using WiFi networking for this host, you'll need to set that up after your first boot. I haven't got a guide for that, but the Internet probably has plenty.

1. Download the OS image (either Raspbian or Armbian) that you want to run on your first host.
   1. If you are using Armbian, you might need to extract the image from an archive file. If the file name ends with `.xz` then you will need to do this. If the file name ends with `.img` then it's not necessary. Something else? Sorry, you'll need to work that out for yourself.
1. Decide on a **unique hostname** for your host, and make a note of it.
1. Decide on a **user account name** that you will use to log into the host via SSH.
   - Default on Armbian is `k3sadmin`.
   - Default on Raspberry Pi OS is `pi`.
1. If you already have an SSH keypair that you will use to log in to this host, then make a note of its location. If not, the script can create one for you.
1. Insert your MicroSD card.
1. Find the device file for your MicroSD card. It will start with `/dev/`.
   - If you use Linux and GNOME, then the "Disks" utility might help you find it.
1. Run `start-cluster/prep-sd-for-new-node.sh`.
   - It will prompt you for the details you've noted.
   - It will ask for superuser access, so that it can write your chosen image to the SD card, and write some files on the SD card after flashing (which are owned by `root`).
1. **Your MicroSD card is ready!** Eject it and plug it in to your new `k3s` host.
1. Connect your new host to network, and power it up.
   - If you are setting up WiFi networking, this is the time.
1. Find your host's IP address on your local network, and make a note of it.
   - You might be able to find this via your router.
   - If all else fails, you can plug in a keyboard and monitor to the machine, log in and run `ip addr`.

Congratulations! Your host is now ready to join -- or start -- a `k3s` Kubernetes cluster!

## Starting a new cluster

To start a new cluster, you need to configure your host as a [k3s server](#whats-a-k3s-server).

Here's how:

1. With your server's IP address in hand, run `start-cluster/k3sup.sh`.
1. You'll be asked to select a role for your host. Select `server`.
1. When prompted, enter your host's IP address and the user account name that you chose (see the defaults above if you don't remember choosing one).
1. When prompted, choose a [context name](#kubectl-contexts) for this cluster. This is just a name you'll use to refer to this cluster in your tools. If you only plan to have one cluster, or this is your first one, then just go with the default.
1. By default, the tool will put your `kubeconfig` in its own file, which prevents your usual `kubeconfig` from getting filled up with noise -- especially if you need a few attempts to get it to work! However, it will offer to merge the new context into your existing `kubeconfig` file. Select that option if you like.
1. Finally, the tool will ask whether you want to enable the Embedded OCI Registry Mirror. This is a feature that allows your hosts to share container images between them. It helps your Pods to start faster, and reduces load on your internet connection, but it takes up more disk space on each host. Your cluster will work either way.

Once you've answered all those questions, let it run! At the end, you'll have a shiny new `k3s`-flavoured Kubernetes cluster ☺

From here, you should be able to use `kubectl` to talk to your cluster, something like this:

```sh
kubectl config use-context k3s # Replace k3s with a different context name if you set one.
kubectl get nodes
```

## Adding a host to an existing cluster

You will need:

- A running `k3s`-flavoured Kubernetes cluster
- A freshly set up host
- The IP address of your new host
- The user name you set for your new host (probably `k3sadmin` or `pi`)
- The IP address of your cluster's server
- The user name you use to log in to your cluster's server via SSH (probably `k3sadmin` or `pi`)

1. Run `start-cluster/k3sup.sh`.
1. When prompted, enter the details you prepared above.
1. Let it run.

That's it!

When you're done, run `kubectl get nodes`. You should see a new node in the list!

## What next?

You (hopefully!) have a working Kubernetes. Now what?

Well, there are many options. But if, like me, you're interested in self-hosting and privacy, you might like to check out:

### A friendly UI

`kubectl` is *technically* all you need to work with your cluster, but you might like something a little more friendly.

- [Freelens](https://freelensapp.github.io/) is a desktop application for managing Kubernetes clusters. It can handle simultaneous connections to multiple clusters.
- [k9s](https://k9scli.io/) is a TUI (Terminal User Interface) that's just a bit more convenient than running hundreds of `kubectl` commands.
- [Rancher](https://github.com/rancher/rancher/tree/main/chart) web UI. Rancher has lots of cool features, but it does consume part of your cluster's capacity, and a lot of its features are overkill for a single small cluster. Even so, I've gotten a lot of mileage out of it while figuring out what shape I want my cluster to be.
- [kubenav](https://kubenav.io/) for Android.

### Helm: A k8s-y "package manager"

Go learn about [Helm](https://helm.sh/). It will make it a lot easier to install cool stuff on your cluster :)

### Installing some essentials (some of which I removed from the box - sorry!)

After publishing this README, my next goal is to share code for installing these.

- [MetalLB](https://metallb.io/) is a slightly more advanced load balancer than the one that comes in the box with `k3s`. It's a must if you want to serve anything that's not HTTP(S), or anything that requires its own IP address.
- [Traefik](https://doc.traefik.io/traefik/v3.3/getting-started/install-traefik/#use-the-helm-chart) is a web proxy and _ingress controller_ (or alternatively a _Gateway controller_). It routes network connections & HTTP requests to workloads, according to rules you specify.
- [Tailscale Operator](https://tailscale.com/docs/features/kubernetes-operator): once you have some apps running on your cluster, the Tailscale Operator can put them on your Tailnet (if you're a Tailscale user, that is). It also makes your k8s API available to your Tailnet -- subject to your policy, of course -- so you don't have to make your API server public to use it. Combines very well with `kubenav` for troubleshooting on the go.

## Tangents & addenda

### What's a `k3s` server?

The server is a host that has a special role in your cluster:

- It keeps track of all the cluster's resources (Pods, Services, Deployments, etc.).
- It decides which workloads will run on which hosts.
- It hosts the cluster's API -- the contact point that you will use (via tools like `kubectl`, `helm` or the Rancher web console) to get information about the cluster, and tell the cluster what to do.

As such, this is an important host! If it breaks, your cluster breaks.

You can run Kubernetes on a single host -- API, workloads and all -- if the host has enough power. But I'm assuming you're here because you want to run a cluster with multiple hosts, either now or in the future. I certainly am!

### `kubectl` contexts

`kubectl` and other Kubernetes tools are capable of talking to many different clusters, and each cluster needs a different configuration. In Kubernetes language, these configurations are called "contexts".

The context includes information about how your tools should connect and authenticate to the cluster.

It is contained in a YAML-formatted file called a `kubeconfig`, which usually lives in your home directory, at `~/.kube/config`.

You can learn more about contexts and the kubeconfig file from the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

## Choices & opinions

I definitely made these choices. I would make at least some of them again.

### MetalLB instead of KlipperLB

K3s' stock load balancer is enough to get started, but only really works with HTTP(S). If you want to serve any other protocol (LDAP, DNS, mail, FTP), or if you want an application to have its own IP address, you need a more capable load balancer. MetalLB is one such.

Alternatives:

- `kube-vip`

### Enabling at-rest encryption of secrets

Honestly, I don't know why this isn't enabled by default.

### Distributed OCI Registry Mirror

Why the heck wouldn't you want your nodes to share images instead of getting them from the internet?

### No stock traefik

Now, I might just be being a bit of a control freak here.

But if asked in a serious tone, I would reply: I want to be sure where the config is.

## Acknowledgements

This project stands on the shoulders of:

- [k3s](https://k3s.io/)
- [k3sup](https://github.com/alexellis/k3sup)
- The [Raspberry Pi Foundation](https://raspberrypi.org/)
- [Armbian](https://armbian.com/)
- and of course, [Kubernetes](https://kubernetes.io/) and the [CNCF](https://www.cncf.io/).

And was heavily inspired by:

- [Yunohost](https://yunohost.org)

It will surely stand on many more shoulders in the future!

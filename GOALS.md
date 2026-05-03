# Goals

TL;DR: I think self-hosting should be easy enough that an enthusiast can do it safely and usefully in their spare time, without having to spend tons of money on equipment.

I've learned about a few software projects that could further these ideals:

- Kubernetes is really good at keeping software running in unreliable conditions. And (I suspect) for figuring out which machine is best for running a workload, even when it's working with a motley assortment of machines.
- Tailscale provides a way for clients and servers to communicate, without needing to expose either to the open Internet.
- Auth tech like passkeys and OAuth/OIDC provide a less vulnerable alternative to passwords. And projects like Pocket ID make them accessible to self-hosters.

The bits that I think are missing are the "in their spare time" and "without spending tons of money". That's where I'm hoping this (or rather, whatever this turns into) might make a difference for some people. Making it easier to get started, having some pretty-easy and pretty-safe supports out of the box (e.g. VPN, SSO, TLS, maybe even backups!), and generally keeping the maintenance burden low. Or more concisely, including a reasonable set of batteries.

So, to phrase some of those things as goals:

## 1. Help non-experts (and time-poor experts) run Kubernetes without needing to understand every detail.

Even with years of experience using Kubernetes and friends in the workplace, I've poured a lot of time and effort into building my home cluster. And I expect that to continue. I'd love it if the requirements of both effort and expertise were lower. So I'm trying to make that real.

## 2. Help folks run their own networked apps for fun, learning, privacy and freedom.

In the same way that some folks get satisfaction out of baking cakes from scratch, or doing their own motorcycle maintenance, I get satisfaction (at least sometimes) from running software that I actually use, on my own hardware, and fixing it when it breaks. While some of that satisfaction comes from the fact that I've worked for it, I also think this stuff should be easier.

## 3. Make self-hosting cheaper, and extend the life of hardware that might otherwise become junk.

I am privileged to have enough disposable income to support my self-hosting hobby, but that's not true for everyone. And even when I _could_ spend money on more powerful hardware, it can feel wasteful to do that when surplus hardware like old-but-still-working laptops are relatively to find. Especially when a lot of useful, self-hostable software can run on hardware that's several generations behind the cutting edge. So I guess I hope that by making it easier to manage a disparate assortment of apps and less-than-cutting-edge machines, I'll also help drive down the cost of self-hosting.

That's not to say that *you* shouldn't pay retail for hardware! Do what works for you! I just don't think that this project would be achieving what I want to achieve if it required that.

I intend to share more about the ideals, peeves, gripes and other motivations that have led me to make this. Hopefully I'll be able to do it without getting too preachy, or reaching for my tinfoil hat. No promises, though.

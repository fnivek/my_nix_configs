# Kevin's System Config
This repo contains all of my configurations for all of the things I do.


## Apparmour blocks my electron apps
Yeah, this one’s not really a “home-manager on Ubuntu” bug, it’s **Ubuntu 24.04 being extra paranoid** and your Nix binaries tripping over it.

Short version:

* Ubuntu 24.04 added **AppArmor restrictions on unprivileged user namespaces**.([Ubuntu Community Hub][1])
* Chromium/Electron apps (Chrome, Obsidian, etc.) **use user namespaces and the chrome-sandbox helper**.
* Ubuntu ships AppArmor profiles for *their* Chrome/Discord/etc, but **your Nix binaries in `/nix/store/...` don’t have those profiles**, so they get blocked and abort with the SUID sandbox error.([GitHub][2])
* Home-manager is user-level only; it **cannot** fix this by itself – you have to adjust the host OS (sysctl or AppArmor).

You’ve basically got three realistic options. I’ll show you the clean ones and the tradeoffs.

---

## Option A – Easiest: turn off the new restriction globally

This makes Ubuntu behave like pre-24.04 for user namespaces. Good for a **dev laptop you control**, less ideal for high-paranoia environments.

1. Check the current values:

```bash
sysctl kernel.unprivileged_userns_clone
sysctl kernel.apparmor_restrict_unprivileged_userns
```

On 24.04, you’ll usually see:

* `kernel.unprivileged_userns_clone = 1`
* `kernel.apparmor_restrict_unprivileged_userns = 1`

2. Temporarily disable the AppArmor restriction (for testing):

```bash
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
```

Now try your Nix chrome/obsidian again. They should start.

3. Make it **persistent** across reboots by dropping a sysctl file, as Ubuntu’s own release notes suggest:([Ubuntu Community Hub][1])

```bash
echo 'kernel.apparmor_restrict_unprivileged_userns = 0' |
  sudo tee /etc/sysctl.d/60-apparmor-namespace.conf

# apply without reboot (still reboot later for good measure)
sudo sysctl -p /etc/sysctl.d/60-apparmor-namespace.conf
```

Security tradeoff:

* You’re re-enabling full unprivileged user namespaces globally, which brings back some kernel exploit surface that Ubuntu was trying to reduce. That’s the same tradeoff as pre-24.04 systems – totally reasonable on a dev laptop if you’re comfortable with it.

No changes to your flake/home-manager setup needed; your Nix Chrome/Obsidian should just work again.

---

## Option B – More targeted: AppArmor profile per Nix app

If you want to **keep** Ubuntu’s stricter defaults but still run specific Nix apps (like Nix-Obsidian, Nix-Chrome), you can add an AppArmor profile that:

* Marks the binary as effectively “unconfined”
* Explicitly allows `userns` for it

This is exactly what the Ubuntu release notes suggest for Google Chrome; here’s their template:([Ubuntu Community Hub][1])

```apparmor
abi <abi/4.0>,

include <tunables/global>

profile chrome-unconfined /opt/google/chrome/chrome flags=(unconfined) {
  userns,

  include if exists <local/chrome>
}
```

For a Nix app, adapt that:

1. Find the real Nix store path of the binary, e.g. for Obsidian:

```bash
readlink -f "$(which obsidian)"
# e.g. /nix/store/xyz...-obsidian-1.6.7/bin/obsidian
```

2. Create an AppArmor profile, e.g. `/etc/apparmor.d/nix-obsidian`:

```bash
sudo nano /etc/apparmor.d/nix-obsidian
```

Put something like:

```apparmor
abi <abi/4.0>,

include <tunables/global>

profile nix-obsidian /nix/store/*-obsidian-*/**/* flags=(unconfined) {
  userns,

  # site-specific additions
  include if exists <local/nix-obsidian>
}
```

3. Load it and reload AppArmor:

```bash
sudo apparmor_parser -r /etc/apparmor.d/nix-obsidian
sudo systemctl reload apparmor
```

Then try `obsidian` again.

You can do the same for any other Nix app that’s complaining about `chrome-sandbox` (Nix Chrome, VSCodium, etc.).

⚠️ **Security note**: using wildcards like `/*-obsidian-*/**/*` means *any* Nix derivation matching that pattern gets those permissions. On a single-user dev machine that’s probably fine; on a multi-user system you’d want to be more precise (no wildcards, update the profile when the store path changes). This tradeoff is exactly what folks in that GitHub thread were debating.([GitHub][2])

Again, this is all **outside** home-manager; HM can’t write `/etc/apparmor.d` for you on Ubuntu.

---

## Option C – Use distro Chrome/Obsidian, Nix for everything else

One very pragmatic split:

* Install **Chrome, Slack, etc. from Ubuntu or vendor .deb** (they already ship appropriate AppArmor profiles for `/opt/google/chrome/...` etc. and are tested on 24.04).([Ubuntu Community Hub][1])
* Use Nix/Home-manager for basically everything else (CLI tools, i3, dev envs, etc.).

This avoids you having to maintain AppArmor profiles for every Electron thing in the Nix store.

You *can* still keep Nix versions of some apps if you really want, and just apply Option A or B for those specific cases.

---

## Where home-manager fits in (and where it doesn’t)

Home-manager on Ubuntu **cannot**:

* Change `kernel.apparmor_restrict_unprivileged_userns`
* Install AppArmor profiles into `/etc/apparmor.d` by itself

So the answer to “how do I set up my flake-based HM config so Chrome/Obsidian work?” is honestly:

> You don’t do it *in* the flake; you fix the host OS once (Option A or B), and then your existing HM config and Nix packages start working again.

Once you pick:

* **A** (global sysctl) → you’re done after the /etc/sysctl.d file and reboot.
* **B** (per-app AppArmor) → add the `/etc/apparmor.d/nix-…` profiles and reload AppArmor.
* **C** (use distro Chrome/Electron) → install via apt/vendor .deb and let Ubuntu handle the sandboxing; keep Nix for the rest.

If you tell me which way you want to lean (global flip vs per-app profiles vs “just use vendor Chrome”), I can give you a little ready-to-paste checklist tailored to your exact Nix/HM layout.

[1]: https://discourse.ubuntu.com/t/ubuntu-24-04-lts-noble-numbat-release-notes/39890 "Ubuntu 24.04 LTS (Noble Numbat) Release Notes - Release - Ubuntu Community Hub"
[2]: https://github.com/NixOS/nixpkgs/issues/308128?utm_source=chatgpt.com "Obsidian fails to start with The SUID sandbox helper binary ..."


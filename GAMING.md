<!--
SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
SPDX-FileCopyrightText: 2026 AleCl1210 <139965580+AleCl1210@users.noreply.github.com>
-->

# Gaming edition

This is a gaming-focused build of [KDE Linux](https://linux.kde.org), targeted
at mid-range 2022/2023 desktops and laptops — concretely: 11th gen Intel Core
i5 (Tiger Lake) with Intel UHD / Iris Xe integrated graphics, but it works on
any hardware KDE Linux supports (AMD and NVIDIA are covered by the base image
too).

## What you get out of the box

### Gaming stack

| Component | Package(s) | What it does |
|---|---|---|
| Steam | `steam` | Game launcher; runs Windows games through Proton |
| **GE-Proton** | baked into `/usr/share/steam/compatibilitytools.d` | Community Proton build (GloriousEggroll) with extra codec/launcher fixes; selected per game in *Properties → Compatibility* |
| GameMode | `gamemode`, `lib32-gamemode` | Applies CPU/scheduler optimizations while a game runs (`gamemoderun %command%`) |
| MangoHud | `mangohud`, `lib32-mangohud`, `goverlay` | FPS/temperature/usage overlay; a sensible system default lives in `/etc/MangoHud.conf` (enable with `mangohud %command%`, toggle with `Shift_R+F12`) |
| Gamescope | `gamescope` | Valve's gaming compositor: frame limiting, FSR upscaling (`gamescope %command%`) |
| Wine stack | `wine`, `wine-mono`, `wine-gecko`, `winetricks`, `protontricks`, `vkd3d` | Run Windows applications and games outside of Steam, incl. Direct3D 12 → Vulkan |
| DOSBox | `dosbox` | Retro DOS games from before the Windows era |
| 32-bit GPU drivers | `lib32-mesa`, `lib32-vulkan-intel` | Most Windows games are 32-bit; these give them hardware acceleration on Intel iGPUs (plus `lib32-gamemode`/`lib32-mangohud`) |

### Intel hardware support (11th gen "Tiger Lake" and later)

Already part of the base image:

* `mesa` + `vulkan-intel` — OpenGL and Vulkan userspace drivers (Iris/ANV)
* `intel-media-driver` + `libva` — hardware video decode/encode (VA-API iHD)
* `intel-ucode`, `thermald`, `powertop` — microcode, thermal and power management
* `fwupd` — firmware updates (BIOS/UEFI, SSDs, peripherals)
* `linux-firmware` — includes the Intel Wi-Fi/Bluetooth (`iwlwifi`) firmware

Added by this edition:

* `intel-compute-runtime` + `clinfo` — OpenCL / Level Zero (Gen12+ GPUs, i.e. 11th gen and newer)
* `intel-gpu-tools` — `intel_gpu_top` for live GPU load monitoring, plus i915 test tools
* `vulkan-tools`, `mesa-utils` — `vulkaninfo` / `glxinfo` to verify drivers initialize correctly
* `ntsync` module is loaded by default (improves Wine/Proton performance, see
  `mkosi.extra/usr/lib/modules-load.d/ntsync.conf`)

### Diagnostics

| Area | Tools |
|---|---|
| Whole system | `inxi`, `lshw`, `fastfetch`, KDE Info Center, `collect-logs` |
| GPU / graphics | `intel_gpu_top`, `nvtop`, `drm-info`, `vulkaninfo`, `glxinfo`, `vainfo`, `glmark2` |
| CPU / thermals | `sensors` (lm_sensors), `powertop`, `turbostat`, `cpupower`, `thermald` |
| Disks | `smartctl` (smartmontools), `nvme-cli`, `iotop` |
| Network / Wi-Fi | `wavemon` (signal quality), `nmcli`, `iw`, `ethtool`, `mtr`, `gping` |
| USB / devices | `lsusb` (usbutils), `dmidecode` (model/BIOS/memory), `v4l2-ctl` (webcams) |
| Firmware | `fwupdmgr get-devices` |

### Windows compatibility

* NTFS volumes from Windows machines: read/write via `ntfs-3g` (plus the
  `ntfsprogs` tools for partitioning), exFAT via `exfatprogs`
* Samba file sharing, all NetworkManager VPN plugins
* Wine/Proton as described above — for launchers such as Epic or GOG, install
  **Heroic**, **Lutris** or **Bottles** from Flathub via Discover

## Using GE-Proton

1. Start Steam once (online).
2. Library → right-click a game → **Properties… → Compatibility** →
   tick *Force the use of a specific Steam Play compatibility tool* →
   pick the `GE-Proton…` entry.
3. For the global default: *Settings → Compatibility → Enable Steam Play for
   all titles* and pick GE-Proton there.

### Updating GE-Proton

The image ships a pinned GE-Proton release (checksum-verified at build time).
To install a newer one for your user:

```sh
install-proton-ge-latest
```

It downloads the latest release from upstream, verifies the official sha512
checksum, and installs into `~/.steam/root/compatibilitytools.d`. Restart
Steam afterwards. A GUI alternative is
[ProtonUp-Qt](https://flathub.org/apps/net.davidotek.Pupgui2):

```sh
flatpak install flathub net.davidotek.Pupgui2
```

## Performance tips for Intel iGPU machines

* Keep the system updated (Discover → Updates): Mesa/Vulkan driver updates
  land there and directly affect game performance.
* Use `gamemoderun %command%` and/or `mangohud %command%` as Steam launch
  options; both work per-game.
* On laptops, switch the power profile to *Performance* while gaming
  (Power Profiles applet); `thermald` handles the rest.
* Check real driver/limits with `vulkaninfo --summary`, `glxinfo | grep
  "OpenGL renderer"` and `intel_gpu_top`.

## Policy notes

* **No cracks, DRM bypasses or game-piracy tooling are included or will be
  added to this image** (e.g. LuaTools/SteamTools-style "manifest generators").
  Beyond the legal issues, such tools are widely reported to bundle malware and
  the LuaTools desktop app is Windows-only anyway. Buy your games; everything
  here works with legitimately owned titles, including via Proton for Windows
  games you own on Steam.
* Everything in this document is added through the normal package lists
  (`mkosi.conf.d/70-packages-gaming.conf`), Flatpaks, or `mkosi.extra`
  drop-ins — see [GAMING.md's sibling files](mkosi.conf.d/) to tweak the set.

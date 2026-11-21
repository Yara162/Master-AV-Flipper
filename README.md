# Master AV Flipper

One place for every Flipper Zero tool made for AV commissioning: test HDMI paths, read EDIDs,
drive displays over RS-232, survey Wi-Fi, fire IR codes and more, from your pocket instead of a
laptop. This repository is the map, plus the build system that keeps every app compiling.

[![suite](https://github.com/Yara162/Master-AV-Flipper/actions/workflows/suite.yml/badge.svg)](https://github.com/Yara162/Master-AV-Flipper/actions/workflows/suite.yml)

## The tools

| Tool | What it does | Hardware it needs | Repository |
|---|---|---|---|
| Wi-Fi Tools | Survey, signal walk test, join check, AirPlay/Dante/NDI discovery, device finder, stability logger, PJLink/TCP/UDP/HTTP control client | Official Wi-Fi Devboard (flashed with the repo's firmware) | [Flipper-Network-Tools](https://github.com/Yara162/Flipper-Network-Tools) |
| LAN Tools | Wired version of the network tools (in progress) | W5500 Ethernet module | [Flipper-Network-Tools](https://github.com/Yara162/Flipper-Network-Tools) |
| Cereal Tools | RS-232 display and projector control, custom command lists, echo, sniffer, VISCA camera client and server, baud-rate finder | Rabbit-Labs Flip'n Cereal HAT | [Flipper-Cereal-Tools](https://github.com/Yara162/Flipper-Cereal-Tools) |
| VGM Test Patterns | 13 test patterns over HDMI, with resolution and a source label | Video Game Module (with the repo's combined firmware) | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| Pixel Fixer | Colour-noise loop for stuck pixels and image retention | Video Game Module | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| EDID Reader | Reads and decodes a display's EDID; checks HDCP and HDMI 2.0 | HDMI breakout board | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| CEC Tool | Monitors HDMI-CEC and sends power, input and volume | HDMI breakout board | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| HDMI Link Monitor | Watches +5 V and hot-plug in line, logs drops, forces a re-plug | HDMI breakout board | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| Lux Meter | Light meter and nine-point projector brightness test | BH1750 sensor | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| Power Monitor | DC voltage, current and power with logging | INA219 sensor | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| IR converter | Flipper `.ir` to Pronto hex and Global Caché `sendir`, in a browser | None | [flipper-av-tools](https://github.com/Yara162/flipper-av-tools) |
| AV IR library | IR codes for displays and projectors, including discrete power on/off | None (built-in IR) | [Flipper-AVIR](https://github.com/Yara162/Flipper-AVIR) |

Each repository's README says what has been tested on real hardware and what hasn't. Read it
before relying on a tool on site.

## Install everything at once

The [suite workflow](https://github.com/Yara162/Master-AV-Flipper/actions/workflows/suite.yml)
builds every app and bundles them with the IR library. Open the latest successful run, download
the **av-flipper-suite** artifact, and with qFlipper copy:

- `apps/*.fap` to `SD Card/apps/GPIO/`
- `infrared/*.ir` to `SD Card/infrared/`

The apps are built for the current release firmware. If your Flipper runs something else,
rebuild with [ufbt](https://github.com/flipperdevices/flipperzero-ufbt) (see below).

## Build system

### Suite build

[`suite.yml`](.github/workflows/suite.yml) clones every repository in [`repos.txt`](repos.txt) and
builds every app against both the **release** and **dev** SDKs, on each push, every Monday and on
demand. A dev-SDK break is a warning rather than a failure. It means the next firmware release
is likely to break that app, so there's time to fix it first.

### CI for one app repository

[`build-fap.yml`](.github/workflows/build-fap.yml) is a reusable workflow. Copy
[`examples/flipper-ci.yml`](examples/flipper-ci.yml) into an app repository's `.github/workflows/`
and every push builds every app in that repository. Pushing a tag such as `v1.2.0` also creates the
GitHub release and attaches the `.fap` files.

```yaml
jobs:
  build:
    uses: Yara162/Master-AV-Flipper/.github/workflows/build-fap.yml@main
    permissions:
      contents: write
```

Inputs: `channel` (`release`, `rc` or `dev`), `paths` (folders to search, default the whole
repository) and `attach-to-release` (default true).

### Locally

```bash
pip install ufbt
```

```bash
ufbt update
```

```bash
scripts/build-all.sh out path/to/repo-one path/to/repo-two
```

It finds every `application.fam`, builds each app, copies the `.fap` files to `out/` and writes
`out/build-summary.md`. Last run (release SDK 1.5.1): all 10 apps built.

## Website

[`docs/index.html`](docs/index.html) is a one-page site for the suite. To publish it, go to
**Settings → Pages**, choose **Deploy from a branch**, and pick `main` and `/docs`.

## Adding a repository

Add it to `repos.txt`, add its tools to the table above and to `docs/index.html`, and push.

MIT License.

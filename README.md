# Omarchy Prayer Times

**English** | [العربية](README.ar.md)

A prayer-times widget for the [Omarchy](https://omarchy.org/) shell bar. Times come from a [Mawaqit](https://mawaqit.net) mosque page, and a background service handles reminders and the adhan.

## Features
- The next prayer in the bar, with either the time left until the adhan or the adhan time (toggle it in the popup).
- UI and notifications in English or Arabic (toggle in the popup, English by default).
- A popup with a countdown, Gregorian and Hijri dates, all six times with iqama, and the Jumu'ah time.
- A notification and alert sound 20 minutes before each adhan.
- The full adhan at prayer time, with a separate adhan for Fajr.
- The adhan plays on a speaker of your choice, falling back to the default output if it is unplugged.
- Times are cached locally, so it keeps working offline.

## Installation
```bash
git clone https://github.com/3mro777o/omarchy-prayer-times.git
cd omarchy-prayer-times
./install.sh
```

The installer:
- copies `prayer-times` to `~/.local/bin` and the widget to `~/.config/omarchy/plugins/blacknova.prayer-times`,
- downloads the adhan and alert sounds from mawaqit.net (they are not stored in this repo),
- installs `mpv` if it is missing,
- enables the `prayer-times` systemd user service and the bar widget.

## Configuration
At the top of `bin/prayer-times` (or `~/.local/bin/prayer-times` after installing):

| Variable | Meaning |
|---|---|
| `MOSQUE_URL` | Your mosque's page on mawaqit.net (defaults to El Iman Moschee Hamburg) |
| `PREFERRED_SINK` | Part of your speaker's name as shown by `pactl list sinks short` |
| `REMIND_MINUTES` | How many minutes before the adhan the reminder fires |

After any change:
```bash
prayer-times fetch
systemctl --user restart prayer-times
```

## Usage
| Action | Result |
|---|---|
| Left click on the widget | Open the prayer-times popup |
| Right click | Stop the adhan |
| Middle click | Refresh the times |

```bash
prayer-times next        # print the next prayer
prayer-times test [fajr] # play the adhan now (Fajr adhan if "fajr" is given)
prayer-times stop        # stop the adhan
prayer-times fetch       # refresh the times from mawaqit.net
```

## Requirements
Omarchy (Quickshell shell), Python 3, `mpv`, `pactl`, `notify-send`, `curl`.

# Change: Add NordVPN Rofi GUI Program

## Why
Currently, the repository has a basic shell script (`vpn-menu.sh`) for NordVPN interaction via rofi, but it lacks the structured menu system, state management, and polish of the Python-based `rofi-menu` approach used in `multitool`. A dedicated Python program provides better user experience with nested menus, dynamic content loading, and proper status display.

## What Changes
- Add new `modules/programs/nordvpn-rofi/` directory with Python source code using `rofi-menu` library
- Package as a Denix module with NixOS support (Darwin excluded since NordVPN Linux client is NixOS-only)
- Provide comprehensive VPN management: connect/disconnect, server selection by country/city/group, status display, and settings access

## Impact
- Affected specs: New `nordvpn-rofi` capability
- Affected code: `modules/programs/nordvpn-rofi/` (new directory)
- Dependencies: `rofi`, `nordvpn` CLI, `python3`, `rofi-menu` Python package, `libnotify`

## 1. Implementation

- [ ] 1.1 Create `modules/programs/nordvpn-rofi/` directory structure
- [ ] 1.2 Create `pyproject.toml` with `rofi-menu` dependency
- [ ] 1.3 Implement `main.py` with rofi-menu based GUI:
  - [ ] 1.3.1 Main menu with Connect/Disconnect/Status/Settings options
  - [ ] 1.3.2 Country selection submenu (dynamic from `nordvpn countries`)
  - [ ] 1.3.3 City selection submenu (dynamic from `nordvpn cities <country>`)
  - [ ] 1.3.4 Server group selection submenu (dynamic from `nordvpn groups`)
  - [ ] 1.3.5 Status display item showing current connection state
  - [ ] 1.3.6 Quick connect option (fastest server)
  - [ ] 1.3.7 Settings view (read-only display of `nordvpn settings`)
- [ ] 1.4 Create `default.nix` Denix module with proper runtime dependencies
- [ ] 1.5 Add README.md documenting usage

## 2. Testing

- [ ] 2.1 Build the package with `nix build`
- [ ] 2.2 Manually test all menu options with NordVPN CLI available
- [ ] 2.3 Verify notifications work correctly
- [ ] 2.4 Test error handling (e.g., when not logged in)

## 3. Integration

- [ ] 3.1 Run `nix flake check` to validate module
- [ ] 3.2 Run `nix develop -c lint` to check for issues

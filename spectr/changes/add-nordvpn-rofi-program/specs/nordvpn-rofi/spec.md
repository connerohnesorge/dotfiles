## ADDED Requirements

### Requirement: NordVPN Rofi Main Menu
The program SHALL display a rofi-based main menu with options for VPN management when executed.

#### Scenario: Launch main menu
- **WHEN** user executes `nordvpn-rofi`
- **THEN** a rofi menu appears with options: Quick Connect, Connect by Country, Connect by City, Connect by Group, Disconnect, Status, and Settings

### Requirement: Quick Connect
The program SHALL provide a quick connect option that connects to the fastest available server.

#### Scenario: Quick connect success
- **WHEN** user selects "Quick Connect" from main menu
- **THEN** the program executes `nordvpn connect` and displays a notification with connection status

### Requirement: Country Selection
The program SHALL provide a submenu for connecting by country with dynamically loaded country list.

#### Scenario: Connect by country
- **WHEN** user selects "Connect by Country" from main menu
- **THEN** the program displays a submenu populated from `nordvpn countries` output
- **WHEN** user selects a country from the list
- **THEN** the program executes `nordvpn connect <country>` and displays a notification

### Requirement: City Selection
The program SHALL provide a submenu for connecting by city with dynamically loaded city list based on selected country.

#### Scenario: Connect by city
- **WHEN** user selects "Connect by City" from main menu
- **THEN** the program displays a country selection first
- **WHEN** user selects a country
- **THEN** the program displays cities from `nordvpn cities <country>` output
- **WHEN** user selects a city
- **THEN** the program executes `nordvpn connect <country> <city>` and displays a notification

### Requirement: Server Group Selection
The program SHALL provide a submenu for connecting by server group (P2P, Double VPN, etc.).

#### Scenario: Connect by group
- **WHEN** user selects "Connect by Group" from main menu
- **THEN** the program displays a submenu populated from `nordvpn groups` output
- **WHEN** user selects a group
- **THEN** the program executes `nordvpn connect --group <group>` and displays a notification

### Requirement: Disconnect
The program SHALL provide an option to disconnect from the current VPN connection.

#### Scenario: Disconnect from VPN
- **WHEN** user selects "Disconnect" from main menu
- **THEN** the program executes `nordvpn disconnect` and displays a notification confirming disconnection

### Requirement: Connection Status Display
The program SHALL display current VPN connection status in the main menu.

#### Scenario: Show connection status
- **WHEN** main menu loads
- **THEN** a status item displays current connection state from `nordvpn status` (connected/disconnected, server, country, IP)

### Requirement: Settings View
The program SHALL display current NordVPN settings in a read-only submenu.

#### Scenario: View settings
- **WHEN** user selects "Settings" from main menu
- **THEN** the program displays output from `nordvpn settings` in a readable format

### Requirement: Notification Feedback
The program SHALL display desktop notifications for all connection state changes.

#### Scenario: Connection notification
- **WHEN** a connect or disconnect operation completes
- **THEN** a desktop notification is displayed with the operation result (success/failure and details)

### Requirement: Nix Packaging
The program SHALL be packaged as a Denix module installable via NixOS configuration.

#### Scenario: Install via NixOS
- **WHEN** `myconfig.programs.nordvpn-rofi.enable = true` is set in configuration
- **THEN** the `nordvpn-rofi` command is available in system path with all dependencies (rofi, nordvpn, python3, libnotify)

### Requirement: Error Handling
The program SHALL gracefully handle error conditions from the NordVPN CLI.

#### Scenario: Handle not logged in
- **WHEN** user attempts to connect but is not logged into NordVPN
- **THEN** the program displays a notification indicating login is required

#### Scenario: Handle NordVPN not installed
- **WHEN** nordvpn CLI is not available
- **THEN** the program displays an error notification and exits gracefully

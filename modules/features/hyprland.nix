{
  delib,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (delib) singleEnableOption;
in
  delib.module {
    name = "features.hyprland";

    options = singleEnableOption false;
    nixos.ifEnabled = {
      myconfig.programs = {
        ghostty.enable = true;
        explorer.enable = true;
        hyprss.enable = true;
      };
      environment = {
        systemPackages =
          [
            inputs.ghostty.packages."${pkgs.stdenv.hostPlatform.system}".default
            inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".default
            inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
            (pkgs.rofi.override {
              plugins = [
                pkgs.rofi-rbw
                pkgs.rofi-calc
              ];
            })
          ]
          ++ (with pkgs; [
            evince
            kdePackages.konsole
            wl-clip-persist
            hyprcursor
            hyprkeys
            hyprpaper
            playerctl
            hyprsunset # Needs cc at runtime
            stdenv.cc
            xmlstarlet
            hyprwayland-scanner
            hyprutils
            wl-clipboard
            hyprnotify
            uwsm
            grimblast
            grim
            slurp
            kitty
            dunst
            brightnessctl
            hyprls
            swaynotificationcenter
            gnome-control-center
            hyprpicker
            ffmpegthumbnailer
            pipewire
          ]);
      };

      hardware = {
        uinput.enable = true;
        graphics = {
          extraPackages = with pkgs; [
            mesa
          ];
        };
      };

      programs = {
        dconf = {
          enable = true;
          profiles.user.databases = [
            {
              settings."org/gnome/desktop/interface" = {
                gtk-theme = "Adwaita";
                icon-theme = "Flat-Remix-Red-Dark";
                font-name = "Noto Sans Medium 11";
                document-font-name = "Noto Sans Medium 11";
                monospace-font-name = "Noto Sans Mono Medium 11";
              };
            }
          ];
        };
        ydotool.enable = true;
        hyprland = {
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
          portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          enable = true;
          # withUWSM = true;
          xwayland.enable = true;
        };
      };

      security = {
        pam.services = {
          sddm.enableGnomeKeyring = true;
          gdm-password.enableGnomeKeyring = true;
          gdm.enableGnomeKeyring = true;
        };
      };

      services = {
        gnome.gnome-keyring.enable = true;
        desktopManager.gnome.enable = true;
        gvfs.enable = true; # Mount, trash, and other functionalities
        tumbler.enable = true; # Thumbnails
        dbus = {
          enable = true;
          implementation = "broker";
        };
        upower.enable = true;
        xserver = {
          enable = true;
        };
        displayManager.gdm = {
          enable = lib.mkDefault true;
        };
      };

      xdg = {
        menus.enable = true;
        portal = {
          enable = true;
          wlr.enable = true;
          extraPortals = [inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland];

          config.hyprland = {
            default = [
              "hyprland"
            ];
            "org.freedesktop.impl.portal.FileChooser" = "hyprland";
          };
        };
        mime = {
          enable = true;

          defaultApplications = {
            "x-scheme-handler/about" = "zen.desktop";
            "x-scheme-handler/unknown" = "zen.desktop";
            "x-scheme-handler/http" = "zen.desktop";
            "x-scheme-handler/https" = "zen.desktop";
            # PDF
            "application/pdf" = "org.gnome.Evince.desktop";
            # PNG, JPG
            "image/png" = "org.gnome.Loupe.desktop";
            "image/jpeg" = "org.gnome.Loupe.desktop";
            "image/ppm" = "org.gnome.Loupe.desktop";
            # Text
            "text/javascript" = lib.mkDefault "nvim.desktop";
            "text/rust" = lib.mkDefault "nvim.desktop";
            "text/x-python" = lib.mkDefault "nvim.desktop";
            "text/x-java-source" = lib.mkDefault "nvim.desktop";
            "text/x-c" = lib.mkDefault "nvim.desktop";
            "text/x-go" = lib.mkDefault "nvim.desktop";
            "text/x-nix" = lib.mkDefault "nvim.desktop";
            "text/x-ocaml" = lib.mkDefault "nvim.desktop";
            "text/x-scala" = lib.mkDefault "nvim.desktop";
            "text/x-tex" = lib.mkDefault "nvim.desktop";
            "text/x-matlab" = lib.mkDefault "nvim.desktop";
            "text/x-meson" = lib.mkDefault "nvim.desktop";
            "text/x-dart" = lib.mkDefault "nvim.desktop";
            "text/x-readme" = lib.mkDefault "nvim.desktop";
            "text/x-sh" = lib.mkDefault "nvim.desktop";
            "text/x-nushell" = lib.mkDefault "nvim.desktop";
            "text/html" = lib.mkDefault "zen.desktop";
            # Directories
            "inode/directory" = "org.kde.dolphin.desktop";
            "x-scheme-handler/file" = "org.kde.dolphin.desktop";
            "application/octet-stream" = "org.kde.dolphin.desktop";
            # .txt
            "text/plain" = "nvim.desktop";
          };
        };
      };
    };
  }

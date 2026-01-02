{
  delib,
  inputs,
  pkgs,
  lib,
  moduleSystem,
  config,
  ...
}:
delib.rice {
  name = "dark";
  home =
    if pkgs.stdenv.isDarwin
    then {
    }
    else {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
        image = ./../../assets/klaus-desktop.jpeg;
      };
      stylix = {
        targets = {
          dunst.enable = true;
          zellij.enable = true;
          fzf.enable = true;
          k9s.enable = true;
        };
      };
    };
  nixos = {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
      image = ./../../assets/klaus-desktop.jpeg;
      polarity = "dark";
      cursor = {
        size = 12;
        name = "rose-pine-hyprcursor";
        package = pkgs.rose-pine-hyprcursor;
      };
      targets = {
        grub.enable = false;
        qt.enable = false;
        plymouth.enable = false;
        gnome.enable = true;
        gtk.enable = true;
        spicetify.enable = true;
        # KDE Plasma theming works via qt.enable above
        # kde.enable and konsole.enable not available in current Stylix version
      };
    };
  };
}

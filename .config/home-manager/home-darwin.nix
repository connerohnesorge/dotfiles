{
  config,
  pkgs,
  lib,
  username ? "connerohnesorge",
  llm-agents,
  direnv-instant,
  constatus,
  cnb,
  catls,
  swiftbar-grafana-alerts,
  ...
}: let
  ovimSrc = pkgs.fetchFromGitHub {
    owner = "tonisives";
    repo = "ovim";
    rev = "d50ed25c051858e079b537a616ad670f42988f23";
    hash = "sha256-eqJ4jkA7XSY6/VyUAmdZ5rKlzN3/5Aa2B2kRalwco2I=";
  };

  pnpmDeps = pkgs.stdenv.mkDerivation {
    name = "ovim-pnpm-deps";
    src = ovimSrc;
    nativeBuildInputs = with pkgs; [pnpm nodejs jq];
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      export HOME=$TMPDIR
      export PNPM_HOME=$TMPDIR/pnpm-home
      export NODE_EXTRA_CA_CERTS="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      jq 'del(.packageManager)' package.json > package.json.tmp
      mv package.json.tmp package.json
      pnpm install --frozen-lockfile --ignore-scripts
      mkdir -p $out/node_modules
      cp -r node_modules $out/
      chmod -R +w $out
    '';
    outputHashMode = "recursive";
    outputHash = "sha256-6GjutHdm/uDCnFT57DWHZ4G4VQCIa3CkU4WZ3saVF4c=";
  };

  ovimFrontend = pkgs.stdenv.mkDerivation {
    name = "ovim-frontend";
    src = ovimSrc;
    nativeBuildInputs = with pkgs; [pnpm nodejs jq];
    buildPhase = ''
      export HOME=$TMPDIR
      export PNPM_HOME=$TMPDIR/pnpm-home
      export NODE_EXTRA_CA_CERTS="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      jq 'del(.packageManager)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp -r ${pnpmDeps}/node_modules ./node_modules
      chmod -R +w ./node_modules
      pnpm build
    '';
    installPhase = ''
      mkdir -p $out
      cp -r dist $out/
    '';
  };

  # Extract just src-tauri so ../dist works relative to it during cargo build
  ovimRustSrc = pkgs.runCommand "ovim-rust-src" {} ''
    cp -r ${ovimSrc}/src-tauri $out
  '';

  ovimPkg = pkgs.rustPlatform.buildRustPackage {
    pname = "ovim";
    version = "0.0.31";
    src = ovimRustSrc;
    cargoHash = "sha256-3bwkDyu4X7QuPUjSB02YWPQn7LmdKqzh+QVUp+6sxJ0=";
    buildInputs = with pkgs; [libiconv];
    nativeBuildInputs = with pkgs; [pkg-config];
    cargoExtraArgs = "--bins";
    preBuild = ''
      mkdir -p ../dist
      cp -r ${ovimFrontend}/dist/* ../dist/
    '';
    TAURI_PRIVATE_KEY = "";
    TAURI_KEY_PASSWORD = "";
    doCheck = false;
  };

  pikoPkg = pkgs.buildGoModule {
    pname = "piko";
    version = "0.10.0";
    src = pkgs.fetchFromGitHub {
      owner = "andydunstall";
      repo = "piko";
      rev = "v0.10.0";
      hash = "sha256-fOdPtPeUKHw0e//PrvqvwhjGpYB4C7x0tGJckVRBEkQ=";
    };
    vendorHash = "sha256-fDhG1YeuoAw+wkrPRUONW0Sb/aPzwFDMmLadOefxVsw=";
  };

  # Honcho Python SDK (https://pypi.org/project/honcho-ai/) - runtime dep of honcho-cli.
  # Not in nixpkgs, so packaged from PyPI here.
  honcho-ai = pkgs.python3Packages.buildPythonPackage rec {
    pname = "honcho-ai";
    version = "2.1.2";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "honcho_ai";
      inherit version;
      hash = "sha256-8sAUY5MeGhbMQ5Z5DhsDh9WW+1641tyDDWq3QvhwEiQ=";
    };
    build-system = with pkgs.python3Packages; [setuptools wheel];
    dependencies = with pkgs.python3Packages; [httpx pydantic typing-extensions];
    pythonImportsCheck = ["honcho"];
    doCheck = false;
  };

  # honcho-cli (https://pypi.org/project/honcho-cli/) - "A terminal for Honcho".
  # Provides the `honcho` command. Not in nixpkgs, so packaged from PyPI here.
  honcho-cli = pkgs.python3Packages.buildPythonApplication rec {
    pname = "honcho-cli";
    version = "0.1.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      pname = "honcho_cli";
      inherit version;
      hash = "sha256-kkYJvZAb6SGWvMHb1/qHzuumBQ5ZHf+Vxb9ouLy8BWg=";
    };
    build-system = [pkgs.python3Packages.hatchling];
    dependencies =
      (with pkgs.python3Packages; [typer rich httpx click])
      ++ [honcho-ai];
    pythonImportsCheck = ["honcho_cli"];
    doCheck = false;
  };
in {
  imports = [
    direnv-instant.homeModules.direnv-instant
  ];
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    sessionVariables = {
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      RTK_TELEMETRY_DISABLED = "1";
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
      CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING = "1";
      DISABLE_INSTALL_GITHUB_APP_COMMAND = "1";
      DISABLE_TELEMETRY = "1";
      DISABLE_UPGRADE_COMMAND = "1";
      DISABLE_EXTRA_USAGE_COMMAND = "1";
      DISABLE_FEEDBACK_COMMAND = "1";
      DISABLE_ERROR_REPORTING = "1";
      GITLAB_HOST = "https://software.cottinghambutler.com";
    };

    file."Library/Application Support/SwiftBar/Plugins/grafana-alerts.30s.sh".source = "${swiftbar-grafana-alerts.packages.aarch64-darwin.default}/share/swiftbar-grafana-alerts/plugins/grafana-alerts.30s.sh";
    file."Library/Application Support/SwiftBar/Plugins/firepit-messages.30s.sh".source = "${swiftbar-grafana-alerts.packages.aarch64-darwin.default}/share/swiftbar-grafana-alerts/plugins/firepit-messages.30s.sh";

    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.
    packages = with pkgs; [
      fzf
      stow
      atuin
      zsh
      zinit
      starship
      carapace
      kubectl
      bun
      curl
      wget
      git
      gnupg
      lsd
      wordnet
      imagemagick
      lua54Packages.luarocks
      colima
      chafa
      ueberzugpp
      viu
      mermaid-cli
      lazygit
      fd
      delta
      zoxide
      nodejs
      awscli2
      velero
      neovim
      ripgrep
      ghostscript
      python313Packages.huggingface-hub
      zellij
      tilt
      kind
      openssl
      pandoc
      pkg-config
      tree
      cmake
      bat
      python314
      poppler
      glow
      gh
      glab
      natscli
      gcc
      ninja
      lazydocker
      openssl
      sad
      uv
      (pkgs.writeShellApplication
        {
          name = "nviml";
          text = builtins.readFile ./nviml.sh;
          excludeShellChecks = [
            "SC2068"
            "SC2155"
          ];
        })
      clickhouse
      argo-workflows
      omnictl
      talosctl
      tree-sitter
      k9s
      tectonic
      natscli
      skopeo
      ffmpeg
      egctl
      coreutils-prefixed
      eza
      azure-cli
      # kargo
      yq-go
      trivy
      natscli
      sops
      python313Packages.huggingface-hub
      # llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".rtk
      llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".agent-browser
      llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".hermes-agent
      espeak-ng
      constatus.packages.aarch64-darwin.default
      catls.packages.aarch64-darwin.default
      cnb.packages.aarch64-darwin.default
      keycastr
      sqlcmd
      kubeseal
      ovimPkg
      aerospace
      swiftbar
      karabiner-elements
      jankyborders
      argocd
      git-bug
      terminal-notifier
      pikoPkg
      honcho-cli
      snouty
      krew

      apple-sdk_15
      libiconv
      duti
    ];
  };

  # Let Home Manager install and manage itself.
  programs = {
    direnv-instant.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    # zed-editor = {
    #   enable = true;
    #   extensions = [
    #     "nix"
    #     "dockerfile"
    #     "toml"
    #     "html"
    #     "templ"
    #     "latex"
    #     "svelte"
    #     "golangci-lint"
    #     "astro"
    #     "python-lsp"
    #     "ocaml"
    #     "vhdl"
    #     "verilog"
    #   ];
    #   userSettings = {
    #     ui_font_size = 16;
    #     buffer_font_size = 16;
    #     telemetry.enable = false;
    #     vim_mode = true;
    #     theme = {
    #       mode = "dark";
    #       dark = "One Dark";
    #       light = "One Light";
    #     };
    #   };
    # };
    home-manager.enable = true;
  };
}

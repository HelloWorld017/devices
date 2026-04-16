{ pkgs, latestPkgs, repo, inputs, system, ... }:
{
  imports = [
    repo.fastfetch
    repo.git
    repo.nvim
    repo.tmux
    repo.zsh
  ];

  config = {
    environment.systemPackages = with pkgs; [
      clang_19
      coreutils
      git
      wget
    ];

    home.packages = with pkgs; [
      inputs.agenix.packages.${system}.default
      bat
      binwalk
      btop
      buildah
      ethtool
      cmake
      curlie
      dig
      eza
      fastmod
      fd
      ffmpeg
      file
      fzf
      inetutils
      jq
      kubectl
      net-tools
      nodejs
      ouch
      pkg-config
      nodePackages.pnpm
      podman
      podman-compose
      python314
      pv
      ripgrep
      smartmontools
      tcpdump
      tealdeer
      unzip
      virtualenv
      latestPkgs.yt-dlp
      zip
    ];
  };
}

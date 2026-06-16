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
      clang_22
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
      net-tools
      nodejs
      ouch
      pkg-config
      pnpm
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

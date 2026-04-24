{ pkgs, repo, latestPkgs, inputs, ... }:
{
  imports = [
    repo.fastfetch
    repo.git
    repo.nvim
    repo.opencode
    repo.tmux
    repo.wsl
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
      cmake
      dig
      eza
      fastmod
      fd
      ffmpeg
      file
      fzf
      go
      gopls
      inetutils
      jq
      net-tools
      nftables
      nodejs
      ouch
      nodePackages.pnpm
      pkg-config
      podman
      podman-compose
      pv
      python314
      qemu_kvm
      ripgrep
      tealdeer
      unzip
      uv
      virtualenv
      latestPkgs.yt-dlp
      zip
    ];
  };
}

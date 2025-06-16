{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  boot.kernelPatches = [
    {
      name = "DMIC";
      patch = /etc/nixos/patches/DMI.patch;
    }
  ];

  # 🧠 Load mic driver and firmware
  boot.kernelModules = [ "snd_pci_acp6x" ];
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.amdgpu.amdvlk.enable = true;

  services.printing.enable = true;

  # 🎧 Audio configuration with modern UCM override
  hardware.alsa.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = lib.mkForce true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # ✅ correct UCM override method
    extraConfig.pipewire."context.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  users.users.yogs = {
    isNormalUser = true;
    description = "Yogs";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [
      firefox
      obs-studio
      neovim
      steam
      spotify
      gcc
      vscode
      android-tools
      python310Full
      git
      gh
      discord
      go
      flex
      bison
      ncurses
      gnumake42
      bc
    ];
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    inxi
  ];

  system.stateVersion = "25.05";
}


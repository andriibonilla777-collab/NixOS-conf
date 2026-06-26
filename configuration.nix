# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ./macbookpro14-sound.nix
    ];

# Настройка EFI загрузчика systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Panama";

  # Select internationalisation properties.
  i18n.defaultLocale = "ru_RU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_PA.UTF-8";
    LC_IDENTIFICATION = "es_PA.UTF-8";
    LC_MEASUREMENT = "es_PA.UTF-8";
    LC_MONETARY = "es_PA.UTF-8";
    LC_NAME = "es_PA.UTF-8";
    LC_NUMERIC = "es_PA.UTF-8";
    LC_PAPER = "es_PA.UTF-8";
    LC_TELEPHONE = "es_PA.UTF-8";
    LC_TIME = "es_PA.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."andey" = {
    isNormalUser = true;
    description = "andey";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
hardware.enableAllFirmware = true;
boot.kernelParams = [ "snd-hda-intel.model=intel-mac-auto" ];

# Enviroment packages (Приложения)

environment.systemPackages = with pkgs; [
    fastfetch # Инфа о ПК.
    brave # Основной Браузер.
    plocate # Поиск файлов.
    cava # Менеджер для звука.
    steam # Игры.
    kitty # Терминал. 
    git # github. В случае чп смогу откатиться.
  ];

programs.zsh.enable = true;
users.users.andey.shell = pkgs.zsh;

# Кастом Программы

programs.bash.shellAliases = {
  conf = "sudo nano /etc/nixos/configuration.nix";
};

  systemd.services.cache-clean30 = {
    script = "nix-collect-garbage --delete-older-than 30d"; 
    serviceConfig = { 
      Type = "oneshot"; 
    };
   }; 
  
  systemd.timers.cache-clean30 = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  
  services.locate = {
    enable = true; 
    package = pkgs.plocate; 
    interval = "daily"; 
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:


let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in


{
  # Imports
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
       inputs.spicetify-nix.nixosModules.default    
   ];

 



  programs.spicetify = {
    enable = true;

# This allows the Marketplace to function better within the Nix sandbox
      
 
    # This replaces the 'current_theme' error
    theme = spicePkgs.themes.starryNight; 
    colorScheme = "Galaxy";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
    ];
    
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
 

  
  
# This creates the encrypted tunnel that hides your traffic from the school
  # The WireGuard Tunnel


home-manager.backupFileExtension = "backup";
  
  # Essential for VPNs on NixOS to prevent "routing loops"
  networking.firewall.checkReversePath = false;

networking.networkmanager.wifi.scanRandMacAddress = true;

  # 2. Define the WireGuard interface
  networking.wg-quick.interfaces.proton0 = {
    # Set autostart to false while testing so you don't get stuck in a boot loop!
    autostart = false; 
    
    # Internal VPN IP addresses (from your Proton config)
    address = [ "10.2.0.2/32" "2a07:b944::2:2/128" ];

    # USE PUBLIC DNS HERE to prevent the "No Internet" issue
    # This ensures your computer can always find websites even if Proton's DNS is slow
    dns = [ "1.1.1.1" "9.9.9.9" ]; 

    privateKeyFile = "/etc/nixos/wireguard_private.key";
    
    # Lower MTU is essential for restricted school networks to prevent packet loss
    mtu = 1280;

    peers = [
      {
        # Your specific Proton server public key
        publicKey = "VZghTYxgyeiYtJ8HcBRaOFRnRjqSoNYMHVSoOQLz3gA=";
        
        # This forces ALL traffic into the tunnel
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        
        # Using Port 443 (HTTPS port) makes the VPN look like normal web traffic
        endpoint = "95.173.217.65:443"; 
        
        persistentKeepalive = 25;
      }
    ];
  };

  # 3. Extra privacy: Force system-wide DNS to be handled safely
  services.resolved.enable = true;



networking.dhcpcd.extraConfig = "nohook resolv.conf";

networking.networkmanager.dns = "systemd-resolved";
services.tailscale.enable = true;

services.nextdns.enable = true;
services.nextdns.arguments = [ "-config" "e82b95" "-report-client-info" ];

services.tor.enable = true;
services.tor.client.enable = true;


    programs.wireshark = {
    enable = true;
    package = (import <nixpkgs-stable> { config = config.nixpkgs.config; }).wireshark;
   
};

  # System packages
  environment.systemPackages = with pkgs; [
#Apps

    wget
    android-tools 
    taskwarrior3
    inotify-tools
    file
    pipes 
    cbonsai
    proton-vpn-cli
    tor
    vesktop
    wofi
    nextdns
    tailscale
    tor-browser
    torsocks
    git
    killall
    btop  
    mpv
    zenity
    matugen
    gpu-screen-recorder
    neovim 
    fzf
    direnv
    zbar
    ffmpeg
    (wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) {})
    vscode
    kitty
    libreoffice-qt
    obsidian
    discord
    
    gh
    p7zip
    papers
    google-chrome
    fastfetch
    jetbrains.idea-oss
    quickshell
    gnome-shell-extensions
    grim
    playerctl
    satty
    yq-go
    xdg-desktop-portal-gtk
    eww
    swappy
    slurp
    mpvpaper
    swww
    awww
    gnome-tweaks
    pkgsCross.mingwW64.stdenv.cc
    wmctrl
   # bottles
    qbittorrent
    power-profiles-daemon
    jdk8
    steam-run
#hacking things
    nmap
    sherlock
  ];

systemd.user.services.awww-daemon = {
  description = "Awww wallpaper daemon";
  wantedBy = [ "graphical-session.target" ];
  partOf = [ "graphical-session.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.awww}/bin/awww-daemon";
    Restart = "always";
    RestartSec = "5";
  };
};

  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # User accounts and security
  users.users.waffle = {
    isNormalUser = true;
    description = "waffle";
    extraGroups = [ "networkmanager" "wheel" "video" "wireshark"  "adbusers" "libvirtd"]; 
    packages = with pkgs; [
    #  thunderbird
    ];
    useDefaultShell = true;
    shell = pkgs.zsh;
  };    

  users.defaultUserShell = pkgs.zsh;
  system.userActivationScripts.zshrc = "touch .zshrc";

  security.sudo.extraRules = [
    {
      users = [ "waffle" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
  }; 
  # Program configurations
  programs.zsh.enable = true;

 # programs.adb.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  programs.dconf = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
  };
  programs.gamemode.enable = true;

  # Home manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true; 
  
  

  # Desktop environment, window managers and theme
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  
  # Hyprland
  programs.hyprland.enable = true;
  
  # XDG Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
  };

  # Fonts
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf
  ]; 

  fonts.fontconfig = {
    enable = true;
    hinting.style = "slight"; 
    subpixel.rgba = "rgb"; 
  };

  # Flatpak
  services.flatpak.enable = true;

  # Environment Variables
  # environment.variables.XDG_DATA_DIRS = lib.mkForce "/home/ilyamiro/.nix-profile/share:/run/current-system/sw/share";

  # Networking and time
  networking.hostName = "waffle"; 
  
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; 
  };
   # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Audio and system services
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.blueman.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the OpenSSH daemon.
 ### services.openssh.enable = true;

  # Power Management Services
  services.power-profiles-daemon.enable = true; 

  # Nix settings and maintenance
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };
  boot = {
    plymouth = {
      enable = true;
      theme = "simple";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "plymouth-theme-simple";
          version = "1.0";
          
          # CHANGE THIS to the actual path of your custom theme folder
          src = /etc/nixos/config/programs/plymouth/simple; 

          installPhase = ''
            mkdir -p $out/share/plymouth/themes/simple
            cp -r * $out/share/plymouth/themes/simple/
            
            # This dynamically replaces the @out@ placeholder with the real Nix store path
            substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
              --replace "@out@" "$out"
          '';
        })      
	];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "amd_pstate=active" 
      "tsc=reliable" 
      "asus_wmi"
    ];
    
  };
  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
	
  # Bootloader and kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel Packages and Optimization
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.cpu.amd.updateMicrocode = true;

  boot.kernelModules = [ "tcp_bbr" ]; # FIX: Network Congestion Control (Helps with packet jitter)
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 1073741824;
    "net.core.rmem_max" = 1073741824;
    "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
  };

  # FIX: Force CPU to run at max clock speed to prevent frame-time jitter
  powerManagement.cpuFreqGovernor = "performance";

  # ==========================================
  # GPU / GRAPHICS CONFIGURATION (ADDED)
  # ==========================================
      # Bus IDs derived from your lspci output
      # NVIDIA: 01:00.0 -> PCI:1:0:0
      # AMD: 04:00.0 -> PCI:4:0:0
      
      hardware.graphics = {
    enable = true;
    enable32Bit = true; 
  };

  system.stateVersion = "25.11"; 
}

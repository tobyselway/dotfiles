# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;

in {
  nix = {
    package = pkgs.nixUnstable;
   # extraOptions = ''
   #   experimental-features = nix-command flakes
   # '';
  };
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      hyprland.nixosModules.default
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "studio"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;

  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "pt";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
  users.users.toby = {
    isNormalUser = true;
    description = "Toby Selway";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.toby = { pkgs, ... }: {
    
    imports = [
      hyprland.homeManagerModules.default
    ];

    home.packages = with pkgs; [
      wofi

      /* Dev */
      nodejs
      nodePackages.vue-cli
      php82
      php82Packages.composer
    ];

    # Wofi
    home.file."/home/toby/.config/wofi/style.css".text = ''
      window {
          margin: 0;
          border: 0;
          background-color: transparent;
      }

      #input {
          padding: 8px 16px;
          border: 4px solid #595959;
          background-color: #202020;
          border-radius: 12px;
          margin-bottom: 12px;
          font-size: 16pt;
          font-weight: 500;
      }

      #inner-box {
          border: 0;
          background-color: transparent;
      }

      #outer-box {
          border: 0;
          background-color: transparent;
      }

      #scroll {
          margin: 0;
          background-color: transparent;
      }

      #entry {
          margin: 4px 0;
          border-radius: 10px;
          border: 2px solid #595959;
          background-color: #202020;
          padding: 12px 12px;
      }

      #entry:selected {
          border: 2px solid #33ccff;
      }

      #text {
          color: #888888;
          font-size: 12pt;
          font-weight: 500;
          margin-left: 8px;
      }

      #text:selected {
          color: #ffffff;
      }

    '';

    # Hyprland
    wayland.windowManager.hyprland = {
      enable = true;

      # default options, you don't need to set them
      package = hyprland.packages.${pkgs.system}.default;

      extraConfig = ''
        monitor=HDMI-A-1, preferred, 0x0, auto
        monitor=eDP-1, preferred, 1920x0, auto

        wsbind=1,HDMI-A-1
        wsbind=2,HDMI-A-1
        wsbind=3,HDMI-A-1
        wsbind=4,HDMI-A-1
        wsbind=5,HDMI-A-1
        wsbind=6,HDMI-A-1
        wsbind=7,HDMI-A-1
        wsbind=8,HDMI-A-1
        wsbind=9,eDP-1
        wsbind=10,eDP-1


        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox
        exec-once = waybar & /nix/store/$(ls -la /nix/store | grep 'polkit-kde' | grep '4096' | awk '{print $9}' | sed -n '$p')/libexec/polkit-kde-authentication-agent-1 &

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf

        # Some default env vars.
        env = XCURSOR_SIZE,24

        # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
        input {
            kb_layout = pt
            kb_variant =
            kb_model =
            kb_options =
            kb_rules =

            follow_mouse = 1

            touchpad {
                natural_scroll = no
            }

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }

        general {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            gaps_in = 6
            gaps_out = 10
            border_size = 4
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            layout = master
        }

        decoration {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            rounding = 16
            blur = yes
            blur_size = 4
            blur_passes = 1
            blur_new_optimizations = on
            active_opacity = 0.9
            inactive_opacity = 0.8

            drop_shadow = no
            shadow_range = 4
            shadow_render_power = 3
            col.shadow = rgba(1a1a1aee)
        }

        animations {
            enabled = yes

            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

            bezier = myBezier, 0.05, 0.9, 0.1, 1.05

            animation = windows, 1, 7, myBezier
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = borderangle, 1, 8, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }

        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = yes # you probably want this
        }

        master {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = false
        }

        gestures {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = off
        }

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
        device:epic-mouse-v1 {
            sensitivity = -0.5
        }

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

        windowrule = opacity 1.0 override 0.8 override,^(chromium-browser)$
        windowrule = float,^(com.github.wwmm.easyeffects)$

        windowrule = noborder,^(ulauncher)$
        windowrule = float,^(ulauncher)$
        windowrule = noblur,^(ulauncher)$
        #windowrule = fullscreen,^(ulauncher)$


        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        $mainMod = SUPER

        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        bind = $mainMod, Q, killactive
        bind = $mainMod, return, exec, alacritty 
        bind = $mainMod, M, exit,
        bind = $mainMod, E, exec, nemo
        bind = $mainMod, F, togglefloating, 
        bind = $mainMod, space, exec, wofi --show drun -s /home/toby/.config/wofi/style.css --width=30% --height=32% --prompt=" Launch" --term=alacritty --matching=fuzzy --no-actions --allow-images
        # bind = $mainMod, space, exec, ulauncher
        bind = $mainMod, P, pseudo, # dwindle
        bind = $mainMod, J, togglesplit, # dwindle

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

        # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
      '';

      xwayland = {
        enable = true;
        hidpi = true;
      };

      nvidiaPatches = false;
    };

    programs = {

      home-manager.enable = true;

      waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";

            modules-left = [ "hyprland/window" ];
            modules-center = [ "clock" ];
            modules-right = [ "network" "tray" ];

            "hyprland/window" = {
                format = "{}";
                separate-outputs = true;
            };

            clock = {
                format-alt = "{:%a, %d. %b  %H:%M}";
            };

            network = {
              interface = "eno1";
              format = "{ifname}";
              format-wifi = "{essid} ({signalStrength}%)";
              format-ethernet = "{ipaddr} /{cidr}";
              format-disconnected = "No network";
              tooltip-format = "{ifname} via {gwaddr}";
              tooltip-format-wifi = "{essid} ({signalStrength}%)";
              tooltip-format-ethernet = "{ifname}";
              tooltip-format-disconnected = "Disconnected";
              max-length = 50;
            };

            tray = {
              icon-size = 21;
              spacing = 10;
            };
          };
        };

        style = ''
          * {
            border: none;
            border-radius: 0;
            font-family: Roboto, Helvetica, Arial, sans-serif;
            font-size: 14px;
            font-weight: bold;
            min-height: 0;
          }

          window#waybar {
            background: transparent;
            color: white;
          }

          #window {
            margin: 4px 4px;
            padding: 0 10px;
            border-radius: 20px;
            background-color: #303030;
          }

          #clock {
            margin: 4px 0;
            padding: 0 10px;
            border-radius: 20px;
            background-color: #303030;
          }

          #network {
            margin: 4px 4px;
            padding: 0 10px;
            border-radius: 20px;
            background-color: #303030;
          }
        '';
      };

      fish = {
        enable = true;
      };

      alacritty = {
        enable = true;
        settings = {
          window = {
            padding = {
              x = 16;
              y = 16;
            };
          };
          shell.program = "fish";
        };
      };

      git = {
        enable = true;
        userName = "Toby Selway";
        userEmail = "tobyselway@outlook.com";
      };

      chromium = {
        enable = true;
      };

      vscode = {
        enable = true;
        package = pkgs.vscodium;
      };

    };

    home.sessionPath = [
      "/home/toby/.config/composer/vendor/bin"
    ];

    home.stateVersion = "22.11";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    xterm
    vim
    wget
    killall
    helvum
    easyeffects
    polkit-kde-agent
    curl
    htop
    neofetch
    macchina
    hyprpaper
    wmctrl
    nnn
    cinnamon.nemo
  ];

  # Polkit
  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
  system.stateVersion = "22.11"; # Did you read the comment?

}

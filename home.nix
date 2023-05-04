{ config, pkgs, inputs, hyprland, ... }:

{

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    /* UI */
    wofi

    /* Dev */
    nodejs
    nodePackages.vue-cli
    php82
    php82Packages.composer

    /* Fonts */
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    /* Utils */
    gnome3.seahorse
  ];

  home.file = {
    ".config/wofi/style.css".source = ./configs/wofi/style.css;
    #".vimrc".source = ./configs/.vimrc;
    ".xprofile".text = ''
      eval $(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)
      export SSH_AUTH_SOCK
    '';
  };


  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;

    # default options, you don't need to set them
    package = hyprland.packages.${pkgs.system}.default;

    extraConfig = (builtins.readFile ./configs/hyprland/hyprland.conf);

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

      style = (builtins.readFile ./configs/waybar/style.css);
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    alacritty = {
      # TODO: override package to use ligatures
      # package = pkgs.alacritty-ligatures;
      enable = true;
      settings = {
        window = {
          padding = {
            x = 16;
            y = 16;
          };
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
          };
        };
        colors = {
          primary = {
            background = "0x1d1f21";
            foreground = "0xc5c8c6";
          };
          normal = {
            black = "0x424242";
            red = "0xE27373";
            green = "0x83C652";
            yellow = "0xFFBA7B";
            blue = "0x97BEDC";
            magenta = "0xE1C0FA";
            cyan = "0x00988E";
            white = "0xDEDEDE";
          };
          bright = {
            black = "0x676767";
            red = "0xFFA1A1";
            green = "0x98E86D";
            yellow = "0xFFDCA0";
            blue = "0xB1D8F6";
            magenta = "0xFBDAFF";
            cyan = "0x1AB2A8";
            white = "0xFFFFFF";
          };

        };
        shell.program = "fish";
      };
    };

    git = {
      enable = true;
      userName = "Toby Selway";
      userEmail = "tobyselway@outlook.com";
      package = pkgs.gitFull;
      extraConfig.credential.helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
    };

    gpg.enable = true;

    wlogout = {
      enable = true;
      layout = [
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
      ];
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    chromium = {
      enable = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
    };

  };

  services = {

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gtk2"; # Hyprland/Wayland
    };

  };

  home.sessionPath = [
    "/home/toby/.config/composer/vendor/bin"
  ];

  home.stateVersion = "22.11";

}

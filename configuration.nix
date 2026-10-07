{ lib, user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
      "com.apple.mouse.tapBehavior" = 1; # enable tap to click globally
      "com.apple.trackpad.scaling" = 1.0; # tracking speed slider: 6 of 10
    };
    dock.autohide = true;
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.0; # tracking speed slider: 6 of 10
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = true;           # show desktop items
    controlcenter.BatteryShowPercentage = true;
    screencapture.location = "/Users/${user}/Documents/screenshots";
    CustomUserPreferences."com.apple.finder".DesktopViewSettings.IconViewSettings.arrangeBy = "grid";
    trackpad.Clicking = true;              # tap to click
  };
  # Reload user preferences so tracking speed takes effect in the current session.
  system.activationScripts.userDefaults.text = lib.mkAfter ''
    /bin/launchctl asuser "$(/usr/bin/id -u ${lib.escapeShellArg user})" \
      /usr/bin/sudo -H -u ${lib.escapeShellArg user} -- \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [ "xykong/tap" ];
    brews = [
      "herdr"
    ];
    casks = [
      # editors / IDEs
      "webstorm"
      "goland"
      "visual-studio-code"
      "cursor"
      "antigravity"

      # dev tools
      "postman"
      "nosqlbooster-for-mongodb"
      "dbeaver-community"
      "docker-desktop"
      "ghostty"
      "wezterm"

      # AI
      "codex"
      "chatgpt"
      "claude"
      "claude-code"

      # browsers
      "brave-browser"
      "google-chrome"

      # everything else
      "discord"
      "xykong/tap/flux-markdown"
      "hiddenbar"
      "localsend"
      "macpacker"
      "obsidian"
      "rectangle"
      "tailscale-app"
      "windscribe"
      "spotify"
      "vorssaint"
    ];
  };
}

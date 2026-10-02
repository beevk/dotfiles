# Installing and updating apps

Every app is declared in this repo, then applied with `./rebuild.sh`.
Never `brew install` by hand: `homebrew.onActivation.cleanup = "zap"` in `configuration.nix` removes anything Homebrew manages that isn't declared.

## Where each kind of app goes

| Kind of app | Where it goes | Example |
|---|---|---|
| Command-line tools | `home.nix` → `home.packages` (nixpkgs) | `ripgrep`, `jq`, `lazygit` |
| Regular Mac apps (`.app`) | `configuration.nix` → `homebrew.casks` | `wezterm`, `google-chrome`, `raycast` |
| Command-line tools missing or outdated in nixpkgs | `configuration.nix` → `homebrew.brews` | `herdr` |
| App Store-only apps | `configuration.nix` → `homebrew.masApps` | Xcode, Amphetamine |

## What to try first

The order depends on the kind of app.

**Command-line tools: nixpkgs first, Homebrew formula (`brews`) second.**
Nix pins exact versions in `flake.lock`, so they're fully reproducible.
Use `brews` only when nixpkgs doesn't have the tool or its version is too old.

**Mac apps: Homebrew cask first, App Store second, Nix last.**

- Many Mac apps update themselves. Nix installs apps into a read-only folder, so those self-updates break.
- Nix-installed apps land in `~/Applications/Home Manager Apps` instead of `/Applications`, which Spotlight and the Dock handle less well.
- Most Mac apps in nixpkgs are missing, unfree, or lag behind.

**App Store:** only for apps you can't get elsewhere, or that you've already bought there.

**Manual installs** (dragging an `.app` from a downloaded `.dmg`): last resort.
`zap` won't remove them, but they also won't come back if you set up a new Mac from this repo.

### Setting up App Store apps

Add this inside the `homebrew` block in `configuration.nix`:

```nix
masApps = {
  "Xcode" = 497799835;   # name is just a label; the number is the App Store ID
};
```

You need to be signed into the App Store already.
`zap` does not remove App Store apps you delete from this list, so uninstall those yourself.

## Finding the right name

- **nixpkgs:** `nix search nixpkgs lazygit`, or <https://search.nixos.org/packages> with the channel set to match `flake.nix` (currently 26.05).
- **Homebrew:** `brew search chrome`, then `brew info --cask google-chrome` (or `brew info <formula>`) to confirm. Or browse <https://formulae.brew.sh>.
- **App Store:** `mas search Xcode`, or take the number after `id` in the app's App Store link (`apps.apple.com/.../id497799835`).

## Updating apps

### Nix packages

Pinned by `flake.lock`, so they only change when you update the lock file:

```sh
nix flake update        # update every input: nixpkgs, nix-darwin, home-manager, nix-homebrew
./rebuild.sh
git commit flake.lock
```

Use `nix flake update nixpkgs` to update only nixpkgs.
This keeps you on the release in `flake.nix` (currently 26.05) with its fixes.
Moving to the next release (for example 26.11) means editing the version numbers in the input URLs in `flake.nix`.

### Homebrew

- `onActivation.autoUpdate = true` only refreshes Homebrew's list of available versions on rebuild. It does not upgrade installed apps.
- To upgrade, run `brew upgrade` whenever you want, or add `onActivation.upgrade = true;` to the `homebrew` block so every rebuild upgrades. That makes each rebuild slower and can pull in new versions when you weren't expecting them.
- Casks that update themselves (Chrome, Claude, and so on) handle their own updates. `brew upgrade` skips them unless you add `--greedy`.

### App Store

Updates through the App Store as usual, or with `mas upgrade`.

## After bootstrap

The first `./bootstrap.sh` run changes your PATH, but only new shells see it.
Run `exec zsh -l` or open a new terminal before using `./rebuild.sh` or newly installed tools.

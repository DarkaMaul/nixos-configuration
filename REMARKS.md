# NixOS

## Import a package with unknown hash

```nix
      dracula = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "sublime";
        rev = "c5de15a0ad654a2c7d8f086ae67c2c77fda07c5f";
        sha256 = lib.fakeSha256;
      } + "/Dracula.tmTheme");
```

Run a rebuild, and copy hash from the error message.
<!> Need to have `lib` available.


## Environment variables
A few places are sourced by KDE Plasma:
- `~/.config/environment.d/`
    * write simply the variable `TOTO=1` in a file
    * they are sourced by lexical order (00-, 10-, 999-)
- ` ~/.config/plasma-workspace/env/` : 
    * in this directory files must be executable and have `.sh` extension
    * the variable must be exported: `export TOTO=1` 

## Shell with IPython

First experiments with `nix-shell`.
I have a `shell.nix` file :

```nix
{ pkgs ? import <nixpkgs> {} }:
let
  python-with-my-packages = pkgs.python3.withPackages (p: with p; [
    ipython
  ]);
in
python-with-my-packages.env # replacement for pkgs.mkShell
```

I still need to understand exactly what it does.


## KDE

### Keyboard Shortcut

It's a mess and a pain...

## Taskbar position

- How to find where the settings is stored:
```console
$ find ~/.config -type f -exec sha256sum {} \; > /tmp/before
$ # change settings
$ find ~/.config -type f -exec sha256sum {} \; > /tmp/after
```

The setting is stored in both:
- ./plasma-org.kde.plasma.desktop-appletsrc
- ./konsolerc

The differences are hard to understand:

```console
$ diff konsolerc /tmp/konsolerc 
< State=AAAA/wAAAAD9AAAAAQAAAAAAAAAAAAAAAPwCAAAAAfsAAAAcAFMAUwBIAE0AYQBuAGEAZwBlAHIARABvAGMAawAAAAAA/////wAAANUBAAADAAAInAAAAm4AAAAEAAAABAAAAAgAAAAI/AAAAAEAAAACAAAAAgAAABYAbQBhAGkAbgBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAAAAAAcAHMAZQBzAHMAaQBvAG4AVABvAG8AbABiAGEAcgEAAAEj/////wAAAAAAAAAA
---
> State=AAAA/wAAAAD9AAAAAQAAAAAAAAAAAAAAAPwCAAAAAfsAAAAcAFMAUwBIAE0AYQBuAGEAZwBlAHIARABvAGMAawAAAAAA/////wAAANUBAAADAAAIyAAAAm4AAAAEAAAABAAAAAgAAAAI/AAAAAEAAAACAAAAAgAAABYAbQBhAGkAbgBUAG8AbwBsAEIAYQByAQAAAAD/////AAAAAAAAAAAAAAAcAHMAZQBzAHMAaQBvAG4AVABvAG8AbABiAGEAcgEAAAEj/////wAAAAAAAAAA
20,21c20,21
< eDP-1 Width 2256x1504=2204
< eDP-1 XPosition 2256x1504=48
---
> eDP-1 Width 2256x1504=2248
> eDP-1 XPosition 2256x1504=4
$ diff /tmp/plasma-org.kde.plasma.desktop-appletsrc plasma-org.kde.plasma.desktop-appletsrc 
< formfactor=2
---
> formfactor=3
35c35
< location=4
---
> location=5
107,108c107,108
< DialogHeight=84
< DialogWidth=2256
---
> DialogHeight=1504
> DialogWidth=419
152c152
< formfactor=2
---
> formfactor=3
155c155
< location=4
---
> location=5
```

Status: do not configure the taskbar position with NIX

## Clipboard

Klipper is responsible
It should not be uninstalled?
https://www.linuxquestions.org/questions/slackware-14/kde-plasma-5-clipboard-4175655887/

## KDE Configuration
https://github.com/samuelgrf/nixos-config/tree/master/config/home/kde
https://github.com/knopki/devops-at-home

## Rycee configuration
https://git.sr.ht/~rycee/configurations/tree/master/item/user/common.nix

## Change a systemd ExecStart

This change the value of ExecStart

```nix
  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""  # Important because we want to override the line
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd --noplugin=sap"
  ];
```

## Check Syntax

Starts an iteractive editor to check the syntax

```command
$ nix repl
```
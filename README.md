# TinyShell
A simple fully working shell without any systemd-related dependencies.

> [!IMPORTANT]
> * This shell is expected to works on non-systemd Hyprland.

## What's working
- Notification
- Left Sidebar: App Launcher, Sytem Tray, Workspaces, Time, Battery.
- Lockscreen: Time, Profile picture, Notification history, MPRIS player.

### MPRIS player
To make sure the player fully works, make sure MPRIS is providing the '_artUrl_' interfacte for the album art to show. You can use [my cmus fork](https://github.com/luthfihakim2004/cmus-mpris-art) which support basu as the systemd/elogind replacement, while also exposing the '_artUrl_' interface.

## To-Dos
- Add volume control
- Add MPRIS player on the homescreen 
- Animations

## Screenshots

![](/previews/Bar.png)
![](/previews/LockScreen.png)

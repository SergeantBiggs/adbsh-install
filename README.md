# adbsh-install

This program provides a way to install android apps using adb.  
It's basically a bash wrapper around adb that allows non-interactive installs Android apps downloaded through [Raccoon](https://raccoon.onyxbits.de/)
  
It's not stable yet, and I don't recommend its use.  
Crucially, it doesn't really check very well if adb is working and has no good standardized privilege escalation.  
I tested it on Arch Linux, but it should *theoretically* work on any Linux Distro

## Dependencies
+ Standard Linux tools (sed, awk, bash) ([base](https://www.archlinux.org/groups/x86_64/base/) in Arch Linux)
+ adb
+ sudo

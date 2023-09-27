## Overview
`yeetd` is a lil' daemon that watches for specific CPU-intensive Simulator processes and stops them in their tracks! `yeetd` runs on both macOS Ventura and Sonoma.

## Why?
Due to some nifty missing entitlement issues in the iOS Simulator, the Xcode 15 release has some **very** nasty CPU issues when running unit or UI tests. Until Apple releases an update addressing this issue, CI testing times can sometimes be up to two or **three** times longer than Xcode 14 running the same tests.

## What are the processes?
During my testing, I found that a handful of *Poster processes (AegirPoster, ExtragalacticPoster, KaleidoscopePoster, etc.) are missing an entitlement, resulting in SpringBoard having a Very Bad Day™ every time it tries to talk to them. SpringBoard *really* likes talking to the Poster processes, which wastes a CPU core or two. `apsd` also has issues because it believes it needs to activate itself (I could be mistaken, but I don't think that the Simulator can activate itself with APNS). By default, yeetd will _not_ kill `apsd` in the Simulator because it causes issues when testing push notifications with the simulator. If you're still seeing performance issues/timeouts when running yeetd, try running `defaults write dev.biscuit.yeetd killapsd true` to tell it to kill apsd.

## Installation
**NOTE: while I've tested this tool extensively, I cannot promise it will fix Xcode in every case. Please test this tool in a testing CI environment before deploying it a production CI environment!**

You can find a package in the Releases section of this repo or build the tool from scratch. If you install the package, it will automatically load `yeetd` as a `LaunchDaemon`.

I've included a helper script that I use to build, package, and notarize macOS packages. To use it, you'll need the following setup:
    - a Developer ID Application AND Installer certificate from the Apple Dev Portal
    - an app specific password to interact with the notarization service

To build the signed package, ensure code signing is correctly setup in the Xcode proejct and run the following command:
```
./build-installer.sh "<your signing identity>" "<app store connet account>" "<team ID>" "<app specific password>"
```

## Extras
I've included an additional helper script named `prewarm_simulators.sh` with the installer. There's a fun "Simulators sometimes take 1-30 minutes to boot for the first time" bug that this script addresses. This script only needs to be run once when creating a new CI template image.

## Apple Folks
Please check out FB13187399 and release a fix ASAP ❤️

## Thanks
Thanks to Saagar for helping me write goofy yet fun code at 2AM and for everyone who helped test & vet this solution! If you have any questions or comments, feel free to open an issue or reach out to me at [@biscuit@social.lol](https://social.lol/@biscuit)

# Homebrew Asterisk
This repo contains the Homebrew formulas I use for my [Asterisk][ast] dev
machine. This is pretty much a few packages which, for one reason or
another, aren't the best fit for going into Homebrew itself.
 
## Installation
    xcode-select --install
    brew tap leedm777/homebrew-asterisk
    brew install asterisk

## Add an asterisk group and user:

    sudo dseditgroup -o create asterisk
    sudo dscl . create /Users/asterisk
    sudo dseditgroup -o edit -a asterisk -t user asterisk

## Make some directories not created during install

    mkdir -p /usr/local/Cellar/asterisk/13/etc/asterisk
    mkdir -p /usr/local/Cellar/asterisk/13/var/run/asterisk

## Get the asterisk-basic configs from github 
## (Optional if you already have your own configs, but make for an easy start)

    git clone https://github.com/matt-jordan/asterisk-configs.git
    cp asterisk-configs/asterisk-13/*.conf /usr/local/Cellar/asterisk/13/etc/asterisk/
    Edit /usr/local/Cellar/asterisk/13/etc/asterisk/asterisk.conf and update necessary
    lines. A suggested basic diff is in asterisk.conf.diff.

## Copy launchctl file

    sudo cp org.asterisk.asterisk.plist /Library/LaunchDaemons/

## Start Asterisk

    launchctl load /Library/LaunchDaemons/org.asterisk.asterisk.plist

[ast]: http://asterisk.org/
[voip-info]: http://www.voip-info.org/wiki/view/Building+Asterisk+on+MacOSX

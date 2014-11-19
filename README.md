# Homebrew Asterisk
This repo contains the Homebrew formulas I use for my [Asterisk][ast] dev
machine. This is pretty much a few packages which, for one reason or
another, aren't the best fit for going into Homebrew itself.
 
## Installation
    brew install https://raw.githubusercontent.com/leedm777/homebrew-asterisk/master/iksemel.rb
    brew install ncurses
    brew install https://raw.githubusercontent.com/leedm777/homebrew-asterisk/master/asterisk.rb

Add an asterisk group and user:

    sudo dseditgroup -o create asterisk
    sudo dscl . create /Users/asterisk
    sudo dseditgroup -o edit -a asterisk -t user asterisk

Follow the instructions in the "Using launchd" section [here][voip-info], but replace /usr/local/asterisk/sbin/asterisk with /usr/local/Cellar/asterisk/12.0.0/sbin/asterisk

## Usage

    launchctl load /Library/LaunchDaemons/org.asterisk.asterisk.plist

[ast]: http://asterisk.org/
[voip-info]: http://www.voip-info.org/wiki/view/Building+Asterisk+on+MacOSX

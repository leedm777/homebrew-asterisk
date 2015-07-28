# Homebrew Asterisk

This repo contains the Homebrew formulas I use for my [Asterisk][ast] dev
machine. This is pretty much a few packages which, for one reason or
another, aren't the best fit for going into Homebrew itself.

## Installation

    xcode-select --install
    brew tap leedm777/homebrew-asterisk
    brew install asterisk

## Configuration

Configuration files are in `/usr/local/etc/asterisk`. Detailed configuration
docs can be found on the [Asterisk wiki][config-docs].

If you have problems after an upgrade, it may be because of bad path information
that ended up in `asterisk.conf`. Check that the directories section looks like:

    [directories](!)
    astetcdir => /usr/local/etc/asterisk
    astmoddir => /usr/local/opt/asterisk/lib/asterisk/modules
    astvarlibdir => /usr/local/var/lib/asterisk
    astdbdir => /usr/local/var/lib/asterisk
    astkeydir => /usr/local/var/lib/asterisk
    astdatadir => /usr/local/var/lib/asterisk
    astagidir => /usr/local/var/lib/asterisk/agi-bin
    astspooldir => /usr/local/var/spool/asterisk
    astrundir => /usr/local/var/run/asterisk
    astlogdir => /usr/local/var/log/asterisk
    astsbindir => /usr/local/opt/asterisk/sbin

## Running asterisk

If you want to just run Asterisk occasionally, just start it up using
`/usr/local/sbin/asterisk -c`. It is recommended to *not* run Asterisk as root.

## Running as a service

To have launchd start asterisk at login:

    ln -sfv /usr/local/opt/asterisk/*.plist ~/Library/LaunchAgents

Then to load asterisk now:

    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.asterisk.plist

To reload asterisk after an upgrade:

    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.asterisk.plist
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.asterisk.plist

To connect to Asterisk running as a service:

    /usr/local/sbin/asterisk -r

To restart asterisk after a `core stop now`:

    launchctl start homebrew.mxcl.asterisk

## Uninstall

To uninstall Asterisk, run `brew rm asterisk`. To get rid of all local state and
configuration data:

    $ rm -rf /usr/local/etc/asterisk /usr/local/var/lib/asterisk \
        /usr/local/var/log/asterisk /usr/local/var/run/asterisk \
        /usr/local/var/spool/asterisk

## Upgrading from older versions

I used to have notes in the README for creating an `asterisk` user for running
Asterisk. This is not very homebrew-y, so I dropped it.

I also had a custom plist that I recommended instead of homebrew's built-in
plist feature. If you had followed those instructions, you may need to remove
`/Library/LaunchDaemons/org.asterisk.asterisk.plist` before installing
[the new plist above](#Running as a service).

 [ast]: http://asterisk.org/
 [config-docs]: https://wiki.asterisk.org/wiki/x/cYXAAQ

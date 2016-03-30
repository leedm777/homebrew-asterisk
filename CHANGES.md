# homebrew-asterisk

## 2016-03-30

 * Asterisk 13.8.0

## 2016-03-29

 * Added `--with-sounds-*` options for installing additional sound files

## 2016-02-09

 * Asterisk 13.7.2 (Security Release)

## 2016-02-05

 * Asterisk 13.7.1 (Security Release)

## 2016-01-21

 * Added docs for how to fix the `/usr/lib/bundle1.o: No such file or directory`
   problem

## 2016-01-18

 * Upgrade to Asterisk 13.7.0

## 2015-12-02

 * More #21 - Use system ncurses

## 2015-11-26

 * Removed unneeded dep on gmime
 * #21 - Use system ODBC and SQLite

## 2015-11-19

 * Added separate optimize and dev-mode options (although dev-mode still implies
   dont-optimize)

## 2015-10-29

 * Use GitHub instead of Gerrit for HEAD and devel builds, so we're cloning
   from a repo instead of a code review tool

## 2015-10-13

 * Added changelog
 * Upgrade to Asterisk 13.6.0
 * Upgrade to PJSIP 2.4.5
 * Travis: Refine brew upgrade to only upgrade dependencies

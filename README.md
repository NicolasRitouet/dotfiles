# Setup a fresh linux box

## Todo
- Rollback if password error while creating a user
- improve prompt
- Correctly copy sublime prefs (all files)
- put files in separate directories
- install chrome
- install Vert.x
- install Node.js


## Install
Run this:

    wget -O install.tar.gz http://github.com/NicolasRTT/dotfiles/tarball/master; tar zxvf *.gz; cd *dotfiles*; ./install.sh


## Session Duration install
Run this:

    wget -O temp_aliases https://raw.github.com/NicolasRTT/dotfiles/master/.bash_aliases
    . ./temp_aliases

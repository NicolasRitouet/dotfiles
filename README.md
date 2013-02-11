# Setup a fresh linux box

## Install
Run this:

    wget -O install.tar.gz http://github.com/NicolasRTT/dotfiles/tarball/master --no-check-certificate; tar zxvf *.gz; cd *dotfiles*; sudo ./install.sh

## Session Duration Setup (for aliases)
Run this:

    wget -O temp_aliases https://raw.github.com/NicolasRTT/dotfiles/master/.bash_aliases; . ./temp_aliases

## What does it do?
- [Update & upgrade](https://github.com/NicolasRTT/dotfiles/blob/master/install.sh#L209-215)
- [Create a new user and add it to sudoers](https://github.com/NicolasRTT/dotfiles/blob/master/install.sh#L231-240)
- [Disable SSH root login](https://github.com/NicolasRTT/dotfiles/blob/master/install.sh#L243-247)
- Install [bash-it](https://github.com/revans/bash-it) and add custom aliases
- [Copy dotfiles](https://github.com/NicolasRTT/dotfiles/blob/master/install.sh#L250-263)
- Clone and symlink dotfiles
- Install Yeoman and dependencies
- Install sublime-text2 and copy settings
- Install [extras](https://github.com/NicolasRTT/dotfiles/blob/master/extra) 
- [Create a SSH key for Github](https://github.com/NicolasRTT/dotfiles/blob/master/install.sh#L114-143)


## Todo
- add .bash_profile in .bashrc
- Change SSH port
- Fix compass installation (Gem not in the path? $PATH:/var/lib/gems/1.8/bin)
- Fix SSH generation problem (copy the public key in the right place?)
- Rollback if password error while creating a user
- Correctly copy sublime prefs (all files)
- put files in separate directories
- install Vert.x
- install Node.js

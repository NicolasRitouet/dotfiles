# Setup a fresh Linux box

## Install on Linux
Run this:

    wget -O install.tar.gz http://github.com/NicolasRitouet/dotfiles/tarball/master --no-check-certificate; tar zxvf install.tar.gz; cd *dotfiles*; ./install.sh

## Session Duration Setup (for aliases)
Run this:

    wget -O temp_aliases https://raw.github.com/NicolasRitouet/dotfiles/master/.bash_aliases; . ./temp_aliases

## What does it do?
- [Update & upgrade](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L209-215)
- [Create a new user and add it to sudoers](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L231-240)
- [Disable SSH root login](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L243-247)
- [Copy dotfiles](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L250-263): [custom prompt](https://github.com/NicolasRitouet/dotfiles/blob/master/.zork.theme.bash), based on [Zork](https://github.com/revans/bash-it/blob/master/themes/zork/zork.theme.bash), [alias](https://github.com/NicolasRitouet/dotfiles/blob/master/.bash_aliases), [path file](https://github.com/NicolasRitouet/dotfiles/blob/master/.bashpath) and the [.bashrc](https://github.com/NicolasRitouet/dotfiles/blob/master/.bashrc) aggregating all that
- Clone and symlink dotfiles
- Install [extras](https://github.com/NicolasRitouet/dotfiles/blob/master/extra) 
- Install NodeJs/npm, yeoman, java and maven


## Todo
- add .bash_profile in .bashrc
- fix maven install
- Change SSH port
- Fix compass installation (Gem not in the path? $PATH:/var/lib/gems/1.8/bin)
- Fix SSH generation problem (copy the public key in the right place?)
- Rollback if password error while creating a user
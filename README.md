# Bootstrap me!

This repo contains my precious dotfiles and a bash script to bootstrap a debian-based Developer box, a Debian-based server and a MacOSX box.

![Prompt](https://raw.githubusercontent.com/NicolasRitouet/nicolasritouet.github.io/master/images/Screenshot-zork-prompt.png)

## Install on Linux

````wget -O install.tar.gz http://github.com/NicolasRitouet/dotfiles/tarball/master --no-check-certificate && tar zxvf install.tar.gz && cd *dotfiles* && ./install.sh````

## Install on MacOSX

````curl -o install.tar.gz http://github.com/NicolasRitouet/dotfiles/tarball/master && tar zxvf install.tar.gz && cd *dotfiles* && ./install.sh````


## What does it do?
### Debian based server

- [Update & upgrade](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L209-215)
- [Create a new user and add it to sudoers](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L231-240)
- [Disable SSH root login](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L243-247)
- [Copy dotfiles](https://github.com/NicolasRitouet/dotfiles/blob/master/install.sh#L250-263): [custom prompt](https://github.com/NicolasRitouet/dotfiles/blob/master/.bash_prompt), based on [Zork](https://github.com/revans/bash-it/blob/master/themes/zork/zork.theme.bash), [alias](https://github.com/NicolasRitouet/dotfiles/blob/master/.bash_aliases), [path file](https://github.com/NicolasRitouet/dotfiles/blob/master/.bash_path) and the [.bashrc](https://github.com/NicolasRitouet/dotfiles/blob/master/.bashrc) aggregating all that
- Install [extras](https://github.com/NicolasRitouet/dotfiles/blob/master/devTools) 
- Install NodeJs/npm (the non-sudo version) and java7

### MacOXS
- Copy dotfiles
- Install homebrew if doesn't exist
- Install those binaries: 
- Install those apps:




## Todo
- Consider using rsync instead of cp (http://mpov.timmorgan.org/use-rsync-instead-of-cp/)
- Install Xcode command line tools
- clean bash_prompt
- Rollback if password error while creating a user

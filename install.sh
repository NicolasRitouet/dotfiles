#!/usr/bin/env bash
###########################################################################
#
# "Bootstrap me!"
# Fast and Easy OS bootstrap script
# This script help you to install and configure a Debian-based or MacOSX box with:
#	- My own dotfiles (alias, prompt, path, etc...)
#	- Useful binaries
# - Useful apps
# - 
#	- Secure server
# Author: Nicolas Ritouet <nicolas@ritouet.com>
# URL: https://github.com/NicolasRitouet/dotfiles
# Created: Dec 24, 2012
# Version: 0.2.0
#
###########################################################################

# Import some utility functions
source ./utility.sh


# Get a random number to display randomly the headers
randomNumber=$((((RANDOM + RANDOM) % 6) + 1))
echo "";
case $randomNumber in
	1)
		cecho "▄▄▄▄·             ▄▄▄▄▄.▄▄ · ▄▄▄▄▄▄▄▄   ▄▄▄·  ▄▄▄·    • ▌ ▄ ·. ▄▄▄ .▄▄ " $blue
		cecho "▐█ ▀█▪▪     ▪     •██  ▐█ ▀. •██  ▀▄ █·▐█ ▀█ ▐█ ▄█    ·██ ▐███▪▀▄.▀·██▌" $blue
		cecho "▐█▀▀█▄ ▄█▀▄  ▄█▀▄  ▐█.▪▄▀▀▀█▄ ▐█.▪▐▀▀▄ ▄█▀▀█  ██▀·    ▐█ ▌▐▌▐█·▐▀▀▪▄▐█·" $blue
		cecho "██▄▪▐█▐█▌.▐▌▐█▌.▐▌ ▐█▌·▐█▄▪▐█ ▐█▌·▐█•█▌▐█ ▪▐▌▐█▪·•    ██ ██▌▐█▌▐█▄▄▌.▀ " $blue
		cecho "·▀▀▀▀  ▀█▄▀▪ ▀█▄▀▪ ▀▀▀  ▀▀▀▀  ▀▀▀ .▀  ▀ ▀  ▀ .▀       ▀▀  █▪▀▀▀ ▀▀▀  ▀ " $blue
	;;
	2)
		cecho "╔╗ ╔═╗╔═╗╔╦╗╔═╗╔╦╗╦═╗╔═╗╔═╗  ╔╦╗╔═╗┬" $yellow
		cecho "╠╩╗║ ║║ ║ ║ ╚═╗ ║ ╠╦╝╠═╣╠═╝  ║║║║╣ │" $yellow
		cecho "╚═╝╚═╝╚═╝ ╩ ╚═╝ ╩ ╩╚═╩ ╩╩    ╩ ╩╚═╝o" $yellow
		;;
	3)
		cecho "██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗     ███╗   ███╗███████╗██╗" $magenta
		cecho "██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝██║" $magenta
		cecho "██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝    ██╔████╔██║█████╗  ██║" $magenta
		cecho "██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝     ██║╚██╔╝██║██╔══╝  ╚═╝" $magenta
		cecho "██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║         ██║ ╚═╝ ██║███████╗██╗" $magenta
		cecho "╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝╚══════╝╚═╝" $magenta
		cecho "                                                                                                      " $magenta
		;;
	4)
		cecho " ____    ___    ___   ______  _____ ______  ____    ____  ____       ___ ___    ___  __ " $yellow
		cecho "|    \  /   \  /   \ |      |/ ___/|      ||    \  /    ||    \     |   |   |  /  _]|  |" $yellow
		cecho "|  o  )|     ||     ||      (   \_ |      ||  D  )|  o  ||  o  )    | _   _ | /  [_ |  |" $yellow
		cecho "|     ||  O  ||  O  ||_|  |_|\__  ||_|  |_||    / |     ||   _/     |  \_/  ||    _]|__|" $yellow
		cecho "|  O  ||     ||     |  |  |  /  \ |  |  |  |    \ |  _  ||  |       |   |   ||   [_  __ " $yellow
		cecho "|     ||     ||     |  |  |  \    |  |  |  |  .  \|  |  ||  |       |   |   ||     ||  |" $yellow
		cecho "|_____| \___/  \___/   |__|   \___|  |__|  |__|\_||__|__||__|       |___|___||_____||__|" $yellow
		cecho "                                                                                        " $yellow
		;;
	5)
		cecho "______  _____  _____ _____ _____ ___________  ___  ______  ___  ___ _____ _ " $magenta
		cecho "| ___ \|  _  ||  _  |_   _/  ___|_   _| ___ \/ _ \ | ___ \ |  \/  ||  ___| |" $magenta
		cecho "| |_/ /| | | || | | | | | \ \`--.  | | | |_/ / /_\ \| |_/ / | .  . || |__ | |" $magenta
		cecho "| ___ \| | | || | | | | |  \`--. \ | | |    /|  _  ||  __/  | |\/| ||  __|| |" $magenta
		cecho "| |_/ /\ \_/ /\ \_/ / | | /\__/ / | | | |\ \| | | || |     | |  | || |___|_|" $magenta
		cecho "\____/  \___/  \___/  \_/ \____/  \_/ \_| \_\_| |_/\_|     \_|  |_/\____/(_)" $magenta
		cecho "                                                                            " $magenta
		cecho "                                                                            " $magenta
		;;
	6)
		cecho "          )      )         (           (              (        *            ____ " $red
		cecho "   (   ( /(   ( /(   *   ) )\ )  *   ) )\ )    (      )\ )   (  \`          |   / " $red
		cecho " ( )\  )\())  )\())\` )  /((()/(\` )  /((()/(    )\    (()/(   )\))(   (     |  /  " $red
		cecho " )((_)((_)\  ((_)\  ( )(_))/(_))( )(_))/(_))((((_)(   /(_)) ((_)()\  )\    | /   " $red
		cecho "((_)_   ((_)   ((_)(_(_())(_)) (_(_())(_))   )\ _ )\ (_))   (_()((_)((_)   |/    " $red
		cecho " | _ ) / _ \  / _ \|_   _|/ __||_   _|| _ \  (_)_\(_)| _ \  |  \/  || __| (      " $red
		cecho " | _ \| (_) || (_) | | |  \__ \  | |  |   /   / _ \  |  _/  | |\/| || _|  )\     " $red
		cecho " |___/ \___/  \___/  |_|  |___/  |_|  |_|_\  /_/ \_\ |_|    |_|  |_||___|((_)    " $red
		cecho "                                                                                 " $red
		;;
esac

echo ""
cecho "    ..........................................................       "
cecho "    .            Dotfiles 0.2.0 (NicolasRitouet)             .       "
cecho "    .       https://github.com/nicolasritouet/dotfiles       .       "
cecho "    .                                                        .       "
cecho "    .        Bootstrap your Debian-based or MacOSX box       .       "
cecho "    .        Includes:                                       .       "
cecho "    .          - Dotfiles (alias, prompt, path, etc...)      .       "
cecho "    .          - Useful binaries                             .       "
cecho "    .          - Useful apps                                 .       "
cecho "    .          - Secure (!!) a server                        .       "
cecho "    ..........................................................       "
echo ""

# Check if root privileges
if [ "$(whoami)" == "root" ]; then
	e_arrow "Actually, you shouldn't call this script with sudo, because it will break all the permissions on the copied files."
	e_arrow "if sudo is needed, we'll ask you!"
	e_arrow "I let you continue, but don't make any mistake !"
fi

launchMainMenu() {
	if [[ $OSTYPE = darwin* ]]; then
		e_arrow "It looks like you are running this script on a Mac OSX"
		ask "Should I bootstrap this mac? (Y/n): " $yellow
  	read -e BOOTSTRAP_MAC
  	if [ "${BOOTSTRAP_MAC}" != "n" ]; then
				menuMacosx
  	fi
  fi

	ask "What do you want to bootstrap ? ($OSTYPE)"
	PS3="Choose one option: "
	options=("Debian-based Developer Box" "Debian-based Server (and VPS)" "MacOS X")
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	    [d1]) # Developer Box
				e_arrow "Developer Workstation"
				menuDev
				;;
			[v2]) # vps
				e_arrow "VPS bootstrap"
				menuServer
				;;
			[m3]) # macosx
				e_arrow "Mac OS x"
				menuMacosx
				;;
			$(( ${#options[@]}+1 )) )
				echo "If you made some bash changes, don't forget to reload after leaving:"
				echo ". ~/.bashrc";
				exit 0
        break
        ;;
			*)
				echo invalid option
				;;
		esac
	done
}

# sub-menu for a dev workstation
menuDev() {
	ask "Developer Box: please enter your choice:"
	options=("Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf, .bash_prompt, etc...)" #1
		"@(sudo) Install utilities (git-core, vim, mtr, bwm-ng, curl, htop, unrar, unzip, zip, tmux)" #2
		"Install NodeJS and NPM (without sudo) and yeoman" #3
		"@(sudo) Install Java 7" #4
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	    	1) # Copy dotfiles
					copyDotfiles
					;;
				2) # Install utilities
					installUtilities
					;;
				3) # Install NodeJS
					installNodeJsYeoman
					;;
				4) # Install Java
					installJava7
					;;
		    $(( ${#options[@]}+1 )) )
					echo "If you made some bash changes, don't forget to reload after leaving:"
					echo ". ~/.bashrc";
					exit 0
	        break
	        ;;
	    	*) echo invalid option;;
	    esac
	done
}


menuServer() {

	e_arrow "Bootstrap your VPS\n"
  # Ask If Update & upgrade
  ask "Do you wish to update and upgrade? (Y/n): "
  read -e OPTION_UPDATE
  if [ "$OPTION_UPDATE" != "n" ]; then
    # Execute Function
    apt-get update
    apt-get upgrade -y
  fi
    
  # Ask If Root SSH Should Be Disabled
  ask "Do you wish to create a user and disable root SSH logins? (Y/n): "
  read -e OPTION_SSHROOT
  if [ "$OPTION_SSHROOT" != "n" ]; then
    # Create a new user
    add_user
    # Disable root with SSH
    disable_sshroot
    # Change SSH port
    change_ssh_port
  fi

  # Ask If Utilities should be installed
  ask "Do you wish to install Extras (dotfiles, git, curl, htop, vim)? (Y/n): "
  read -e OPTION_EXTRAS
  if [ "$OPTION_EXTRAS" != "n" ]; then
    # Execute Function
    copyDotfiles
    installUtilities
  fi

  # Ask If reboot
  ask "Do you wish to reboot? (Y/n): "
  read -e OPTION_REBOOT
  if [ "$OPTION_REBOOT" != "n" ]; then
    # Execute Function
    reboot
  fi

}



function menuMacosx {

	# copy dotfiles
  ask "Should I copy the dotfiles? (Y/n): "
  read -e COPY_DOTFILES
  if [ "$COPY_DOTFILES" != "n" ]; then
    	copyDotfiles
  fi

	# Install homebrew if it isn't installed already
	ask "Should I install homebrew? (Y/n): "
  read -e INSTALL_BREW
  if [ "${INSTALL_BREW}" != "n" ]; then
		if test ! $(which brew); then
		  e_arrow "Installing homebrew..."
		  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		else
			e_success "Homebrew already installed"
		fi
	fi

	# Run Brew doctor before anything else
  echo ""
	e_arrow "Starting brew doctor to make sure everything's ok"
  brew doctor || true

	# Update homebrew recipes
  echo ""
	e_arrow "Updating brew"
	brew update

	# Install more recent versions of some OS X tools
	brew tap homebrew/dupes
	brew install homebrew/dupes/grep

	# add path of coreutils in $PATH
	echo "export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH" >> ~/.bash_path

  echo ""
	e_arrow "installing binaries..."
	cat "${__DIR__}/brew-binaries.txt" | xargs brew install

  echo ""
  e_arrow "Cleaning up Homebrew intallation..."
  brew cleanup


  echo ""
  e_arrow "Installing Caskroom, Caskroom versions and Caskroom Fonts..."
  brew install caskroom/cask/brew-cask
  brew tap caskroom/versions

  # Make /Applications the default location of apps
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"

	# Install apps to /Applications
	# Default is: /Users/$user/Applications
	e_arrow "installing apps..."
	cat "${__DIR__}/brew-apps.txt" | xargs brew cask install

	
}

copyDotfiles() {
	copyDotfile .bashrc
	copyDotfile .bash_prompt
	copyDotfile .bash_profile
	copyDotfile .bash_path
	copyDotfile .bash_aliases
	copyDotfile .inputrc
	copyDotfile .vimrc
	copyDotfile .tmux.conf
	copyDotfile .gitconfig
}


installNodeJsYeoman() {
	
	installPackage build-essential g++ curl
	
	e_arrow "Installing NodeJs"
	# Install nodeJS
	export PATH=~/local/bin:$PATH
	echo "\n\nexport PATH=~/local/bin:$PATH" >> ~/.bash_path
	mkdir ~/local
	mkdir ~/node-latest-install
	cd ~/node-latest-install
	curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
	./configure --prefix=~/local
	make install
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "NodeJS install" "failed!"
	else
		e_success "NodeJS install" "Success"
	fi
	# Install NPM
	e_arrow "Installing NPM"
	curl https://npmjs.org/install.sh | sh
	npm config set prefix $HOME/.node_modules
	echo "\n\nexport PATH=~/.node_modules/bin:$PATH" >> ~/.bash_path

}

# Install Utilities Defined In File "extra"
installUtilities() {
	e_arrow "Installing utilities"
	sudo apt-get -q -y update || true
	# Loop Through Package List
	while read package; do
		# Install Currently Selected Package
		installPackage "${package}"
	done < linux-binaries.txt
	# Clean Cached Packages
	sudo apt-get clean
}


installJava7() {
	# Install java oracle
	e_arrow "Install Java 7 from webupd8team..."
	# if add-apt-repository > ??, then, add argument -y
	sudo add-apt-repository ppa:webupd8team/java
	# At work, port 11371 is blocked, we have to manually add the key using the port 80
	# sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 EEA14886
	sudo apt-get -q -y update
	sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	sudo apt-get -y install oracle-java7-installer
	echo -e "\n\nJAVA_HOME=/usr/lib/jvm/java-7-oracle" | sudo tee -a /etc/environment > /dev/null
	export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
	echo -e "\nJAVA_HOME=/usr/lib/jvm/java-7-oracle/" >> ~/.bash_path
	# Set the path in a bash.path file ?
	java -version > /dev/null
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Java install" "fail!"
	else
		e_success "Java install" "Success"
	fi
}


# Add User Account
add_user() {
	e_arrow "Add: User Account"
	# Take User Input
	ask "Please enter a user name: "
	read -e USERNAME
	# Add User Based On Input
	useradd -m -s /bin/bash $USERNAME
	# Set Password For Newly Added User
	passwd $USERNAME
	echo $USERNAME ' ALL=(ALL:ALL) ALL' >> /etc/sudoers
	# Copy dotfiles to the new user and chown them
	for dotfile in .bashrc .bash_prompt .bash_profile .bash_path .bash_aliases .inputrc .vimrc .gitconfig
	do
		cp $dotfile /home/$USERNAME/$dotfile
		chown $USERNAME:$USERNAME /home/$USERNAME/$dotfile
	done
}

# Disable Root SSH Login
disable_sshroot() {
	e_arrow "Disabling Root SSH Login"
	e_arrow "BE SURE TO CREATE A NEW USER BEFORE"
	# Disable Root SSH Login For OpenSSH
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Disable SSH Root login" "fail!"
	else
		e_success "Disable SSH Root login" "Success"
		e_arrow "You need to restart sshd or reboot to take the changes"
	fi
	# Disable Root SSH Login For Dropbear
    # sed -i 's/DROPBEAR_EXTRA_ARGS="/DROPBEAR_EXTRA_ARGS="-w/g' /etc/default/dropbear
}

change_ssh_port() {
	e_arrow "Change SSH port"
	sed -i "s/Port 22/Port 2706/g" /etc/ssh/sshd_config

}

# Copy a dotfile to the home directory of the current user
copyDotfile() {
	# http://mpov.timmorgan.org/use-rsync-instead-of-cp/
	e_arrow "Copy $1 into ${HOME}"
	if [ -f ${HOME}/$1 ]; then
		cp ${HOME}/$1 ${HOME}/$1.backup
		e_success "$1 file backup as $1.backup"
	fi
	cp $1 ${HOME}/$1
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Copy of $1" "FAIL"
	else
		e_success "Copy of $1" "Successful!"
	fi
}

# Install package, check if successfull and display fail or success
installPackage() {
	while [ ${#} -gt 0 ]; do
		INSTALLED=$(dpkg -l | grep " $1 ") || true
		if [ "$INSTALLED" != "" ]; then
			e_success "Package $1 already installed!"
		else
			e_arrow "Installing package $1"
			sudo apt-get install --force-yes --yes $1 > /dev/null 2>&1 ;
			if [ $? -gt 0 ]	# What did last command return ?
			then
				e_error "Install of $1" "FAIL"
			else
				e_success "Install of $1" "Successful!"
			fi
		fi
		shift
	done
}

# Launch menu
launchMainMenu

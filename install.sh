#!/bin/bash
#
# Utility script to setup a fresh Linux box
#
# @author Nicolas Ritouet <nicolas@ritouet.com>


# Extra logs methods
function desc_print() { echo -e "      ➜ $1 [0;35m$2[0m $3"; }
function ask() { echo -e -n " [1;32m☆ $1 [0m\n"; }
function happy_print() { echo -e "   [1;32m✔ $1[0;32m $2[0m"; }
function sad_print() { echo -e "   [1;31m✖ $1[0;31m $2[0m"; }

function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }

e_header "Setup your Fresh Linux Box\n"

if [ "$(whoami)" != "root" ]; then
	e_arrow "Calling this script with user '$(whoami)'"
	e_arrow "This script is limited since it wasn't called with sudo."
	e_arrow "To get the full functionnality, please type the following:"
	e_arrow "sudo ./${0##*/}"
	echo -e "\n"
fi


menu() {
	PS3="Please enter your choice:"
	options=("Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf)" #1
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        1) # Copy dotfiles
				copyDotfile .bashrc
				copyDotfile .bash_aliases
				copyDotfile .vimrc
				copyDotfile .tmux.conf
				copyDotfile .gitconfig
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

menuRoot() {
	PS3="Please enter your choice:"
	options=("Update && upgrade your debian" #1
		"Create a new user" #2
		"Disable root login from SSH" #3
		"Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf)" #4
		"Install Git, clone dotfiles and symlink" #5
		"Install Yeoman environment (node.js, ruby, etc...)" #6
		"Install Sublime-text2 and copy Sublime-settings" #7
		"Install extras" #8
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        1) # Update && upgrade debian
				updateAndUpgrade
	            ;;
	        2) # Create a user
	            configure_user
	            ;;
	       3) # Disable root
	            configure_sshroot
	            ;;
	        4) # Copy dotfiles
				copyDotfile .bashrc
				copyDotfile .bash_aliases
				copyDotfile .vimrc
				copyDotfile .tmux.conf
				copyDotfile .gitconfig
				;;
			5) # Clone dotfiles
				cloneDotfiles
				;;
			6) # Install yeoman
				ask "Work in progress"

				;;
			7) # Install Sublime-text2 and copy settings
				installSublimeText
				copySublimeDotFiles
				;;
			8) # Install extras
				install_extra
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


cloneDotfiles() {
	if git --version &> /dev/null ; then
		happy_print "GIT already installed"
	else
		installPackage git-core
	fi
	git clone https://github.com/NicolasRTT/dotfiles.git
	cd /dotfiles
	# add symlink for every dotfile

	symlinkDotfile .bashrc
	symlinkDotfile .bash_aliases
	symlinkDotfile .vimrc
	symlinkDotfile .tmux.conf
	symlinkDotfile .gitconfig
}

updateAndUpgrade() {
	e_arrow "Updating ..."
    	apt-get update > /dev/null
	happy_print "apt-get update" "successful"
	e_arrow "Upgrading ..."
	apt-get upgrade -y > /dev/null
	happy_print "apt-get upgrade" "successful"
}

# Install Extra Packages Defined In File extra
install_extra() {
	e_arrow "Installing extra"
	# Loop Through Package List
	while read package; do
		# Install Currently Selected Package
		installPackage $package
	done < extra
	# Clean Cached Packages
	apt-get clean
}

# Add User Account
configure_user() {
	e_arrow "Configuring: User Account"
	# Take User Input
	ask "Please enter a user name: "
	read -e USERNAME
	# Add User Based On Input
	useradd -m -s /bin/bash $USERNAME
	# Set Password For Newly Added User
	passwd $USERNAME
	echo $USERNAME ' ALL=(ALL:ALL) ALL' >> /etc/sudoers
}

# Disable Root SSH Login
configure_sshroot() {
	e_arrow "Configuring: Disabling Root SSH Login"
	# Disable Root SSH Login For OpenSSH
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
}

# Copy a dotfile to the home directory of the current user
copyDotfile() {
	e_arrow "Copy $1 into ${HOME}"
	if [ -f ${HOME}/$1 ]; then
		cp ${HOME}/$1 ${HOME}/$1.backup
		happy_print "$1 file backup as $1.backup"
	fi
	cp $1 ${HOME}/$1
	if [ $? -gt 0 ]	# What did last command return ?
	then
		sad_print "Copy of $1" "FAIL"
	else
		happy_print "Copy of $1" "Successful!"
	fi
}

# Symlink a dotfile to the home directory of the current user
symlinkDotfile() {
	e_arrow "Linking $1 into ${HOME}"
	ln -s $1 ${HOME}/$1
	if [ $? -gt 0 ]	# What did last command return ?
	then
		sad_print "Symlink of $1" "FAIL"
	else
		happy_print "Symlink of $1" "Successful!"
	fi
}

copySublimeDotFiles() {
	sublime_dir=~/Library/Application\ Support/Sublime\ Text\ 2/Packages
	e_arrow "Copy Sublime settings"
	e_arrow "Work in progress, try again later !"
	#mv "$sublime_dir/User" "$sublime_dir/User.backup"
	#cd "$sublime_dir"
	#echo "Installing Soda Theme..."
	#git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"

	#rm -rf $ZSH/sublime2/User
	#cp -R ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User $ZSH/sublime2/User

}

installSublimeText() {

	installPackage python-software-properties # Needed to call add-apt-repository
	add-apt-repository -y ppa:webupd8team/sublime-text-2
	apt-get update > /dev/null
	installPackage sublime-text
}

# Install package, check if successfull and display fail or success
installPackage() {
	INSTALLED=$(dpkg -l | grep $1)
	if [ "$INSTALLED" != "" ]; then
		happy_print "Package $1 alread installed!"
	else
		e_arrow "Installing package $1"
		apt-get install --force-yes --yes $1 > /dev/null 2>&1 ;
		if [ $? -gt 0 ]	# What did last command return ?
		then
			sad_print "Install of $1" "FAIL"
		else
			happy_print "Install of $1" "Successful!"
		fi
	fi
}

# Launch menu
if [ "$(whoami)" = "root" ]
then
	menuRoot
else
	menu
fi

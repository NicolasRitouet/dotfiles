#!/bin/bash

# Debug off (-x to enable debug)
set +x

script_name="install.sh"
sublime_dir=~/Library/Application\ Support/Sublime\ Text\ 2/Packages
username=$(whoami)

# Must run as root so that we can install packages
if [ $(whoami) != "root" ]; then
	echo -e "\n You need to run this script as root."
	echo -e "\n Use 'sudo ./$script_name' then enter your password when prompted.\n "
	exit 1
fi

main() {

	echo -e "\n Script to install a Dev environment on a fresh Linux box.\n "
	
	# If debian, update and upgrade
	if [ -f /etc/debian_version ]; then
		echo "This script will firstly update your apt-get"

		sudo apt-get update > /dev/null

		# upgrade ?
		ask "Do you wish to upgrade your Debian? (Y/n)?"
		read -e UPGRADE
		if [ "$UPGRADE" != "n" ]; then
			sudo apt-get upgrade -y > /dev/null
		fi
	fi
	
	# Create a user ?
	ask "Do you wish to create a user? (Y/n)?"
	read -e CREATE_USER
	if [ "$CREATE_USER" != "n" ]; then
		configure_user
	fi
	
	# Disable ROOT ?
	ask "Do you wish to disable root? (Y/n)?"
	read -e DISABLE_ROOT
	if [ "$DISABLE_ROOT" != "n" ]; then
		configure_sshroot
	fi

	# Copy .bashrc ?
	ask "Do you wish to copy bashrc? (Y/n)?"
	read -e COPY_BASHRC
	if [ "$COPY_BASHRC" != "n" ]; then
		copyBashrc
	fi
	
	# Copy .bash_aliases ?
	ask "Do you wish to copy bash_aliases? (Y/n)?"
	read -e COPY_BASH_ALIASES
	if [ "$COPY_BASH_ALIASES" != "n" ]; then
		copyBashAliases
	fi


	# Install GIT
	if git --version &> /dev/null ; then
		happy_print "GIT already installed"
	else
		ask "Do you wish to install GIT (Y/n)?"
		read -e INSTALL_GIT
		if [ "$INSTALL_GIT" != "n" ]; then
			installGit
		fi
	fi

	# Copy .gitconfig ?
	ask "Do you wish to copy gitconfig (Y/n)?"
	read -e COPY_GITCONFIG
	if [ "$COPY_GITCONFIG" != "n" ]; then
		copyGitconfig
	fi

	# Install Sublime-text2 ?
	ask "Do you wish to install Sublime-text2 (Y/n)?"
	read -e INSTALL_SUBLIME
	if [ "$INSTALL_SUBLIME" != "n" ]; then
		installSublimeText
	fi

	# Copy sublime-text2 dotfiles ?
	ask "Do you wish to copy Sublime-text2 dotfiles from Github? (Y/n)?"
	read -e COPY_SUBLIME_CONF
	if [ "$COPY_SUBLIME_CONF" != "n" ]; then
		copySublimeDotFiles
	fi

	# Install extra?
	ask "Do you wish to install the extra? (Y/n)?"
	read -e INSTALL_EXTRA
	if [ "$INSTALL_EXTRA" != "n" ]; then
		install_extra
	fi

	# Clean /root ?
	ask "Do you wish to remove all /root files? (Y/n)?"
	read -e REMOVE_HOME
	if [ "$REMOVE_HOME" != "n" ]; then
		rm -rf ~/*
	fi

	# Restart SSHd ?
	ask "Do you wish to restart SSHd? (Y/n)?"
	read -e RESTART_SSHD
	if [ "$RESTART_SSHD" != "n" ]; then
		service ssh restart
	fi

	# reload bash
	exec bash

}

# Install Extra Packages Defined In List
install_extra() {
	desc_print "Installing extra"
	# Loop Through Package List
	while read package; do
		# Install Currently Selected Package
		apt-get -q -y install $package
	done < extra
	# Clean Cached Packages
	apt-get clean
}

# Add User Account
configure_user() {
	desc_print "Configuring: User Account"
	# Take User Input
	ask "Please enter a user name: "
	read -e USERNAME
	username=$USERNAME
	# Add User Based On Input
	useradd -m -s /bin/bash $USERNAME
	# Set Password For Newly Added User
	passwd $USERNAME
	sudo echo $USERNAME ' ALL=(ALL:ALL) ALL' >> /etc/sudoers
}

# Disable Root SSH Login
configure_sshroot() {
	desc_print "Configuring: Disabling Root SSH Login"
	# Disable Root SSH Login For OpenSSH
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
}

installGit() {

	sudo apt-get install --force-yes --yes git-core > /dev/null 2>&1 ;
	quitOnError "Installing git-core now"
}

copyBashAliases() {
		
	desc_print "Copy .bash_aliases"
	cp ${HOME}/.bash_aliases ${HOME}/.bash_aliases.backup
	desc_print ".bash_aliases file backup as .bash_aliases.backup"
	cp .bash_aliases ${HOME}/.bash_aliases
	if [ "$username" != "root" ]; then
		cp .bash_aliases /home/$username/.bash_aliases
	fi
	happy_print "Copy of .bash_aliases" "successful"

}
copyBashrc() {

	desc_print "copy .bashrc"

	cp ${HOME}/.bashrc ${HOME}/.bashrc.backup
	desc_print ".bashrc file backup as .bashrc.backup"
	cp .bashrc ${HOME}/.bashrc
	if [ "$username" != "root" ]; then
		cp .bashrc /home/$username/.bashrc
	fi
	happy_print "Copy of .bashrc" "successful"
}

copyGitconfig() {

	desc_print "copy .gitconfig"
	cp ${HOME}/.gitconfig ${HOME}/.gitconfig.backup
	desc_print ".gitconfig file backup as .gitconfig.backup"
	cp .gitconfig ${HOME}/.gitconfig
	if [ "$username" != "root" ]; then
		cp .gitconfig /home/$username/.gitconfig
	fi
	happy_print "Copy of .gitconfig" "successful"
}



copySublimeDotFiles() {
	desc_print "Work in progress, try again later !"
	#mv "$sublime_dir/User" "$sublime_dir/User.backup"
	#cd "$sublime_dir"
	#echo "Installing Soda Theme..."
	#git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"

	#rm -rf $ZSH/sublime2/User
	#cp -R ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User $ZSH/sublime2/User

}


installSublimeText() {

	desc_print "Install sublime-text2"
	sudo apt-get install --force-yes --yes python-software-properties > /dev/null 2>&1 ;
	quitOnError "Installing python-software-properties now"
	sudo add-apt-repository ppa:webupd8team/sublime-text-2
	sudo apt-get update > /dev/null
	sudo apt-get install --force-yes --yes sublime-text > /dev/null 2>&1 ;
	quitOnError "Installing sublime-text now"
}


#---------------------------------------------
# UTILITY METHODS
#---------------------------------------------
function quitOnError {
	if [ $? -gt 0 ]	
	then
		sad_print "\n\n $@ ..." "FAIL"
		exit 10
	else
		happy_print "$@ ..." "Successful!"
	fi
}

# Print extra descriptions for failure
desc_print() {
    echo -e "      * $1 [0;35m$2[0m $3"
}

ask() {
	echo -e -n " [1;32m☆ $1 [0m"    
}

# Print all in green and the ✔ and $1 in bold
happy_print() {
    echo -e "   [1;32m✔ $1[0;32m $2[0m"
}

# Print all in red and the ✖ and $1 in bold
sad_print() {
    echo -e "   [1;31m✖ $1[0;31m $2[0m"
}

main

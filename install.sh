#!/bin/bash

# Debug off (-x to enable debug)
set +x

script_name="install.sh"
sublime_dir=~/Library/Application\ Support/Sublime\ Text\ 2/Packages
username=$(whoami)

# Must run as root so that we can install packages
if [ $(whoami) != "root" ]; then
	echo "You need to run this script as root."
	echo "Use 'sudo ./$script_name' then enter your password when prompted."
	exit 1
fi

main() {

	echo "Script to install a Dev environment on a fresh Linux box."
	
	# If debian, update and upgrade
	if [ -f /etc/debian_version ]; then
		echo "This script will firstly update your apt-get"
		echo -n "Press any touch to continue ..."
		read -e NOTHING

		sudo apt-get update > /dev/null

		# upgrade ?
		echo -n "Do you wish to upgrade your Debian? (Y/n)?"
		read -e UPGRADE
		if [ "$UPGRADE" != "n" ]; then
			sudo apt-get upgrade -y > /dev/null
		fi
	fi
	
	# Create a user ?
	echo -n "Do you wish to create a user? (Y/n)?"
	read -e CREATE_USER
	if [ "$CREATE_USER" != "n" ]; then
		configure_user
	fi
	
	# Disable ROOT ?
	echo -n "Do you wish to disable root? (Y/n)?"
	read -e DISABLE_ROOT
	if [ "$DISABLE_ROOT" != "n" ]; then
		configure_sshroot
	fi

	# Install GIT
	if git --version &> /dev/null ; then
		echo "GIT already installed"
	else
		echo -n "Git is needed to clone the dotfiles Rep, do you wish to install GIT (Y/n)?"
		read -e INSTALL_GIT
		if [ "$INSTALL_GIT" != "n" ]; then
			installGit
		fi
	fi

	# Copy .bashrc ?
	echo -n "Do you wish to copy bashrc? (Y/n)?"
	read -e COPY_BASHRC
	if [ "$COPY_BASHRC" != "n" ]; then
		copyBashrc
	fi
	
	# Copy .bash_aliases ?
	echo -n "Do you wish to copy bash_aliases? (Y/n)?"
	read -e COPY_BASH_ALIASES
	if [ "$COPY_BASH_ALIASES" != "n" ]; then
		copyBashAliases
	fi

	# Copy .gitconfig ?
	echo -n "Do you wish to copy gitconfig (Y/n)?"
	read -e COPY_GITCONFIG
	if [ "$COPY_GITCONFIG" != "n" ]; then
		copyGitconfig
	fi

	# Install Sublime-text2 ?
	echo -n "Do you wish to install Sublime-text2 (Y/n)?"
	read -e INSTALL_SUBLIME
	if [ "$INSTALL_SUBLIME" != "n" ]; then
		installSublimeText
	fi

	# Copy sublime-text2 dotfiles ?
	echo -n "Do you wish to copy Sublime-text2 dotfiles from Github? (Y/n)?"
	read -e COPY_SUBLIME_CONF
	if [ "$COPY_SUBLIME_CONF" != "n" ]; then
		copySublimeDotFiles
	fi

	# reload bash
	exec bash

}



# Add User Account
configure_user() {
	echo \>\> Configuring: User Account
	# Take User Input
	echo -n "Please enter a user name: "
	read -e USERNAME
	username=$USERNAME
	# Add User Based On Input
	useradd -m -s /bin/bash $USERNAME
	# Set Password For Newly Added User
	passwd $USERNAME
}

# Disable Root SSH Login
configure_sshroot() {
	echo \>\> Configuring: Disabling Root SSH Login
	# Disable Root SSH Login For OpenSSH
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
}

installGit() {

	sudo apt-get install --force-yes --yes git-core > /dev/null 2>&1 ;
	quitOnError "Installing git-core now"
}

copyBashAliases() {

	cp ${HOME}/.bash_aliases ${HOME}/.bash_aliases.backup
	echo ".bash_aliases file backup as .bash_aliases.backup"
	cp .bash_aliases ${HOME}/.bash_aliases
	if [ "$username" != "root"]; then
		cp .bash_aliases /home/$username/.bash_aliases
	fi
	happy_print "Copy of .bash_aliases" "successful"

}
copyBashrc() {

	cp ${HOME}/.bashrc ${HOME}/.bashrc.backup
	echo ".bashrc file backup as .bashrc.backup"
	cp .bashrc ${HOME}/.bashrc
	if [ "$username" != "root"]; then
		cp .bashrc /home/$username/.bashrc
	fi
	happy_print "Copy of .bashrc" "successful"
}

copyGitconfig() {

	cp ${HOME}/.gitconfig ${HOME}/.gitconfig.backup
	echo ".gitconfig file backup as .gitconfig.backup"
	cp .gitconfig ${HOME}/.gitconfig
	if [ "$username" != "root"]; then
		cp .gitconfig /home/$username/.gitconfig
	fi
	happy_print "Copy of .gitconfig" "successful"
}



copySublimeDotFiles() {
	echo "Work in progress, try again later !"
	#mv "$sublime_dir/User" "$sublime_dir/User.backup"
	#cd "$sublime_dir"
	#echo "Installing Soda Theme..."
	#git clone https://github.com/buymeasoda/soda-theme/ "Theme - Soda"

	#rm -rf $ZSH/sublime2/User
	#cp -R ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/User $ZSH/sublime2/User

}


installSublimeText() {

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

# Print all in green and the ✔ and $1 in bold
happy_print() {
    echo -e "   [1;32m✔ $1[0;32m $2[0m"
}

# Print all in red and the ✖ and $1 in bold
sad_print() {
    echo -e "   [1;31m✖ $1[0;31m $2[0m"
}

main

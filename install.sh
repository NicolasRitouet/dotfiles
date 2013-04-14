#!/bin/bash
#
# Utility script to setup a fresh Linux box
#
# @author Nicolas Ritouet <nicolas@ritouet.com>


# Extra logs methods
function ask() { echo -e -n " [1;32m☆ $1 [0m\n"; }

function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }

e_header "Setup your Fresh Linux Box\n"

# Check if root privileges
if [ "$(whoami)" != "root" ]; then
	e_arrow "Calling this script with user '$(whoami)'"
	e_arrow "This script is limited since it wasn't called with root-level privileges."
	e_arrow "To get the full functionnality, please type the following:"
	e_arrow "sudo ./${0##*/}"
	echo -e "\n"
fi

# Menu if root privileges
menuRoot() {
	PS3="Is this a [s]erver or a [d]eveloper workstation ?"
	otpions=("Developer Box", "Server Box")
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        d) # Developer Box
				e_arrow "Developer Workstation"
				menuDev
				;;
			s) # Server box
				e_arrow "Server"
				menuServer
				;;
			*)
				echo invalid option
				;;
		esac
	done
}

# sub-menu for a dev workstation
menuDev() {
	PS3="Developer Box: please enter your choice:"
	options=("Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf, sublime-text)" #1
		"Install Developer tools (git, svn, hg, maven, yeoman, nodejs, java7, etc..." #2
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        1) # Copy dotfiles
				copyDotfile .bashrc
				copyDotfile .zork.theme.bash
				copyDotfile .bash_aliases
				copyDotfile .vimrc
				copyDotfile .tmux.conf
				copyDotfile .gitconfig
				;;
			2) # Install dev tools
				installDevTools
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
	PS3="Server Box: please enter your choice:"
	options=("Update && upgrade your debian" #1
		"Create a new user" #2
		"Disable root login from SSH" #3
		"Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf)" #4
		"Install extras" #5
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
				copyDotfile .zork.theme.bash
				copyDotfile .bash_aliases
				copyDotfile .vimrc
				copyDotfile .tmux.conf
				copyDotfile .gitconfig
				;;
			5) # Install extras
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

menuNotRoot() {
	PS3="Please enter your choice:"
	options=("Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf)" #1
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        1) # Copy dotfiles
				copyDotfile .bashrc
				copyDotfile .zork.theme.bash
				copyDotfile .bash_profile
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

# Copy the dotfiles in $HOME
copyDotfiles() {
	BASHFILES_ROOT="`pwd`/bash"
	echo $BASHFILES_ROOT
 	for source in `find $BASHFILES_ROOT -maxdepth 2 -name \*`
  	do
  		echo $source
  		# symlinkDotfile $source
  	done
}

# clone the repository and symlink the dotfiles in $HOME
cloneDotfiles() {
	if git --version &> /dev/null ; then
		e_success "GIT already installed"
	else
		installPackage git-core
	fi
	git clone https://github.com/NicolasRTT/dotfiles.git ~/.dotfiles
	cd ~/.dotfiles
	# add symlink for every dotfile

	symlinkDotfile .bashrc
	symlinkDotfile .zork.theme.bash
	symlinkDotfile .bash_profile
	symlinkDotfile .bash_aliases
	symlinkDotfile .vimrc
	symlinkDotfile .tmux.conf
	symlinkDotfile .gitconfig
}

# Install dev Packages Defined In File extra
installDevTools() {
	apt-get -q -y update
	e_arrow "Installing Dev tools"
	# Loop Through Package List
	while read package; do
		# Install Currently Selected Package
		installPackage $package
	done < devTools
	# Clean Cached Packages
	apt-get clean
	# Install node.js
	e_arrow "Installing Node.js"
	add-apt-repository ppa:chris-lea/node.js
	apt-get -q -y update
	installPackage nodejs npm

	# Install Ruby
	e_arrow "Install Ruby..."
	\curl -#L https://get.rvm.io | bash -s stable --autolibs=3 --ruby
	e_success "Ruby Installed (or not)..."	

	# Install yeoman
	e_arrow "Install Yeoman..."
	npm install -g yo grunt-cli bower generator-angular generator-karma
	e_success "Yeoman Installed (or not)..."


	# Install java  oracle
	e_arrow "Install Java..."
	add-apt-repository ppa:webupd8team/java
	apt-get -q -y update
	sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	apt-get -y install oracle-java7-installer
	echo -e "\n\nJAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/environment;
	export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
	# Set the path in a bash.path file ?
	java>/dev/null
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Java install" "fail!"
	else
		e_success "Java install" "Success"
	fi

	# Install Maven 3
	e_arrow "Install Maven 3..."
	add-apt-repository ppa:natecarlson/maven3
	apt-get -q -y update
	apt-get -y install maven3
	mvn>/dev/null
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Maven install" "fail!"
	else
		e_success "Maven install" "Success"
	fi
}



updateAndUpgrade() {
	e_arrow "Updating ..."
    	apt-get update > /dev/null
	e_success "apt-get update" "successful"
	e_arrow "Upgrading ..."
	apt-get upgrade -y > /dev/null
	e_success "apt-get upgrade" "successful"
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
}

# Copy a dotfile to the home directory of the current user
copyDotfile() {
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

# Symlink a dotfile to the home directory of the current user
symlinkDotfile() {
	e_arrow "Linking $1 into ${HOME}"
	ln -s $1 ${HOME}/$1
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Symlink of $1" "FAIL"
	else
		e_success "Symlink of $1" "Successful!"
	fi
}

# Install package, check if successfull and display fail or success
installPackage() {
	while [ ${#} -gt 0 ]; do
		INSTALLED=$(dpkg -l | grep "$1 ")
		if [ "$INSTALLED" != "" ]; then
			e_success "Package $1 already installed!"
		else
			e_arrow "Installing package $1"
			apt-get install --force-yes --yes $1 > /dev/null 2>&1 ;
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
if [ "$(whoami)" = "root" ]
then
	menuRoot
else
	menuNotRoot
fi

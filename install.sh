#!/bin/bash
#
# Utility script to setup a fresh Linux box
#
# @author Nicolas Ritouet <nicolas@ritouet.com>


# Extra logs methods
ask() { echo -e -n " [1;32m☆ $1 [0m\n"; }

e_header()   { echo -e "\n\033[1m$@\033[0m"; }
e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }

e_header "Setup your Fresh Linux Box\n"

# Check if root privileges
if [ "$(whoami)" == "root" ]; then
	e_arrow "Actually, you shouldn't call this script with sudo, because it will break all the permissions on the copied files."
	e_arrow "if root is needed, we'll ask you!"
	exit 0
	break
fi

launchMainMenu() {
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
	options=("Copy dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf, .zork.theme.bash, etc...)" #1
		"Clone dotfiles (.bashrc, .bash_aliases, .gitconfig, .vimrc, .tmux.conf, .zork.theme.bash, etc...)" #2
		"@(sudo) Install utilities (git-core, vim, mtr, bwm-ng, curl, htop, unrar, unzip, zip, tmux)" #3
		"Install NodeJS and NPM (without sudo) and yeoman" #4
		"@(sudo) Install Java 7" #5
		"@(sudo) Install Maven (not sure if this works everywhere)" #6
	)
	select opt in "${options[@]}"  "Quit"; do
	    case "$REPLY" in
	        1) # Copy dotfiles
				copyDotfile .bashrc
				copyDotfile .zork.theme.bash
				copyDotfile .bash_profile
				copyDotfile .inputrc
				copyDotfile .bashpath
				copyDotfile .bash_aliases
				copyDotfile .vimrc
				copyDotfile .tmux.conf
				copyDotfile .gitconfig
				;;
	        2) # Clone dotfiles
				cloneDotfiles
				;;
			3) # Install utilities
				installUtilities
				;;
			4) # Install NodeJS
				installNodeJsYeoman
				;;
			5) # Install Java
				installJava
				;;
			6) # Install Maven
				installMaven
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
	options=("@(sudo) Update && upgrade your debian" #1
		"@(sudo) Create a new user" #2
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
			copyDotfile .bash_profile
			copyDotfile .bashpath
			copyDotfile .inputrc
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


# clone the repository and symlink the dotfiles in $HOME
cloneDotfiles() {
	if git --version &> /dev/null ; then
		e_success "GIT already installed"
	else
		installPackage git-core
	fi
	git clone https://github.com/NicolasRitouet/dotfiles.git ~/.dotfiles
	cd ~/.dotfiles
	# add symlink for every dotfile

	symlinkDotfile .bashrc
	symlinkDotfile .zork.theme.bash
	symlinkDotfile .bash_profile
	symlinkDotfile .inputrc
	symlinkDotfile .bashpath
	symlinkDotfile .bash_aliases
	symlinkDotfile .vimrc
	symlinkDotfile .tmux.conf
	symlinkDotfile .gitconfig
}


installNodeJsYeoman() {
	
	installPackage build-essential g++ curl
	
	e_arrow "Installing NodeJs"
	# Install nodeJS
	export PATH=$HOME/local/bin:$PATH
	echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashpath
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
	# Install yeoman
	e_arrow "Installing Yeoman"
	npm install -g yo
	# and the angular generator
	npm install -g generator-angular

	# Install Ruby
	#e_arrow "Install Ruby..."
	#/usr/bin/curl -#L https://get.rvm.io | bash -s stable --autolibs=3 --ruby
	#e_success "Ruby Installed (or not)..."	
}

# Install Utilities Defined In File "extra"
installUtilities() {
	e_arrow "Installing utilities"
	sudo apt-get -q -y update
	# Loop Through Package List
	while read package; do
		# Install Currently Selected Package
		installPackage $package
	done < devTools
	# Clean Cached Packages
	sudo apt-get clean
}


installJava() {


	# Install java  oracle
	e_arrow "Install Java 7 from webupd8team..."
	# if add-apt-repository > ??, then, add argument -y
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get -q -y update
	sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	sudo apt-get -y install oracle-java7-installer
	sudo echo -e "\n\nJAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/environment;
	export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
	echo -e "JAVA_HOME=/usr/lib/jvm/java-7-oracle/" >> ~/.bashpath
	# Set the path in a bash.path file ?
	java -version > /dev/null
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Java install" "fail!"
	else
		e_success "Java install" "Success"
	fi
}

installMaven() {


	e_arrow "Install maven 3.1.1 from binary..."
	wget http://mirror3.layerjet.com/apache/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
	tar xzf apache-maven-3.1.1-bin.tar.gz
	sudo mv apache-maven-3.1.1 /usr/local
	sudo ln -s /usr/local/apache-maven-3.1.1 /usr/local/maven

	e_arrow "Registering Maven Path..."
	export M2_HOME=/usr/local/maven
	export M2=$M2_HOME/bin
	export PATH=$M2:$PATH

	e_arrow "Install path in bashpath ..."
	echo -e "M2_HOME=/usr/local/maven" >> ~/.bashpath
	echo -e "M2=$M2_HOME/bin" >> ~/.bashpath
	echo -e "PATH=$M2:$PATH" >> ~/.bashpath
}


updateAndUpgrade() {
	e_arrow "Updating ..."
    	sudo apt-get update > /dev/null
	e_success "apt-get update" "successful"
	e_arrow "Upgrading ..."
	sudo apt-get upgrade -y > /dev/null
	e_success "apt-get upgrade" "successful"
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
		INSTALLED=$(dpkg -l | grep " $1 ")
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

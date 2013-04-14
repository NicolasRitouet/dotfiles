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


link_files () {
  ln -s $1 $2
  e_success "linked $1 to $2"
}

copyDotBash() {
	BASHFILES_ROOT="`pwd`/bash"
	echo $BASHFILES_ROOT
 	for source in `find $BASHFILES_ROOT -maxdepth 2 -name \*`
  	do
  		echo $source
  		# symlinkDotfile $source
  	done
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
	add-apt-repository ppa:webupd8team/java
	apt-get -q -y update
	sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	apt-get -y install oracle-java7-installer
	echo -e "\n\nJAVA_HOME=/usr/lib/jvm/java-7-oracle" >> /etc/environment;
	export JAVA_HOME=/usr/lib/jvm/java-7-oracle/
	java>/dev/null
	if [ $? -gt 0 ]	# What did last command return ?
	then
		e_error "Java install" "fail!"
	else
		e_success "Java install" "Success"
	fi
}

installYeoman() {
	e_arrow "Install Yeoman"
	# Thx http://ericterpstra.com/2012/10/install-yeoman-and-all-its-dependencies-in-ubuntu-linux/
	installPackage curl

# Install Git
	installPackage git-core

# Install Node.js and NPM
	installPackage python-software-properties # Needed to call add-apt-repository
	add-apt-repository ppa:chris-lea/node.js
	apt-get update > /dev/null
	installPackage nodejs npm

# Install RVM & Ruby
	installPackage build-essential
	curl -L get.rvm.io | bash -s stable
	# Not needed anymore, add the PATH=$PATH:/usr/local/bin in .bashrc
	# echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
	# source "$HOME/.rvm/scripts/rvm"
	# sudo ln -s /usr/local/rvm/bin /usr/local/bin/rvm
	installPackage openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
	rvm install 1.9.3
	rvm use 1.9.3 
	rvm --default use 1.9.3-p194

# Install compass
	gem update --system
	gem install compass

# Install PhantomJS
	wget http://phantomjs.googlecode.com/files/phantomjs-1.7.0-linux-x86_64.tar.bz2
	sudo tar xvf phantomjs-1.7.0-linux-x86_64.tar.bz2 -C /usr/local/share
	sudo ln -s /usr/local/share/phantomjs-1.7.0-linux-x86_64/ /usr/local/share/phantomjs
	sudo ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs
	phantomjs --version
	rm ~/phantomjs-1.7.0-linux-x86_64.tar.bz2
# Install JPEGTRAN / OptiPNG
	installPackage libjpeg-turbo-progs optipng
# Install Yeoman !!! :)
	npm install -g yeoman
	echo -e "Check with: \n curl -L get.yeoman.io | bash"


}

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

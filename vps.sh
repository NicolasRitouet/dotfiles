#!/bin/bash
# VPS bootstrap by Nicolas Ritouet <nicolas@ritouet.com>
# Secure (change SSH port, deactivate root, add sudoer user, install dropbear/remove sshd, install iptables)
# Install utilities (dotfiles, htop, curl, git, vim)
# install applications (nginx, add nginx domain, nodejs, npm, mongodb)

# Credits goes to the LEB community

# Extra logs methods
ask() { echo -e -n " [1;32m☆ $1 [0m\n"; }

e_header() { echo -e "\n\033[1m$@\033[0m"; }
e_success() { echo -e " \033[1;32m✔\033[0m $@"; }
e_error() { echo -e " \033[1;31m✖\033[0m $@"; }
e_arrow() { echo -e " \033[1;33m➜\033[0m $@"; }

e_header "Bootstrap your VPS\n"

function start {

  apt-get update
  apt-get upgrade -y

  # Ask If Update & upgrade
  echo -n "Do you wish to update and upgrade? (Y/n): "
  read -e OPTION_UPDATE
  # Check User Input
  if [ "$OPTION_UPDATE" != "n" ]; then
    # Execute Function
    apt-get update
    apt-get upgrade -y
  fi

  # Ask If Logging Should Be Simplified
  echo -n "Simplify logging configuration? (Y/n): "
  read -e OPTION_LOGGING
  # Check User Input
  if [ "$OPTION_LOGGING" != "n" ]; then
          # Execute Function
          configure_logging
  fi

  # Ask If Time Zone Should Be Set
  echo -n "Do you wish to set the timezone? (Y/n): "
  read -e OPTION_TZ
  # Check User Input
  if [ "$OPTION_TZ" != "n" ]; then
    # Execute Function
    configure_timezone
  fi
    
    
  # Ask If Root SSH Should Be Disabled
  echo -n "Do you wish to create a user and disable root SSH logins? (Y/n): "
  read -e OPTION_SSHROOT
  # Check User Input
  if [ "$OPTION_SSHROOT" != "n" ]; then
    # Create a new user
    add_user
    # Execute Function
    configure_sshroot
  fi

  # Ask If Utilities should be installed
  echo -n "Do you wish to install Extras (dotfiles, git, curl, htop, vim)? (Y/n): "
  read -e OPTION_EXTRAS
  # Check User Input
  if [ "$OPTION_EXTRAS" != "n" ]; then
    # Execute Function
    install_dotfiles
    install_extras
  fi

  # Ask If Install MongoDB
  echo -n "Do you wish to install MongoDB? (Y/n): "
  read -e OPTION_MONGODB
  # Check User Input
  if [ "$OPTION_MONGODB" != "n" ]; then
    # Execute Function
    install_mongodb
  fi

  # Ask If Install nodeJS
  echo -n "Do you wish to install NodeJs? (Y/n): "
  read -e OPTION_NODEJS
  # Check User Input
  if [ "$OPTION_NODEJS" != "n" ]; then
    # Execute Function
    install_nodejs
  fi

}


# Simplify Logging
function configure_logging {
  echo \>\> Configuring: Simplified Logging
  # Stop Logging Daemon
  /etc/init.d/inetutils-syslogd stop
  # Remove Log Files
  rm /var/log/* /var/log/*/*
  rm -rf /var/log/news
  # Create New Log Files
  touch /var/log/{auth,daemon,kernel,mail,messages}
  # Copy Simplified Logging Configuration
  cp settings/syslog /etc/syslog.conf
  # Copy Simplified Log Rotation Configuration
  cp settings/logrotate /etc/logrotate.d/inetutils-syslogd
  # Start Logging Daemon
  /etc/init.d/inetutils-syslogd start
}

# Set Time Zone
function configure_timezone {
  echo \>\> Configuring: Time Zone
  # Configure Time Zone
  dpkg-reconfigure tzdata
}

# Add User Account
function add_user {
        e_arrow "Configuring: User Account"
        # Take User Input
        ask "Please enter a user name: "
        read -e USERNAME
        # Add User Based On Input
        useradd -m -s /bin/bash $USERNAME
        # Set Password For Newly Added User
        passwd $USERNAME
        echo $USERNAME ' ALL=(ALL:ALL) ALL' >> /etc/sudoers
        cp .bashrc /home/$USERNAME/.bashrc
        cp .zork.theme.bash /home/$USERNAME/.zork.theme.bash
        cp .bash_profile /home/$USERNAME/.bash_profile
        cp .inputrc /home/$USERNAME/.inputrc
        cp .bashpath /home/$USERNAME/.bashpath
        cp .bash_aliases /home/$USERNAME/.bash_aliases
        cp .vimrc /home/$USERNAME/.vimrc
        cp .bash_aliases /home/$USERNAME/.bash_aliases
        cp .gitconfig /home/$USERNAME/.gitconfig
}

# Disable Root SSH Login
function configure_sshroot {
  echo \>\> Configuring: Disabling Root SSH Login
  # Disable Root SSH Login For OpenSSH
  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  # Disable Root SSH Login For Dropbear
  # sed -i 's/DROPBEAR_EXTRA_ARGS="/DROPBEAR_EXTRA_ARGS="-w/g' /etc/default/dropbear
}

function install_dotfiles {
  copyDotfile .bashrc
  copyDotfile .zork.theme.bash
  copyDotfile .bash_profile
  copyDotfile .inputrc
  copyDotfile .bashpath
  copyDotfile .bash_aliases
  copyDotfile .vimrc
  copyDotfile .tmux.conf
  copyDotfile .gitconfig
}

function install_extras {
  e_arrow "Installing extras"
  apt-get -q -y update
  # Loop Through Package List
  while read package; do
          # Install Currently Selected Package
          installPackage $package
  done < extra
  # Clean Cached Packages
  apt-get clean
}

function install_mongodb {
  apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
  apt-get -y update
  apt-get -y install mongodb-10gen
  e_arrow "Allowing only localhost"
  echo '\nbind_ip = 127.0.0.1' >> /etc/mongodb.conf
  
  
}

install_nodejs() {
        
  installPackage build-essential g++ curl

  e_arrow "Installing NodeJs"
  # Install nodeJS
  export PATH=~/local/bin:$PATH
  echo '\n\nexport PATH=~/local/bin:$PATH' >> ~/.bashpath
  mkdir ~/local
  mkdir ~/node-latest-install
  cd ~/node-latest-install
  curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
  ./configure --prefix=~/local
  make install
  if [ $? -gt 0 ]        # What did last command return ?
  then
          e_error "NodeJS install" "failed!"
  else
          e_success "NodeJS install" "Success"
  fi
  # Install NPM
  e_arrow "Installing NPM"
  curl https://npmjs.org/install.sh | sh
  # Change the globaly node_modules folder
  npm config set prefix $HOME/.node_modules
  echo '\n\nexport PATH=~/.node_modules/bin:$PATH' >> ~/.bashpath
       
}

# Install package, check if successfull and display fail or success
function installPackage {
  while [ ${#} -gt 0 ]; do
    INSTALLED=$(dpkg -l | grep " $1 ")
    if [ "$INSTALLED" != "" ]; then
      e_success "Package $1 already installed!"
    else
      e_arrow "Installing package $1"
      apt-get install --force-yes --yes $1 > /dev/null 2>&1 ;
      if [ $? -gt 0 ]        # What did last command return ?
      then
        e_error "Install of $1" "FAIL"
      else
        e_success "Install of $1" "Successful!"
      fi
    fi
    shift
  done
}


# Copy a dotfile to the home directory of the current user
function copyDotfile {
        e_arrow "Copy $1 into ${HOME}"
        if [ -f ${HOME}/$1 ]; then
                cp ${HOME}/$1 ${HOME}/$1.backup
                e_success "$1 file backup as $1.backup"
        fi
        cp $1 ${HOME}/$1
        if [ $? -gt 0 ]        # What did last command return ?
        then
                e_error "Copy of $1" "FAIL"
        else
                e_success "Copy of $1" "Successful!"
        fi
}

start

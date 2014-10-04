#####################
# Common alias
#####################

## get rid of command not found ##
alias cd..='cd ..'

## Colorize the ls output ##
alias ls='ls --color=auto'
 
## Use a long listing format ##
alias ll='ls -la'
 
## Show hidden files ##
alias l.='ls -d .* --color=auto'

# Clear the terminal
alias cls='clear'

# Recursively create folders
alias mkdir='mkdir -pv'
# Cd into created folder
mcd() {
  mkdir -p "$1" && cd "$1";
}
alias mcd=mcd

# Compact, colorized git log
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Monitor logs
alias syslog='sudo tail -100f /var/log/syslog'
alias messages='sudo tail -100f /var/log/messages'

alias mount='mount | column -t'

# Set VIM as default
alias vi=vim

# Enable aliases to be sudo’ed
alias sudo='sudo '

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm="rm -I --preserve-root"

# Show me the size (sorted) of only the folders in this directory
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

# Recursive directory listing
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'''

# List paths
alias path="echo -e ${PATH//:/\\n}"

# Search in history
alias h="history | grep "

# Search for text in files
fg() {
    find . -name "${2:-*}" | xargs grep -l "$1"
}
alias fg=fg


# less > more
alias more='less'


# Upload a file
upload() {
    curl --upload-file ./$1 https://transfer.sh/$1;
}
alias upload=upload
alias download="curl -O $1"


if [[ "$OSTYPE" == "linux-gnu" ]]; then

    #######################
    # Alias only for Linux
    #######################

    ## Display info about memory
    alias meminfo='free -m -l -t'

    ## get top process eating memory
    alias psmem='ps auxf | sort -nr -k 4'
    alias psmem10='ps auxf | sort -nr -k 4 | head -10'

    # This is GOLD for finding out what is taking so much space on your drives!
    alias diskspace="du -S | sort -n -r |more"

    # Search inside files
    alias searchFiles=sh\ -c\ \''find . -name \*.* -type f -print0 | xargs -0 grep --color -Hn "$1"'\'\ -

    alias install='sudo apt-get install '

    # Sublime-text 3
    alias sub='/opt/sublime_text/sublime_text '

    # Simple Web server and launch browser if available
    alias webserver='python -m SimpleHTTPServer 8000 | xdg-open http://localhost:8000'


elif [[ "$OSTYPE" == "darwin"* ]]; then

    #######################
    # Alias only for MacOSX
    #######################

    # Lock the screen (when going AFK)
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

    # IP addresses
    alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
    alias ipinfo="curl ipinfo.io"
    alias localip="ipconfig getifaddr en1"
    alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

    # Show/hide hidden files in Finder
    alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

    # Hide/show all desktop icons (useful when presenting)
    alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
    alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

    # Reload the shell (i.e. invoke as a login shell)
    alias reload="exec $SHELL -l"

    # Sublime text
    alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl "

    # Http server
    alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"

    save_brew () {
        brew leaves > ~/brew_leaves.txt
        brew cask list > ~/brew_cask_list.txt
    }
    alias save_brew=save_brew


fi

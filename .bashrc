
############################
#         HISTORY          #
############################
# Expand the history size
HISTFILESIZE=100000000
HISTSIZE=100000

# Set to avoid spamming up the history file
HISTIGNORE="cd:ls:[bf]g:clear:exit"

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# Don't check mail when opening terminal.
unset MAILCHECK

############################
#         PROMPT           #
############################
#GIT
simple_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
 
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}
parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ")"}'
}
parse_svn_url() {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}
export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \w \[\033[31m\]\$(parse_git_branch)\$(parse_svn_branch) \[\033[00m\]$\[\033[00m\] "



# enable my own aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Load RVM, if you are using it
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

############################
#           PATH           #
############################

PATH=$PATH:/usr/local/bin
PATH=$PATH:~/.gem/ruby/1.8/bin

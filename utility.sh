
set -o pipefail
set -o errexit
# set -o xtrace

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

ARG1="${1:-Undefined}"

# set -o nounset

# Use friendly name for colors
black='\033[0;30m'
white='\033[0;37m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'


#  Reset text attributes to normal without clearing screen.
Reset() {
  tput sgr0
}


# Color-echo.
# Argument $1 = message
# Argument $2 = Color
cecho() {
    echo -e "${2}${1}"
    Reset # Reset to normal.
    return
}

# This prints ☆, rest in green bold
ask() {
  cecho "===================================================" $white
  echo -e -n " [1;32m☆ $1 [0m\n";
  cecho "===================================================" $white
  Reset
  return
}

# This prints ✓ in green, rest in bold.
e_success()  {
  echo -e " \033[1;32m✔\033[0m  $@";
  Reset
  return
}

# This prints the ✘ in red, rest in bold.
e_error()    {
  echo -e " \033[1;31m✖\033[0m  $@";
  Reset
  return
}

# This prints the ➜, rest in normal white
e_arrow() {
  echo -e " \033[1;33m➜\033[0m  $@";
  Reset
  return
}
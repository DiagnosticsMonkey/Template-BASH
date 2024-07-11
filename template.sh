#!/bin/bash

# Colour Codes
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
PURPLE='\033[95m'
CYAN='\033[96m'
# Styles
UNDERLINE='\033[4m'
BOLD='\033[1m'
RESET='\033[0m'

# Script Variables
NewLn="\r\n"
Author="Diagnostics"
ScriptName="${0##*/}"
ExUsage="Usage: After cloning an empty repo, run this script from inside the repo.${NewLn}   Example: ../${ScriptName}"

# --------------

# Functions for Error and Warning Handling
print_header() {
   echo -e "${PURPLE}${BOLD}$1${RESET}"
}

print_fatal_error() {
   echo -e "${RED}${BOLD}Fatal Error: $1${RESET}"
   exit 1
}

print_error() {
   echo -e "${RED}${BOLD}Error: $1${RESET}"
}

print_warning() {
   echo -e "${YELLOW}${BOLD}Warning: $1${RESET}"
}

print_success() {
   echo -e "${GREEN}${BOLD}$1${RESET}"
}

print_info() {
   echo -e "${BLUE}$1${RESET}"
}

print_separator() {
   echo -e "${CYAN}------------------------------------${RESET}"
}

# --------------

# We sudoed?
check_sudo() {
   if [ "$EUID" -ne 0 ]; then
      print_fatal_error "Permissions you don't have; sudo you must."
   fi
}

# --------------

main() {
   # Author and Usage
   print_header "Script by: ${Author}${NewLn}   ${ExUsage}"
   #print_usage "${ExUsage}"

   # Do stuff
   if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      print_fatal_error "You have not run this script in a Git repo."
   fi

   # Grab branches
   branches=$(git branch)

   # Check for empty
   if [ -z "${branches}" ]; then
      # No branches found, so make some
      print_info "No branches found. Continuing."
      git checkout -b trunk
      echo "# ReadMe" > README.md
      git add README.md
      git commit -m "Initial commit"
      git push -u origin trunk
      git checkout -b develop
      git push -u origin develop
      git tag -a v0.0.0 -m "Epoch tag"
      git push --tags
      print_info "Branches created, epoch tag set."
   else
      # Bang out
      print_warning "Pre-existing branches found:${NewLn}${branches}"
      print_fatal_error "You should only run this script on an empty repo."
   fi

   print_success "Script reached the end."
}

main "$@"

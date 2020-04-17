#!/bin/bash

# T&M Hansson IT AB © - 2020, https://www.hanssonit.se/

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/20.04_testing/lib.sh)

# Must be root
root_check

# Use another method if the new one doesn't work
if [ -z "$REPO" ]
then
    REPO=$(apt update -q4 && apt-cache policy | grep ubuntu.com | tail -1 | awk '{print $2}')
fi

# Check where the best mirrors are and update
msg_box "To make downloads as fast as possible when updating you should have mirrors that are as close to you as possible.
This VM comes with mirrors based on servers in that where used when the VM was released and packaged.

If you are located outside of Europe, we recomend you to change the mirrors so that downloads are faster."
print_text_in_color "$ICyan" "Checking current mirror..."
print_text_in_color "$ICyan" "Your current server repository is: $REPO"

if [[ "no" == $(ask_yes_or_no "Do you want to try to find a better mirror?") ]]
then
    print_text_in_color "$ICyan" "Keeping $REPO as mirror..."
    sleep 1
else
    if [[ "$KEYBOARD_LAYOUT" =~ ,|/|_ ]]
    then
        msg_box "Your keymap contains more than one language, or a special character. ($KEYBOARD_LAYOUT)\nThis script can only handle one keymap at the time.\nThe default mirror ($REPO) will be kept."
        exit 1
    fi
    print_text_in_color "$ICyan" "Locating the best mirrors..."
    apt update -q4 & spinner_loading
    apt install python-pip -y
    pip install \
        --upgrade pip \
        apt-select
    check_command apt-select -m up-to-date -t 5 -c -C "$KEYBOARD_LAYOUT"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    if [ -f sources.list ]
    then
        sudo mv sources.list /etc/apt/
    fi
fi
clear

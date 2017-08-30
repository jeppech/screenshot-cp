#!/bin/bash

##
# This package requires xclip and gnome-screenshot
#
# $ apt install xclip gnome-screenshot
##

# Name of screenshot file
# e.g. SS20082017T104918.png
name="SS$(date +"%d%m%YT%H%M%S").png"
temp="./$name"
ss_tool=gnome-screenshot

# Enable shadows for screenshot
ss_tool_args="-e shadow"

# Hostname or IP of the server, to upload screenshot to
server_host=""

# Username on server.
server_user=""

# Privat key for authentication
# e.g. ~/.ssh.pub_key
server_key=""

# Path on server, to store the picture
# e.g. ~/www/mysite.com/i
server_path=""

# Url from where, the screenshot is accessible from.
# e.g. https://mysite.com/i
server_url=""

# Take the screenshot and save to $temp folder
$ss_tool $@ $ss_tool_args -f $temp

ss_status=$?

if [[ $? -ne 0 ]]; then
	notify-send "Screenshot failed" "[$?] Check the syslog..." --urgency=normal
	exit $ss_status
fi

# If file does not exist, 
if [ ! -f $temp ]; then
	notify-send "Screenshort aborted" "No file" --urgency=normal
	exit $ss_status
fi

# Upload the file to the server
scp -i$server_key $temp $server_host:"${server_path}/"

if [[ $? -eq 0 ]]; then
	echo -n $server_url/$name | xclip -selection clipboard
	file_size=( $(du -h "$temp") )
	notify-send "Screenshot uploaded" "$server_url/$name (${file_size}b)" --urgency=normal
else 
	notify-send "Screenshot upload failed" "[$?] Check the syslog..." --urgency=normal
fi

rm $temp

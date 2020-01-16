#!/bin/sh

repos="http://alpha.de.repo.voidlinux.org \
http://beta.de.repo.voidlinux.org \
http://alpha.us.repo.voidlinux.org \
http://mirror.clarkson.edu/voidlinux/ \
http://mirrors.servercentral.com/voidlinux/ \
http://mirror.aarnet.edu.au/pub/voidlinux/ \
http://ftp.swin.edu.au/voidlinux/ \
http://ftp.acc.umu.se/mirror/voidlinux.eu/ \
https://mirrors.dotsrc.org/voidlinux/ \
http://www.gtlib.gatech.edu/pub/VoidLinux/ \
https://void.webconverger.org \
https://youngjin.io/voidlinux \
http://ftp.lysator.liu.se/pub/voidlinux/ \
http://lysator7eknrfl47rlyxvgeamrv7ucefgrrlhk7rouv3sna25asetwid.onion/pub/voidlinux/"

min_repo=""

commands_exist() {
	check_cmds=$*

	if command -v type >/dev/null ; then
		type ${check_cmds} >/dev/null
	else
		for cmd in ${check_cmds}; do
			if ! command -v "$cmd" >/dev/null ; then
				return 1
			fi
		done
	fi
}

needed_cmds="awk sed ping tail cut"

if ! commands_exist ${needed_cmds} ; then
	echo "Your system is missing needed packages"
	echo "It needs $needed_cmds"
	exit 1
fi

smaller() {
	new_min=$1
	orig_min=$2
	if [ "$(awk 'BEGIN{ print "'$new_min'"<"'$orig_min'" }')" = 1 ] ; then
		return 0
	fi
	return 1
}

if [ "$1" = "--verbose" ]; then
	verbose="true"
fi

for repo in ${repos}; do
	host=$(echo $repo | sed -e 's|^http://*||g' -e 's:/.*::')
	pingt=$(ping -c 4 -w 2 $host 2>/dev/null | tail -1 | awk '{print $4}' \
	| cut -d '/' -f 2)

	if [ "$pingt" != "" ]; then
		if [ "$min_ping" = "" ] || smaller $pingt $min_ping ; then
			min_ping="$pingt"
			min_repo="$repo"
		fi
	else
		pingt="timed out"
	fi

	if [ "$verbose" = "true" ];then
		echo "$repo: $pingt"
	fi

done
if [ "$min_repo" != "" ]; then
	echo "$min_repo"
else
	echo "Error: couldn't ping any of the mirrors"
	exit 1
fi


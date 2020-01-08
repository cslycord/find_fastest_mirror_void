#!/bin/sh

repos="http://alpha.de.repo.voidlinux.org http://beta.de.repo.voidlinux.org \
http://alpha.us.repo.voidlinux.org \
http://mirror.clarkson.edu/voidlinux/ \
http://mirrors.servercentral.com/voidlinux/ \
http://mirror.aarnet.edu.au/pub/voidlinux/ \
http://ftp.swin.edu.au/voidlinux/ \
http://ftp.acc.umu.se/mirror/voidlinux.eu/ \
https://mirrors.dotsrc.org/voidlinux/ \
http://www.gtlib.gatech.edu/pub/VoidLinux/ \
https://void.webconverger.org \
http://ftp.lysator.liu.se/pub/voidlinux/ \
http://lysator7eknrfl47rlyxvgeamrv7ucefgrrlhk7rouv3sna25asetwid.onion/pub/voidlinux/"

min_repo=""

smaller() {
	new_min=$1
	orig_min=$2
	if [ "$(awk 'BEGIN{ print "'$new_min'"<"'$orig_min'" }')" = 1 ] ; then
		return 0
	fi
	return 1
}

for repo in ${repos}; do
	host=$(echo $repo | sed -e 's|^http://*||g' -e 's:/.*::')
	ping=$(ping -c 4 -w 400 $host 2>/dev/null | tail -1 | awk '{print $4}' \
	| cut -d '/' -f 2)
	if [ "$ping" != "" ] && [ "$ping" != "0" ]; then
		if [ "$min_ping" = "" ] || smaller $ping $min_ping ; then
			min_ping="$ping"
			min_repo="$repo"
		fi
	fi
done
if [ "$min_repo" != "" ]; then
	echo "$min_repo"
else
	echo "Error: couldn't ping any of the mirrors"
	exit 1
fi


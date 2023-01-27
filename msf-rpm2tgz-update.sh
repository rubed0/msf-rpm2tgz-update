#!/usr/bin/env bash

get_answer() {
	while true; do
		read -p "$1" ANSWER
		case $ANSWER in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* )	echo "Please answer yes or no";;
		esac
	done
}

verlte() {
	[ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

CWD=$(pwd)
INSTALLED_VER="$(ls /var/log/packages/metasploit* | cut -d/ -f5 | cut -d- -f3)"
LATEST="$(curl -s rpm.metasploit.com | sed -n 53p | cut -d= -f2 | cut -d\" -f2 | cut -d/ -f4)"
WEB="https://rpm.metasploit.com/metasploit-omnibus/pkg/""$LATEST"
RPM="$(curl -s rpm.metasploit.com | sed -n 53p | cut -d= -f2 | cut -d/ -f4 | cut -d\> -f2 | tr -d "<")"
TGZ="$(echo $RPM | sed 's/rpm/tgz/')"
LATEST_VER="$(curl -s rpm.metasploit.com | sed -n 53p | cut -d= -f2 | cut -d/ -f4 | cut -d\> -f2 | tr -d "<" | tr '~' '_' | cut -d- -f3)"


if [ -z "$INSTALLED_VER" ]; then
	
	echo "Metasploit Framework is not installed!"
	
	if get_answer "Would you like to install it now? [Y/N]: "; then

		echo "Now downloading Metasploit Framework"
		wget -P /tmp/ $WEB
		cd /tmp/
		rpm2tgz $RPM
		installpkg $TGZ
		rm $RPM
		rm $TGZ
		cd $CWD

	else
		echo "Exiting now."
		exit 0
	fi

else
	if verlte $LATEST_VER $INSTALLED_VER; then 
	
		echo "Metsploit Framework is already latest version."
		exit 0

	else
		echo "Newer version $LATEST_VER available!"
		if get_answer "Would you like to upgrade? [Y/N]: "; then
		
			echo "Now downloading newer version:"
			wget -P /tmp/ $WEB
			cd /tmp/
			rpm2tgz $RPM
			upgradepkg $TGZ
			rm $RPM
			rm $TGZ
			cd $CWD

		else
			echo "Not upgrading. Exiting now."
			exit 0
		fi
	fi
fi

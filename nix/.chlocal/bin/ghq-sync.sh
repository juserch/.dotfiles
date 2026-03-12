#!/bin/sh
query=$1

# show ghq list
for repo in `ghq list -p ${query}`; do
	echo ${repo}
done

# prompt yes/no
echo -n "Run force sync of above repositories (y/n)? "
old_stty_cfg=$(stty -g)
stty raw -echo
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
stty $old_stty_cfg
if echo "$answer" | grep -iq "^y" ;then
	echo Yes
	echo Sync repositories ... 
else
	echo No
	echo Command canceled
	exit
fi

# sync repos
for repo in `ghq list -p ${query}`; do
	echo "Sync ${repo}"
	cd ${repo}
	git reset .
	git checkout .
	git clean -f
	git pull -f
done

echo Command done

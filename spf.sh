#!/bin/bash 

domain=$1

if [ ! -n "$domain" ]; then 
	echo "Usage: ./spf.sh www.domain.de"
	exit
fi

# 
if dig -t txt $domain | grep --quiet "v=spf1"; then 
	echo "SPF-Record found."
else 
	echo "NO SPF-Record found for Domain $domain"
	exit
fi

spfrr=$(dig -t txt $domain | egrep -o "v=spf1.*")


# Check if spfrr end with all 
if echo $spfrr | egrep --quiet " [~-?]{1}all$" ; then
	echo "all gefunden"
else 
	echo "KEIN all gefunden. SPF ungültig"
fi	

echo $spfrr

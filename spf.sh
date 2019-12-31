#!/bin/bash 

domain=$1
declare -A ipArray

if [ ! -n "$domain" ]; then 
	echo "Usage: ./spf.sh www.domain.de"
	exit
fi

# 
if dig -t txt $domain | grep --quiet "v=spf1"; then 
	echo -e "\e[32mSPF recound found:\e[0m"
else 
	echo -e "\e[31mNo SPF record found for domain:\e[0m $domain" 
	exit
fi

# 
spfrr=$(dig -t txt $domain | egrep -o "v=spf1.*" | tr -d \")


# Check if spfrr end with all
if ! echo $spfrr | egrep --quiet "[?~-]{1}all$" ; then
	echo "No all mechanisms in SPF record. Please add -all/~all or ?all to this SPF record."
fi	

# [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/{1}[0-9]{1,2}

echo $spfrr

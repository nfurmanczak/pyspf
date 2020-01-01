#!/bin/bash 

domain=$1
declare -A ipArray
#ipArray=("Hans" "Peter")

if [ ! -n "$domain" ]; then 
	echo "Usage: ./spf.sh domain.de"
	exit
fi

if dig -t txt $domain | grep --quiet "v=spf1"; then 
	echo -e "\e[32mSPF recound found:\e[0m"
else 
	echo -e "\e[31mNo SPF record found for domain:\e[0m $domain" 
	exit
fi

spfrr=$(dig -t txt $domain | egrep -o "v=spf1.*" | tr -d \")


# Check if spfrr end with all
if ! echo $spfrr | egrep --quiet "[?~-]{1}all$" ; then
	echo "No all mechanisms in SPF record. Please add -all/~all or ?all to this SPF record."
fi	

# [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/{1}[0-9]{1,2}

echo $spfrr

include=(`echo $spfrr | egrep -o "include:[_\.a-z]*" | sed -e 's/^include://g'`)
ip4=(`echo $spfrr | egrep -o "ip4:[_\.0-9]*" | sed -e 's/^ip4://g'`)
ip6=(`echo $spfrr | egrep -o "ip6:[0-9:a-z]*" | sed -e 's/^ip6://g'`)


echo "INCLUDE:"
echo ${include[*]}

echo "------"

echo "IP4:"
echo ${ip4[*]}
echo "------"

echo "IP6:"
echo ${ip6[*]}
echo "------"
 

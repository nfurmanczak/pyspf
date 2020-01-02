#!/bin/bash 

domain=$1

if [ ! -n "$domain" ]; then 
	echo "Usage: ./spf.sh domain.de"
	exit
fi


spfrr=$(dig -t txt $domain | egrep -o "v=spf1.*" | tr -d \")

# Check for SenderID alias SPF Version 2 
if dig -t txt $domain | grep --quiet "v=spf2"; then 
	echo -e "\e[32mWarning \e[0m"
	echo "It seems that a SenderID DNS (aka spf2) record has been set for this domain. "
	echo "The SenderID is not commonly supported by mailbox providers and not a substitute or replacement for SPF."
fi 

if dig -t txt $domain | grep --quiet "v=spf1"; then 
	echo -e "\e[32mSPF recound found:\e[0m"
else 
	echo -e "\e[31mNo SPF record found for domain:\e[0m $domain" 
	exit
fi



if echo $spfrr | egrep --quiet "[+]{1}all$" ; then
	allcheck="\e[32mSPFWarning: reciever will accept emails from all sources. SPF IS BROKEN! Use only -/~ or ?\e[0m"
elif echo $spfrr | egrep --quiet "[-]{1}all$" ; then
	allcheck="Hardfail (Most reciever will reject emails from sources)"
elif echo $spfrr | egrep --quiet "[?]{1}all$" ; then
	allcheck="Neutral"
elif echo $spfrr | egrep --quiet "[~]{1}all$" ; then
	allcheck="Softfail"
fi 

spfmechanisms=(include ip4_addr ip4_net ip6_addr ip6_net a mx redirect)

include=(`echo $spfrr | egrep -o "include:[-_\.a-z]*" | sed -e 's/^include://g'`)
redirect=(`echo $spfrr | egrep -o "redirect=[-_\.a-z0-9]*" | sed -e 's/^redirect=//g'`)
ip4_addr=(`echo $spfrr | egrep -o "ip4:[_\.0-9]*\s{1}" | sed -e 's/^ip4://g'`)
ip6_addr=(`echo $spfrr | egrep -o "ip6:[0-9:a-fA-F]*\s{1}" | sed -e 's/^ip6://g'`)
ip4_net=(`echo $spfrr | egrep -o "ip4:[_\.0-9]*\/{1}[0-9]{1,2}" | sed -e 's/^ip4://g'`)
ip6_net=(`echo $spfrr | egrep -o "ip6:[0-9:a-fA-F]*\/[0-9]{1,3}" | sed -e 's/^ip6://g'`)
a=(`echo $spfrr | egrep -o "\+?a:[a-zA-Zöäü\.-]+" | sed -e 's/^a://g'`)
mx=(`echo $spfrr | egrep -o "\+?mx:[a-zA-Zöäü\.-]+" | sed -e 's/^a://g'`)


echo $spfrr

# Check if spfrr end with all
if ! echo $spfrr | egrep --quiet "[?~-]{1}all$" ; then
	echo "No all mechanisms in SPF record. Please add -all/~all or ?all to this SPF record."
fi	


echo ""
echo "Additional information: "
echo "------------------------"
echo -e "SPF policy: $allcheck"

for i in "${spfmechanisms[@]}"
do
	eval 'array_count=${#'"$i"'[@]}'
	if [[ $array_count -gt "0" ]] ; then 
		var=$i[@]
		echo "$i: ${!var}"
	fi
done

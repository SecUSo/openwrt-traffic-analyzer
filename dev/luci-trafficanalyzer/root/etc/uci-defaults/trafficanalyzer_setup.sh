#! /bin/sh
#Changes privoxy- and firewall-settings for trafficanalyzer
# Copyright 2015 Daniel Franke
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License a	http://www.apache.org/licenses/LICENSE-2.0
#
privoxy_port=8118
privoxy_content_added_file="/etc/privoxy/added_by_trafficanalyzer"

#will be changed if file /etc/config/privoxy exists
privoxy_config_file="/etc/privoxy/config"
privoxy_config_file_new_fomat="/etc/config/privoxy"
##true if new privoxy configuration file is used (chaos calmer and above)
new_privoxy_conffile=$false
#stores old hostname in this file
saved_hostname_file=/etc/uci-defaults/oldhostname
#stores ip of the interface of which the name was given as first argumnt to this script
saved_ip_file=/etc/uci-defaults/trafficanalyzer_if_ip

#if privoxy config file with new format is detected
if [ -e $privoxy_config_file_new_fomat ]; then
	echo "Recognized new privoxy config file (used in chaos calmer and above). This feature is still in beta!"
	privoxy_config_file=$privoxy_config_file_new_fomat
	new_privoxy_conffile=$true
fi;


#replaces string which is given as second argument and is placed at the beginning of a line
# with string which is given as third argument in file whose name/path is given as first argument.
replace_at_beginning() {
	file=$1
	beginstring=$2
	replacestring=$3
	sed  -i.bak "s|^$beginstring |$replacestring |" $file
    
}

#comment out line which begins with second argument in file whose nae is given as first argument
comment_out(){
	file=$1
	commentout=$2
	replace="\#"$commentout
	replace_at_beginning $file $commentout $replace

}

#removes # from beginning of a line which begins with # followed by second argument in file whose name is given as first argument
remove_comment_out() {
	file=$1
	commentout="\#"$2
	replace=$2
	replace_at_beginning $file $commentout $replace
}

do_modify_privoxy_file(){
	echo "begin to modify privoxy config..."
	nwip=$1
	subnet=$2
	commentoutstrings=$3
	for commentout in $commentoutstrings; do
	 comment_out $privoxy_config_file $commentout
	done
	echo "filterfile trafficanalyzer.filter" >> $privoxy_content_added_file
	echo "actionsfile trafficanalyzer.action" >> $privoxy_content_added_file

	#Because new config file format does user underscore instead of -, you have decide between the formats here
	if [ $new_privoxy_conffile ]; then
		echo "listen_address $nwip:$privoxy_port" >> $privoxy_content_added_file
		echo "enable_remote_http_toggle  0" >> $privoxy_content_added_file
		echo "enable_edit_actions 0" >> $privoxy_content_added_file
		echo "accept_intercepted_requests 1" >> $privoxy_content_added_file
		echo "permit_access  $subnet" >> $privoxy_content_added_file
	else
		echo "listen-address $nwip:$privoxy_port" >> $privoxy_content_added_file
		echo "enable-remote-http-toggle  0" >> $privoxy_content_added_file
		echo "enable-edit-actions 0" >> $privoxy_content_added_file
		echo "accept-intercepted-requests 1" >> $privoxy_content_added_file
		echo "permit-access  $subnet" >> $privoxy_content_added_file
	fi;
	#copy new lines from $privoxy_content_added_file file to privoxy config file
	cat $privoxy_content_added_file >> $privoxy_config_file
	echo "modifications in privoxy configfile are done..."
}

undo_modify_privoxy_file(){
	echo "begin to restore privoxy configfile..."
	commentoutstrings=$1
	#remove lines which are stored in $privoxy_content_added_file from $privoxy_config_file 
	awk 'NR==FNR{a[$0];next} !($0 in a)' $privoxy_content_added_file $privoxy_config_file >>/tmp/config
	cp /tmp/config $privoxy_config_file
	rm /tmp/config
	rm $privoxy_content_added_file
	#now remove commets added by install script
	for commentout in $commentoutstrings; do
	 remove_comment_out $privoxy_config_file $commentout
	done
	echo "privoxy config file was restored if no failures appeared..."
}

#modifies privoxy file. If first argument is do do_modify_privoy_file is called. Else undo_modify_privoxy_file
#second parameter has to be the network name if first parameter is do
modify_privoxy_file(){
	do_undo=$1	
	nwname=$2
	nwip=$3
	subnet=$(echo $nwip | sed 's|\([0-9]*\.[0-9]*\.[0-9]*\)\.[0-9]*|\1.0\/24|')
	
	#defines strings which have to be at the beginning of a line which has to be commented out
	commentoutstrings="filterfile actionsfile"
	#Because new config file format does user underscore instead of -, you have decide between the formats here
	if [ $new_privoxy_conffile ]; then
		commentoutstrings=$(echo "$commentoutstrings listen_address enable_remote-http_toggle enable_edit_actions accept_intercepted_requests permit_access")
	else
		commentoutstrings=$(echo "$commentoutstrings listen-address enable-remote-http-toggle enable-edit-actions accept-intercepted-requests permit-access")
	fi;
	if [ $do_undo = "do" ]; then	
		do_modify_privoxy_file $nwip $subnet "$commentoutstrings";
	else
		undo_modify_privoxy_file "$commentoutstrings";
	fi;
}

#add firewall rules needed for privoxy
add_firewall_rules() {
	echo "begin to add firewall rules.."
	nwname=$1
	nwip=$2
	zoneid=$(uci show firewall |grep network=$nwname | sed 's|\.network='$nwname'|   |')
	zonename=$(uci show $zoneid| grep name | sed -r 's|.*\.name=(.*)|\1|')
    uci add firewall redirect
	uci set firewall.@redirect[-1].name='privoxy_transparent_http_proxy_autogen'
	uci set firewall.@redirect[-1].proto='tcp'
	uci set firewall.@redirect[-1].target='DNAT'
	uci set firewall.@redirect[-1].dest=$zonename
	uci set firewall.@redirect[-1].src=$zonename
	uci set firewall.@redirect[-1].src_dport='80'
	uci set firewall.@redirect[-1].dest_ip=$nwip
	#Uncomment next line, if you want, that http traffic to the router will not be redirected to privoxy	
	#uci set firewall.@redirect[-1].src_dip='!'$nwip
	uci set firewall.@redirect[-1].dest_port=$privoxy_port
	uci commit firewall
	uci commit network
	echo "firewall rules added..."
}

#deletes firewall rules which were created
remove_firewall_rules(){
	echo "begin to remove firewall rules..."
#names of all rules which will be deletes (e.g. "rule1 rule2")
	rulenames="privoxy_transparent_http_proxy_autogen'"
	for rulename in $rulenames; do
		rules=$(uci show firewall |grep $rulename |sed -r 's|\.name='$rulename'| |')
		for i in $rules; do
		        #deleting redirects may change the inices, so we have to search again
		        rulesl=$(uci show firewall |grep $rulename |sed -r 's|\.name='$rulename'| |')
		        rule=$(echo $rulesl|awk '{print $1}')
		        uci delete $rule
		done
	done
	uci commit firewall
	echo "firewall rules removed"
}

#changes Hostname
change_hostname(){
if [ $# -ne 0 ]; then
new_hostname=$1
else
echo "hostname cannot be found. So take router as hostname"
new_hostname="router"
fi;
echo "change hostname to $new_hostname"
uci  set system.@system[0].hostname=$new_hostname
uci commit system
}


#renames Hostname to router
rename_hostname(){
echo "save old hostname to $saved_hostname_file"
uci get system.@system[0].hostname > $saved_hostname_file
change_hostname router
}

#restores hostname from file stored 
restore_hostname(){
old_hostname=$(cat $saved_hostname_file)
change_hostname $old_hostname
rm $saved_hostname_file
}

#changes ip of the router in privoxy filter rules. The old ip has to be the first argument and the new ip the second argument
change_router_ip_in_trafficrules(){
from=$1
to=$2
echo "Set IP of the router in privoxy filters to $to (before it was $from)"
sed  -i "s|$from|$to|" /etc/config/trafficanalyzer
sed  -i "s|$from|$to|" /etc/privoxy/trafficanalyzer.filter
}

#changes ip of the router in privoxy filter rules to ip of the interface given to the script. Default ip 10.0.0.1 is replaced
renew_router_ip_in_trafficrules(){
	nwname=$1
	nwip=$2
	echo "$nwip" > $saved_ip_file 
	
	change_router_ip_in_trafficrules 10.0.0.1 $nwip
	
}

#changes ip of the router in privoxy filter rules to default ip
restore_router_ip_in_trafficrules(){
	defaultip="10.0.0.1"
	interfaceip=$(cat $saved_ip_file)
	change_router_ip_in_trafficrules $interfaceip $defaultip
	rm $saved_ip_file
}


case "$1" in
    install)
	if [ -z "$2" ]; then echo "If install is first parameter, interface-name has to be the second parameter"; else
		if [ -e $privoxy_content_added_file ]; then
			echo "Please undo setup before click setup again (file $privoxy_content_added_file still exists)";
		else
			nwname=$2
			nwip=$(uci get network.$nwname.ipaddr)
			rename_hostname
			add_firewall_rules  $nwname $nwip
			modify_privoxy_file do $nwname $nwip
			renew_router_ip_in_trafficrules $nwname $nwip
			/etc/init.d/privoxy restart			
		fi;
	fi
        ;;
    uninstall)
	if [ -e $privoxy_content_added_file ]; then
			remove_firewall_rules
			modify_privoxy_file undo
			restore_router_ip_in_trafficrules
			/etc/init.d/privoxy restart
			restore_hostname
	else echo "$privoxy_content_added_file does not exist. So please setup our privoxy config before removing it (Run setup script)";
	fi;
        ;;
    *)
        echo "Usage: $SCRIPTNAME {install interface-name | uninstall}" >&2
        exit 3
        ;;
esac


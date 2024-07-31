#!/bin/bash

#Cesar Badilla Monday, November 16, 2020 10:41:17 PM 

echo "######################################################"
echo;echo "These are the current Certificate Stores:";echo
		
		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list); do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After"; done; 
echo;echo "If there is any expired or expiring Certificates within the BACKUP_STORES please continue to run this script";echo "######################################################";echo 

	read -p "Have you taken powered off snapshots of all PSC's and VCSA's within the SSO domain(Y|y|N|n)" -n 1 -r

	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then 
	exit 1
	fi
echo

		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli entry list --store BACKUP_STORE |grep -i "alias" | cut -d ":" -f2);do echo BACKUP_STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store BACKUP_STORE --alias $i -y; done 
		
	for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list); do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After"; done | grep -i 'BACKUP_STORE_H5C'&> /dev/null

	if [ $? == 0 ]; then 
		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli entry list --store BACKUP_STORE_H5C |grep -i "alias" | cut -d ":" -f2); do echo BACKUP_STORE_H5C $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry delete --store BACKUP_STORE_H5C --alias $i -y; done
	
echo 
echo "--------------------------------------------------------";
fi

echo "######################################################";
echo;echo "The resulting BACKUP_STORES after the cleanups are: ";echo

		for i in $(/usr/lib/vmware-vmafd/bin/vecs-cli store list); do echo STORE $i; /usr/lib/vmware-vmafd/bin/vecs-cli entry list --store $i --text | egrep "Alias|Not After"; done

echo "######################################################";echo "--------------------------------------------------------"; echo "--------------------------------------------------------";
echo "Results: ";
echo "--------------------------------------------------------"; echo "--------------------------------------------------------";
echo;echo "The Certificate BACKUP_STORES were successfully cleaned";echo;
echo "Please acknowlege and reset to green any certificate related alarm."
echo "Restart services on all PSC's and VCSA's in the SSO Domain with command.";echo;echo "service-control --stop --all && service-control --start --all(optional)."
echo "--------------------------------------------------------";
echo;echo "If you could not restart the services, please monitor
the VCSA for 24 hours and the alarm should not reappear 
after the acknowlegement."
echo;echo "######################################################"




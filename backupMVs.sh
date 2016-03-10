#!/bin/bash

bk_date=`date "+%Y-%m-%d"`
mkdir "backups_"$bk_date
for vm_name in `virsh list --all | tail -n +3 | head -n -1 | awk '{print $2}'`;
do
	echo "Realizando copia de las MVs" 
	echo -------Copia de seguridad de $vm_name --------
	virsh snapshot-create-as $vm_name "$vm_name"_"$bk_date" > /dev/null 2> /dev/null
	if [ $? -eq 0 ]
	then
		echo -------Creacion de $vm_name Exitosa ---------------
		cp /var/lib/libvirt/qemu/snapshot/"$vm_name"/"$vm_name"_"$bk_date".xml ./"backups_"$bk_date/"$vm_name"_"$bk_date".xml
		cp /var/lib/libvirt/images/"$vm_name".qcow2 ./"backups_"$bk_date/"$vm_name"_"$bk_date".qcow2
		echo -------Copia de $vm_name Exitosa ---------------
		echo -------Realizando restauración del snapshot "$vm_name"_"$bk_date"
		cp ./"backups_"$bk_date/"$vm_name"_"$bk_date".qcow2 /var/lib/libvirt/images/"$vm_name".qcow2
		virsh snapshot-revert $vm_name "$vm_name"_"$bk_date" > /dev/null 2> /dev/null
		if [ $? -eq 0 ]
		then
			echo -------restauración "$vm_name"_"$bk_date" Exitosa -------
		else
			echo -------restauración "$vm_name"_"$bk_date" Fallida -------
		fi
	else
		echo -------Fallo al realizar copia de $vm_name ------
	fi
done

#!/bin/bash

 

DEVICE=`df | grep 62afea1a-64be-43a4-b128-8592aa0df995  | awk '{print $1}' `
ENDPOINT=/mnt/lexar

if [ -n $DEVICE ]; then

	if ! [ -d $ENDPOINT ]; then

		mkdir /mnt/lexar
	fi
		

	mount $DEVICE /mnt/lexar
fi

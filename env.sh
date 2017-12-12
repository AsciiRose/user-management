#!/bin/bash

function setEnv() {
#Variablen für den Pfad
	if [ $DEBUG = "666" ]; then 
		echo "We are in the debug scenario. Look for you stuff in /tmp"
		defaultPath="/tmp/"
	else
		defaultPath="/etc/"
	fi

	groupFileName="group"
	userFileName="passwd"

	groupPath=$defaultPath$groupFileName
	userPath=$defaultPath$userFileName

    if [ $DEBUG = "666" ]; then 
        touch $groupPath
        touch $userPath
    fi 

	export groupPath
	export userPath
}
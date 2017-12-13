#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll

function setEnv() {
	#Variablen für den Pfad
	if [ $DEBUG = "666" ] 
	then 
		echo "We are in the debug scenario. Look for you stuff in /tmp"
		defaultPath="/tmp/"
		homePath="/tmp/home/"
	else
		defaultPath="/etc/"
		homePath="/home/"
	fi
	
	groupFileName="group"
	userFileName="passwd"

	groupPath=$defaultPath$groupFileName
	userPath=$defaultPath$userFileName

    if [ $DEBUG = "666" ] 
	then 
        touch $groupPath
        touch $userPath
    fi 

	export groupPath
	export userPath
	export homePath
	export groupFileName
	export userFileName
}
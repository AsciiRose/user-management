#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll

function searchUser()
{
    #Prüfen ob Nutzer schon besteht
	if [ $(cat $userPath | cut -f1 -d: | grep '\<$1\>' | wc -w) -gt 0 ]
	then
        #Fehlermeldung ausgeben das der Nutzer bereits existiert
		echo "Nutzer besteht bereits"
		#Abbrechen
		return 1
	else
        #Meldung ausgeben das der Nutzer noch nicht existiert
		echo "Nutzer besteht noch nicht"
		return 0
	fi
}

function checkAndAddGroup()
{		
    #Prüft ob Gruppe bereits besteht
	if [ $(cat $groupPath | cut -f1 -d: | grep '\<$1\>' | wc -w) -gt 0 ]
	then
        #Meldung, dass Gruppe bereits besteht
		echo "Gruppe besteht bereits"
		
		#Gruppenummer abspeichern
		groupNumber=$(cat $groupPath | grep '\<$1\>' | cut -f3 -d:)
		
		#Gruppennummer exportieren
		export $groupNumber
	else
        #Meldung, dass Gruppe angelegt wird
		echo "Gruppe $1 wird angelegt"

		#Gruppe wird angelegt
        echo "$1:x:$2:" >> $groupPath
	fi
}

function getNewID()
{
	if [ -z $1 ] 
	then
		echo "Kein Parameter übergeben"
		return 1
	fi 

    #Kleinste belegte 4 stellige ID suchen
	ID=$(cat $1 | cut -f4 -d: | grep -e '^.\{4\}$' | sort -n | head -1)
	
	echo "Die ID ist $ID"
	
	if [ -z $ID ] 
	then 
		ID=1000;
		export ID;
		return 0;	
	fi
	
    #Schleife bis ID frei ist
	while [ $(cat $1 | cut -f4 -d:) -ne $ID ]
	do
        #ID erhöhen
		let ID=$ID+1

        #Abfangen der größten ID anhand der Suchkriterien -> Merke: generelle Max ID = 65536
		if [ $ID -eq 10000 ]
		then
            #Fehlermeldung wenn Max ID erreicht ist
			echo "Maximale ID erreicht!"
			#Abbrechen
			return 1
		else
            #ID exportieren
			export ID
		fi
	done
}
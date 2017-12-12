#!/bin/bash

#use the env.sh file next to this one
source env.sh

function searchUser()
{
    #Prüfen ob Nutzer schon besteht
	if [ $(cat $userPath | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]
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
	if [ $(cat $groupPath | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]
	then
        #Meldung, dass Gruppe bereits besteht
		echo "Gruppe besteht bereits"
		
		#Gruppenummer abspeichern
		groupNumber=$(cat $groupPath | grep $1 | cut -f3 -d:)
		
		#Gruppennummer exportieren
		#Gruppenname exportieren
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

	if [ -z $1 ]; then
		echo "getNewID: No parameter given"
		return 1
	fi 

    #Kleinste belegte 4 stellige ID suchen
	ID=$(cat $1 | cut -f4 -d: | grep -e '^.\{4\}$' | sort -n | head -1)
	echo "ID is $ID"
	if [ -z $ID ]; then 
		ID=1000;
		export ID;
		return 0;	
	fi
    #Schleife bis ID frei ist
	while [ $(cat $1 | cut -f4 -d:) -ne ${ID} ]
	do
        #ID erhöhen
		let ID=$ID+1

        #Abfangen der größten ID anhand der Suchkriterien -> Merke: generelle Max ID = 65536
		if [ $ID -eq 10000 ]
		then
            #Fehlermeldung wenn Max ID erreicht ist
			echo "Maximale $1 ID erreicht!"
			#Abbrechen
			return 1
		else
            #ID exportieren
			export ID
		fi
	done
}

#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 4 ]
then
    #Fehlermeldung wenn zu wenige Parameter angegeben sind
	echo "Zu wenige Parameter angegeben. Es müssen Gruppenname, Nutzername, Kommentar und Passwort angegeben werden"
	#Abbrechen
	return 1
else
	
	setEnv

	#Variablen für die Übergabewerte
	inputGroupName=$1
	inputUserName=$2
	inputComment=$3
	inputPassword=$4

    #Prüfen ob Nutzer schon besteht
	searchUser $inputUserName
	
    #Brüft ob es einen Fehler gab
	if [ ! $? -eq 0 ]
	then
        #Abbrechen
		exit 2
	else
        #Sucht eine neue freie User ID
		getNewID $userPath
        #Brüft ob es einen Fehler gab
		if [ ! $? -eq 0 ]
	    then
			echo "Error"
            #Abbrechen
			exit 3
		else
			#Speichert ID in einer Variable
			userID=$ID
			
            #Sucht eine neue freie Group ID
			getNewID $groupPath

            #Brüft ob es einen Fehler gab
			if [ ! $? -eq 0 ]
			then
                #Abbrechen
				exit 4
			else
				#Speichert ID in einer Variable
				groupID=$ID
				
                #Prüft ob Gruppe bereits existiert
                #Legt ggf. eine neue Gruppe an
                checkAndAddGroup $inputGroupName $groupID

                #Nutzer in passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell
				echo "$inputUserName:x:$userID:$groupID:$2:/home/$inputUserName:/bin/bash" >> $userPath

                #Homeverzeichnis anlegen
				mkdir /home/$inputUserName

                #Nutzer die Besitzrechte auf das Verzeichnis übertragen -> chown Benutzer:Gruppe Datei
				chown $inputUserName:$inputGroupName /home/$inputUserName
				#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
				chmod 700 /home/$inputUserName

                #Passwort für Nutzer anlegen
				echo -e "$4\n$4" | ($userPath $inputUserName)
			fi
		fi
	fi
fi





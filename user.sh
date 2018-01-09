#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll

#Benutzt andere Dateien in diesem Skript
source env.sh
source function.sh

if [ $# -lt 4 ]
then
    #Fehlermeldung wenn zu wenige Parameter angegeben sind
	echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Gruppenname, Kommentar und Passwort angegeben werden"
	#Abbrechen
	return 1
else
	#Setzt Pfade über eine andere Datei
	setEnv

	#Variablen für die Übergabewerte
	inputUserName=$1
	inputGroupName=$2
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
		getNewID $userFileName
		
        #Brüft ob es einen Fehler gab
		if [ ! $? -eq 0 ]
	    then
			echo "getNewID Error"
			
            #Abbrechen
			exit 3
		else
			#Speichert ID in einer Variable
			userID=$ID
			
            #Sucht eine neue freie Group ID
			getNewID $groupFileName

            #Brüft ob es einen Fehler gab
			if [ ! $? -eq 0 ]
			then
				echo "getNewID Error"
			
                #Abbrechen
				exit 4
			else
				#Speichert ID in einer Variable
				groupID=$ID
				
                #Prüft ob Gruppe bereits existiert
                #Legt ggf. eine neue Gruppe an
                checkAndAddGroup $inputGroupName $groupID
				
				if [ ! -z $groupNumber ] 
				then
					groupID=$groupNumber
				fi

                #Nutzer in passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell
				echo "$inputUserName:x:$userID:$groupID:$3:$homePath$inputUserName:/bin/bash" >> $userPath

                #Homeverzeichnis anlegen
				mkdir -p $homePath$inputUserName

                #Nutzer die Besitzrechte auf das Verzeichnis übertragen -> chown Benutzer:Gruppe Datei
				chown $inputUserName:$inputGroupName $homePath$inputUserName
				#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
				chmod 700 $homePath$inputUserName

                #Passwort für Nutzer anlegen
				echo -e "$4\n$4" | ($userFileName $inputUserName)
			fi
		fi
	fi
fi





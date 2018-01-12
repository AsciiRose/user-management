#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll

#Benutzt andere Dateien in diesem Skript
source env.sh
source function.sh

if [ $# -lt 1 ]
then
    #Fehlermeldung wenn zu wenige Parameter angegeben sind
	echo "Keine Parameter übergeben. Übergeben Sie einen oder mehrere Benutzernamen ein."
	#Abbrechen
	return 1
else
	for [ username in $* ]
	do
		if [ -z $groupname ]
		then
			groupname=$username
		fi
	
		#Setzt Pfade über eine andere Datei
		setEnv $username

		#Prüfen ob Nutzer schon besteht
		searchUser $username
		
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
					checkAndAddGroup $groupName $groupID
					
					if [ ! -z $groupNumber ] 
					then
						groupID=$groupNumber
					fi
					
					if [ -z $loginshell ]
					then
						loginshell="/bin/bash"
					fi

					#Nutzer in passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell
					echo "$username:x:$userID:$groupID:$3:$homePath$username:$loginshell" >> $userPath

					#Homeverzeichnis anlegen
					mkdir -p $homePath$username

					#Nutzer die Besitzrechte auf das Verzeichnis übertragen -> chown Benutzer:Gruppe Datei
					chown $username:$groupName $homePath$username
					#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
					chmod 700 $homePath$username
					
					getRandomPassword

					#Passwort für Nutzer anlegen
					echo -e $password | ($userFileName $username)
					
					echo "Ihr Passwort zu dem Benutzer $username lautet zur Zeit: $password"
					
					echo "$username, $password" >> user.csv
				fi
			fi
		fi
	done
fi





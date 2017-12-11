#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
then
    #Fehlermeldung wenn zu wenige Parameter angegeben sind
	echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Kommentar und Passwort angegeben werden"
	#Abbrechen
	exit 1
else
    #Prüfen ob Nutzer schon besteht
	searchUser $1

    #Brüft ob es einen Fehler gab
	if [ ! $? -eq 0 ]
	then
        #Abbrechen
		exit 2
	else
        #Sucht eine neue freie User ID
		getNewID passwd
		#Speichert ID in einer Variable
		userID = $ID

        #Brüft ob es einen Fehler gab
		if[ ! $? -eq 0 ]
		then
            #Abbrechen
			exit 3
		else
            #Sucht eine neue freie Group ID
			getNewID group
			#Speichert ID in einer Variable
            groupID = $ID

            #Brüft ob es einen Fehler gab
			if[ ! $? -eq 0 ]
			then
                #Abbrechen
				exit 4
			else
                #Prüft ob Gruppe bereits existiert
                #Legt ggf. eine neue Gruppe an
                checkAndAddGroup $userName $groupID

                #Nutzer in passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell
				echo "$userName:x:$userID:$groupID:$2:/home/$userName:/bin/bash" >> /etc/passwd

                #Homeverzeichnis anlegen
				mkdir /home/$userName

                #Nutzer die Besitzrechte auf das Verzeichnis übertragen
				chown $userName:$groupName /home/$userName
				#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
				chmod 700 /home/$userName

                #Passwort für Nutzer anlegen
				echo -e "$4\n$4" | (passwd $userName)
			fi
		fi
	fi
fi

function getNewID()
{
    #Kleinste belegte 4 stellige ID suchen
	ID = $(cat /etc/$1 | cut -f4 -d: | grep -e '^.\{4\}$' | sort -n | head -1)

    #Schleife bis ID frei ist
	while[ $(cat /etc/$1 | cut -f4 -d:) -ne $ID ]
	do
        #ID erhöhen
		ID = ID+1

        #Abfangen der größten ID -> Merke: Max ID = 65536
		if( $ID -eq "10000")
		then
            #Fehlermeldung wenn Max ID erreicht ist
			echo "Maximale $1 ID erreicht!"
			#Abbrechen
			exit 1
		else
            #ID exportieren
			export $ID
		fi
	done
}

function searchUser()
{
    #Prüfen ob Nutzer schon besteht
	if [ $(cat /etc/passwd | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]
	then
        #Fehlermeldung ausgeben das der Nutzer bereits existiert
		echo "Nutzer besteht bereits"
		#Abbrechen
		exit 1
	else
        #Username speichern
		userName = $1
		#Username exportieren
		export $userName
	fi
}

function checkAndAddGroup()
{
	#Gruppenname speichern
	groupName = $1
		
    #Prüft ob Gruppe bereits besteht
	if [ $(cat /etc/group | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]
	then
        #Meldung, dass Gruppe bereits besteht
		echo "Gruppe besteht bereits"
		
		#Gruppenummer abspeichern
		groupNumber = $(cat /etc/group | grep $1 | cut -f3 -d:)
		
		#Gruppennummer exportieren
		#Gruppenname exportieren
		export groupNumber
		export groupName
	else
        #Meldung, dass Gruppe noch nicht besteht
		echo "Gruppe besteht noch nicht"

		#Gruppe wird angelegt
        echo "$1:x:$2:" >> /etc/group
		#Gruppenname exportieren
		export groupName
	fi
}

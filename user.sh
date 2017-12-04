#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
then
	echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Kommentar und Passwort angegeben werden"		#Fehlermeldung wenn nur ein Parameter angegeben ist
	exit 1
else
	
	searchUser $1
	
	if [ $? -eq 0 ]																							#Prüfen ob Nutzer schon besteht
	then																										
		exit 2
	else
		getUserID
	
		if[ $? -ep 0 ]
		then
			exit 3
		else
			echo "$userName:x:$userID:501:$2:/home/$userName:/bin/bash" >> /etc/passwd						#Nutzer ini passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell  
			echo "$userName:x:501:" >> /etc/group															#Gruppe für Nutzer anlegen
		
			mkdir /home/$userName																			#Homeverzeichnis anlegen 
				
			chown $userName:$userName /home/$userName														#Nutzer die Besitzrechte auf das Verzeichnis übertragen
			chmod 700 /home/$userName																		#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
				
			echo -e "$4\n$4" | (passwd $userName)															#Passwort für Nutzer anlegen
		fi
	fi
fi

function getUserID()
{
	userID = $(cat /etc/passwd | grep -e '^.\{4\}$' | cut -f3 -d: | sort -n | head -1)
			
	while[ $(cat /etc/passwd | cut -f3 -d:) -ne $userID ]
	do
		((userID++))
		
		if( $userID -eq "65536")
		then
			echo "Maximale User-ID erreicht!"
			exit 1
		else
			export userID
		fi
	done
}

function searchUser()
{
	if [ $(cat /etc/passwd | grep $1 | cut -f1 -d: | wc -w) -gt 0 ]											#Prüfen ob Nutzer schon besteht
	then
		echo "Nutzer besteht bereits"																		#Fehlermeldung ausgeben das der Nutzer bereits existiert
		exit 1
	else
		userName = $1
		export userName
	fi
}

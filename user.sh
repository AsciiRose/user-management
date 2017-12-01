#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
	then
		echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Kommentar und Passwort angegeben werden" #Fehlermeldung wenn nur ein Parameter angegeben ist
		exit 1
	else
	if [ $(cat /etc/passwd | grep $1 | cut -f1 -d: | wc -w) -gt 0 ]								#Prüfen ob nutzer schon besteht
		then
			echo "Nutzer besteht bereits"														#Fehlermeldung ausgeben das der Nutzer bereits existiert
			exit 2
		else
			userID = $(cat /etc/passwd | grep -e '^.\{4\}$' | cut -f3 -d: | sort -n)
			userID = userID + 1
			echo "$1:x:$userID:501:$2:/home/$1:/bin/bash" >> /etc/passwd							#Nutzer ini passwd datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell  
			echo "$1:x:501:" >> /etc/group													#gruppe für nutzer anlegen
			mkdir /home/$1																	#Home verzeichnis anlegen 
			chown $1:$1 /home/$1															#nutzer die besitzrechte auf das verzeichnis übertragen
			chmod 700 /home/$1																#nutzer schreibrechte in eigenem Homeverzeichnis geben
			echo -e "$4\n$4" | (passwd $1)													#Passwort für nutzer anlegen
			
	fi
fi

function searchUser()
{
	if [ $(cat /etc/passwd | grep $1 | cut -f1 -d: | wc -w) -gt 0 ]								#Prüfen ob nutzer schon besteht
		then
			echo "Nutzer besteht bereits"														#Fehlermeldung ausgeben das der Nutzer bereits existiert
			exit 2
		else
			
		fi
	fi
}

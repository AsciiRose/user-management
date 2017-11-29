#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
	then
		echo "Zu wenige Parameter angegeben. Es müssen Nutzername, User-ID, Kommentar und Passwort angegeben werden" #Fehlermeldung wenn nur ein Parameter angegeben ist
		exit 1
	else
	if [ $(cat /etc/passwd | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]										#Prüfen ob Nutzer schon besteht
		then
			echo "Nutzer besteht bereits"													#Fehlermeldung ausgeben das der Nutzer bereits existiert
			exit 2
		else
			if [ $(cat /etc/passwd | grep $1 | cut -f3 -d: | wc -w) -eq $3 ]
			then
				echo "User-ID besteht bereits"													#Fehlermeldung ausgeben das der Nutzer bereits existiert
			    exit 2
			else
				echo "$1:x:$2:501:$3:/home/$1:/bin/bash" >> /etc/passwd						#Nutzer in passwd datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell  
				echo "$1:x:501:" >> /etc/group													#gruppe für nutzer anlegen
				mkdir /home/$1																	#Home verzeichnis anlegen 
				chown $1:$1 /home/$1															#nutzer die besitzrechte auf das verzeichnis übertragen
				chmod 700 /home/$1																#nutzer schreibrechte in eigenem Homeverzeichnis geben
				echo -e "$4\n$4" | (passwd $1)													#Passwort für nutzer anlegen
			fi
	fi
fi


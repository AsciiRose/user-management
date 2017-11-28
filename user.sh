#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
	then
		echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Kommentar und Passwort angegeben werden" #Fehlermeldung wenn nur ein Parameter angegeben ist
		exit 1
	else
	if [ $(cat /etc/passwd | cut -f1 -d: | grep $1 | wc -w) -gt 0 ]										#Prüfen ob Nutzer schon besteht
		then
			echo "Nutzer besteht bereits"													#Fehlermeldung ausgeben das der Nutzer bereits existiert
			exit 2
		else
			echo "$1:x:501:501:$2:/home/$1:/bin/bash" >> /etc/passwd						#Nutzer in passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell  
			echo "$1:x:501:" >> /etc/group													#Gruppe für Nutzer anlegen
			mkdir /home/$1																	#Homeverzeichnis anlegen 
			chown $1:$1 /home/$1															#Nutzer die Besitzrechte auf das Verzeichnis übertragen
			chmod 700 /home/$1																#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
			echo -e "$3\n$3" | (passwd $1)													#Passwort für Nutzer anlegen
	fi
fi

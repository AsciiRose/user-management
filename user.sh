#!/bin/bash
#Nennt dem Kernel den Pfad des Interpreters, der verwendet werden soll
if [ $# -lt 3 ]
then
	echo "Zu wenige Parameter angegeben. Es müssen Nutzername, Kommentar und Passwort angegeben werden"		#Fehlermeldung wenn nur ein Parameter angegeben ist
	exit 1
else
	
	searchUser $1															#Prüfen ob Nutzer schon besteht
	
	if [ $? -eq 0 ]									
	then																										
		exit 2
	else
		getUserID
	
		if[ $? -eq 0 ]
		then
			exit 3
		else
			getGroupID
			
			if[ $? -eq 0 ]
			then
				exit 4
			else
				echo "$userName:x:$userID:$groupID:$2:/home/$userName:/bin/bash" >> /etc/passwd					#Nutzer ini passwd Datei anlegen -> Name:Passwort:User-ID:Group-ID:Kommentar:Verzeichnis:Shell  
				
				if[ $? -ne 0 ]
				then
					echo "$userName:x:$groupID:" >> /etc/group													#Gruppe für Nutzer anlegen
				else
				fi	
			
				mkdir /home/$userName																			#Homeverzeichnis anlegen 
					
				chown $userName:$userName /home/$userName														#Nutzer die Besitzrechte auf das Verzeichnis übertragen
				chmod 700 /home/$userName																		#Nutzer Schreibrechte in eigenem Homeverzeichnis geben
					
				echo -e "$4\n$4" | (passwd $userName)															#Passwort für Nutzer anlegen
			fi
		fi
	fi
fi

function getGroupID()
{
	groupID = $(cat /etc/passwd | grep -e '^.\{4\}$' | cut -f4 -d: | sort -n | head -1)
			
	while[ $(cat /etc/passwd | cut -f4 -d:) -ne $groupID ]
	do
		groupID = $groupID + 1
		
		if( $groupID -eq "65536")
		then
			echo "Maximale Group-ID erreicht!"
			exit 1
		else
			export groupID
		fi
	done
}

function getUserID()
{
	userID = $(cat /etc/passwd | grep -e '^.\{4\}$' | cut -f3 -d: | sort -n | head -1)
			
	while[ $(cat /etc/passwd | cut -f3 -d:) -ne $userID ]
	do
		$userID = $userID + 1
		
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

function checkAndAddGroup()
{
	if [ $(cat /etc/group | grep $1 | cut -f1 -d: | wc -w) -gt 0 ]											
	then
		echo "Gruppe besteht bereits"																		
		groupNumber = $(cat /etc/group | grep $1 | cut -f3 -d:)
		export groupNumber
	else
		echo "Gruppe besteht noch nicht"
		getGroupID
			
		if[ $? -eq 0 ]
		then
			exit 1
		else
			echo "Gruppe wird angelegt"
			echo "$1:x:$groupID:" >> /etc/group																
			export 0
		fi
	fi
}

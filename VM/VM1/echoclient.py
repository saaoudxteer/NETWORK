#!/usr/bin/env python
# -*- coding: utf-8 -*-

# echo / client simple
#   Master Informatique 2014 -- UniversitÃ© Aix-Marseille  
#    Emmanuel Godard

# Python2 compatibility
from __future__ import print_function

# modules
import sys
import socket

MAXLIGNE = 64

# Traitement des arguments 
if len(sys.argv) !=3  : # erreur de syntaxe 
    print("Usage:", sys.argv[0], "hote port")
    sys.exit(1)

hote = sys.argv[1]      # nom d'hÃ´te du  serveur
port = int(sys.argv[2]) # port TCP du serveur    

# RÃ©solution de l'hÃ´te
# On ne considÃ¨re que la premiÃ¨re adresse renvoyÃ©e 
af, socktype, proto, canonname, saddr = socket.getaddrinfo(hote, port,)[0]

# CrÃ©ation de la socket, de type TCP / IP
try: 
    s = socket.socket(af, socktype, proto)
    print("le nÂ° de la socket est : ",s.fileno())
except socket.error:
    print("allocation de socket")
    sys.exit(3)

# Connexion 
# On extrait l'addresse IP
ip = saddr[0]
print('Essai de connexion Ã ', hote, '(', ip,' ) sur le port ', port)
try:    
    s.connect(saddr)
    print('ConnectÃ© Ã ', saddr)
except socket.error as err:
    s.close()
    print('Erreur Connexion :', err)
    sys.exit(3)

# Session 
fini = False
while  True:
# Jusqu'Ã  fermeture de la socket (ou de stdin)
# recopier Ã  l'Ã©cran ce qui est lu dans la socket
# recopier dans la socket ce qui est lu dans stdin 
    # rÃ©ception des donnÃ©es 
    donnees = s.recv(MAXLIGNE) # bloquant
    if not donnees:
        print("Connexion terminÃ©e par l'hÃ´te distant")
        break # on sort de la boucle infinie
    if sys.version_info[0] == 2:
        print('ReÃ§u:', donnees)
    else: # Python 3.x : gestion explicite pour unicode 
        print('ReÃ§u:', donnees.decode())

    if fini:
        break # on sort de la boucle infinie

    # recopier dans la socket ce qui est entrÃ© au clavier
    if sys.version_info[0] == 2:
        ligne = sys.stdin.readline()
    else: # python 3.x : gestion explicite pour unicode 
        ligne = sys.stdin.readline().encode()
    if not ligne: # entrÃ©e standard fermÃ©e 
        print('Connexion terminÃ©e !!')
        fini = True 
        print('HÃ´te distant informÃ©...')
        s.shutdown(socket.SHUT_WR) # terminaison explicite de la socket 
			           # dans le sens client -> serveur 
        # On ne sort pas de la boucle tout de suite ...
    else:
        s.send(ligne)
    # Fin de la boucle infinie
# Destruction de la socket 
s.close()

print('Fin de la session')
sys.exit(0)

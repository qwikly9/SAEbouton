# Définition du compilateur
CC = gcc
# Options de compilation (Wall = affiche tous les avertissements)
CFLAGS = -Wall

# Cible par défaut : compile tout
all: client serveur

# Règle pour le client
client: simpleClientSocket.c
	$(CC) $(CFLAGS) simpleClientSocket.c -o client

# Règle pour le serveur
serveur: simpleServerSocket.c
	$(CC) $(CFLAGS) simpleServerSocket.c -o serveur

# Nettoyage des fichiers exécutables
clean:
	rm -f client serveur

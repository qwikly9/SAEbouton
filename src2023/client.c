#include "client.h"
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

// Le parseur basique (compte les points-virgules)
void afficher_nom_prenom(char *ligne) {
  int colonne = 0;
  char nom[100] = {0};
  char prenom[100] = {0};
  int index_nom = 0;
  int index_prenom = 0;

  for (int i = 0; ligne[i] != '\0' && ligne[i] != '\n' && ligne[i] != '\r';
       i++) {
    if (ligne[i] == ';') {
      colonne++;
    } else {
      if (colonne == 4) {
        nom[index_nom++] = ligne[i];
      } else if (colonne == 6) {
        prenom[index_prenom++] = ligne[i];
      }
    }
  }
  nom[index_nom] = '\0';
  prenom[index_prenom] = '\0';

  if (strlen(nom) > 0 && strcmp(nom, "nom") != 0) {
    // Affichage aligné
    printf("%-20s %s\n", nom, prenom);
  }
}

// Fonction classique de connexion
int se_connecter_au_serveur(const char *hostname, int port) {
  int sockfd;
  struct sockaddr_in serv_addr;
  struct hostent *server;

  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    perror("Erreur d'ouverture du socket");
    return -1;
  }

  server = gethostbyname(hostname);
  if (server == NULL) {
    fprintf(stderr, "Erreur: hote introuvable\n");
    return -1;
  }

  bzero((char *)&serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr,
        server->h_length);
  serv_addr.sin_port = htons(port);

  if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
    perror("Erreur de connexion");
    return -1;
  }

  return sockfd;
}

// Fonction pour dialoguer avec le serveur
void demander_classe(int sockfd, const char *classe) {
  char buffer[256];
  bzero(buffer, 256);

  // On prépare et envoie le nom de la classe
  sprintf(buffer, "%s\n", classe);
  write(sockfd, buffer, strlen(buffer));

  // fdopen permet d'utiliser fgets sur le socket (très facile à lire ligne par
  // ligne)
  FILE *socket_f = fdopen(sockfd, "r");
  if (socket_f == NULL) {
    perror("Erreur de lecture du socket");
    return;
  }

  char ligne[512];
  printf("\n--- Liste des eleves ---\n");

  // On lit chaque ligne envoyée par le serveur
  while (fgets(ligne, sizeof(ligne), socket_f) != NULL) {
    if (strncmp(ligne, "Erreur", 6) == 0) {
      printf("%s", ligne); // Affiche l'erreur si le fichier n'existe pas
    } else {
      afficher_nom_prenom(ligne); // Sinon, on parse et on affiche
    }
  }
}

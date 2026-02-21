#include "client.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Utilisation : %s hostname port\n", argv[0]);
    exit(0);
  }

  const char *hostname = argv[1];
  int port = atoi(argv[2]);
  char classe[100];

  printf("Entrez le nom de la classe (ex: RT1FA) : ");
  scanf("%s", classe);

  // 1. Connexion au serveur
  int sockfd = se_connecter_au_serveur(hostname, port);
  if (sockfd < 0) {
    exit(1); // On quitte si la connexion échoue
  }

  // 2. Échange des données (Envoi de la requête et affichage de la réponse)
  demander_classe(sockfd, classe);

  // 3. Fermeture de la connexion
  close(sockfd);

  return 0;
}

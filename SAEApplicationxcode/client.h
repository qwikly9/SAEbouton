//
//  client.h
//  SAEApplicationxcode
//
//  Created by etudiant on 21/02/2026.
//

#ifndef CLIENT_H
#define CLIENT_H

// Fonction pour se connecter au serveur et renvoyer le "socket"
int se_connecter_au_serveur(const char *hostname, int port);

// Fonction pour extraire et afficher uniquement le Nom et Prénom d'une ligne
// CSV
void afficher_nom_prenom(char *ligne);

// Fonction qui envoie la classe demandée et lit la réponse du serveur
void demander_classe(int sockfd, const char *classe);
// Un tableau pour stocker jusqu'à 200 élèves (avec 100 caractères max par nom)
extern char liste_eleves[200][100];
extern int nb_eleves;
#endif

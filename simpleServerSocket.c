#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int main( int argc, char *argv[] )
{
    int sockfd, newsockfd, portno;
    socklen_t clilen;
    char buffer[256];
    struct sockaddr_in serv_addr, cli_addr;
    int n;

    sockfd = socket(PF_INET, SOCK_STREAM, 0);
    bzero((char *) &serv_addr, sizeof(serv_addr));
    portno = 5001;
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(portno);
    bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
    listen(sockfd,5);
    clilen = sizeof(cli_addr);

    printf("Serveur en attente sur le port %d...\n", portno);

    while (1)
    {
        newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);
        
        bzero(buffer,256);
        n = read(newsockfd, buffer, 255);
        
        buffer[strcspn(buffer, "\r\n")] = 0;
        
        printf("Le client veut la classe : %s\n", buffer);

        char nomFichier[100];
        sprintf(nomFichier, "CSV/%s.csv", buffer);

        FILE *f = fopen(nomFichier, "r");

        if (f == NULL) {
            write(newsockfd, "Erreur: Fichier introuvable\n", 28);
        } else {
            char ligne[256];
            while(fgets(ligne, 255, f) != NULL) {
                write(newsockfd, ligne, strlen(ligne));
            }
            fclose(f);
        }
        
        close(newsockfd);
    }
    return 0;
}

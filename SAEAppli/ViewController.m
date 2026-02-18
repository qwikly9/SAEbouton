//
//  ViewController.m
//  SAEAppli
//
//  Created by etudiant on 10/02/2026.
//

#import "ViewController.h"
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];

  // Données des 4 classes
  NSArray *classes = @[ @"RT1FA", @"RT1FI", @"RT2FA", @"RT2FI" ];
  NSArray *couleurs = @[
    [UIColor systemBlueColor], [UIColor systemGreenColor],
    [UIColor systemOrangeColor], [UIColor systemRedColor]
  ];

  // Création des 4 boutons carrés (grille 2x2)
  for (NSInteger i = 0; i < 4; i++) {
    CGFloat x = 40 + (i % 2) * 160;
    CGFloat y = 100 + (i / 2) * 160;

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 130, 130)];
    btn.backgroundColor = couleurs[i];
    [btn setTitle:classes[i] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 12;
    btn.tag = i;
    [btn addTarget:self
                  action:@selector(classeButtonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
  }

  // Initialisation du tableau de données
  self.elevesArray = [NSMutableArray array];

  // Création de la UITableView pour afficher les élèves
  self.tableViewEleves = [[UITableView alloc]
      initWithFrame:CGRectMake(20, 440, self.view.frame.size.width - 40,
                               self.view.frame.size.height - 460)
              style:UITableViewStylePlain];
  self.tableViewEleves.dataSource = self;
  self.tableViewEleves.delegate = self;
  self.tableViewEleves.layer.cornerRadius = 10;
  self.tableViewEleves.clipsToBounds = YES;
  [self.tableViewEleves registerClass:[UITableViewCell class]
               forCellReuseIdentifier:@"EleveCell"];
  [self.view addSubview:self.tableViewEleves];
}

// Action quand on appuie sur un bouton de classe
- (void)classeButtonTapped:(UIButton *)sender {
  NSArray *classes = @[ @"RT1FA", @"RT1FI", @"RT2FA", @"RT2FI" ];
  NSString *classe = classes[sender.tag];
  NSLog(@"Bouton appuyé : %@", classe);

  // Connexion au serveur dans un thread séparé
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    int sockfd, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char buffer[256];

    // Création du socket
    sockfd = socket(PF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
      NSLog(@"ERREUR socket");
      return;
    }

    // Résolution de l'hôte
    server = gethostbyname("127.0.0.1");
    if (server == NULL) {
      NSLog(@"ERREUR hôte");
      close(sockfd);
      return;
    }

    // Configuration de l'adresse du serveur
    bzero((char *)&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr,
          server->h_length);
    serv_addr.sin_port = htons(5001);

    // Connexion
    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
      NSLog(@"ERREUR connexion serveur (port 5001)");
      close(sockfd);
      return;
    }

    // Envoi du nom de la classe
    n = (int)write(sockfd, [classe UTF8String], strlen([classe UTF8String]));
    if (n < 0) {
      NSLog(@"ERREUR écriture socket");
      close(sockfd);
      return;
    }

    // Lecture de la réponse
    NSMutableString *reponse = [NSMutableString string];
    bzero(buffer, 256);
    while ((n = (int)read(sockfd, buffer, 255)) > 0) {
      buffer[n] = '\0';
      [reponse appendFormat:@"%s", buffer];
      bzero(buffer, 256);
    }
    close(sockfd);

    // Parsing du CSV : construction de la liste nom + prénom
    NSMutableArray *nouveauxEleves = [NSMutableArray array];
    printf("\n Parsing : Nom Prenom \n");
    for (NSString *ligne in [reponse
             componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                      newlineCharacterSet]]) {
      if (ligne.length == 0)
        continue;
      NSArray *champs = [ligne componentsSeparatedByString:@";"];
      // champs[4] = nom, champs[6] = prenom (on ignore l'en-tête)
      if (champs.count >= 7 && ![champs[0] isEqualToString:@"etudid"]) {
        NSString *nomPrenom =
            [NSString stringWithFormat:@"%@ %@", champs[4], champs[6]];
        printf("%s\n", [nomPrenom UTF8String]);
        [nouveauxEleves addObject:nomPrenom];
      }
    }

    // Mise à jour de la table sur le thread principal
    dispatch_async(dispatch_get_main_queue(), ^{
      self.elevesArray = nouveauxEleves;
      [self.tableViewEleves reloadData];
    });
  });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.elevesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"EleveCell"
                                      forIndexPath:indexPath];
  cell.textLabel.text = self.elevesArray[indexPath.row];
  cell.textLabel.font = [UIFont systemFontOfSiz e:16];
  return cell;
}

@end

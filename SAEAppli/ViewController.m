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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.eleves = [NSMutableArray array];
  self.view.backgroundColor = [UIColor systemBackgroundColor];

  // ==========================================
  // Titre principal
  // ==========================================
  self.titleLabel = [[UILabel alloc] init];
  self.titleLabel.text = @"📚 Liste des Élèves";
  self.titleLabel.font = [UIFont boldSystemFontOfSize:26];
  self.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.titleLabel];

  // ==========================================
  // Sous-titre / Instructions
  // ==========================================
  UILabel *subtitleLabel = [[UILabel alloc] init];
  subtitleLabel.text = @"Sélectionnez une classe pour afficher les élèves";
  subtitleLabel.font = [UIFont systemFontOfSize:14];
  subtitleLabel.textColor = [UIColor secondaryLabelColor];
  subtitleLabel.textAlignment = NSTextAlignmentCenter;
  subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:subtitleLabel];

  // ==========================================
  // Boutons pour chaque classe
  // ==========================================
  NSArray *classes = @[ @"RT1FA", @"RT1FI", @"RT2FA", @"RT2FI" ];
  NSArray *couleurs = @[
    [UIColor colorWithRed:0.20 green:0.60 blue:0.86 alpha:1.0], // Bleu
    [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0], // Vert
    [UIColor colorWithRed:0.90 green:0.49 blue:0.13 alpha:1.0], // Orange
    [UIColor colorWithRed:0.75 green:0.22 blue:0.17 alpha:1.0], // Rouge
  ];

  UIStackView *buttonStack = [[UIStackView alloc] init];
  buttonStack.axis = UILayoutConstraintAxisHorizontal;
  buttonStack.distribution = UIStackViewDistributionFillEqually;
  buttonStack.spacing = 10;
  buttonStack.translatesAutoresizingMaskIntoConstraints = NO;

  for (NSInteger i = 0; i < classes.count; i++) {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:classes[i] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    btn.backgroundColor = couleurs[i];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    btn.clipsToBounds = YES;
    btn.tag = i;
    [btn addTarget:self
                  action:@selector(classeButtonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:btn];
  }
  [self.view addSubview:buttonStack];

  // ==========================================
  // Label de statut (nombre d'élèves, erreurs)
  // ==========================================
  self.statusLabel = [[UILabel alloc] init];
  self.statusLabel.text = @"Aucune classe sélectionnée";
  self.statusLabel.font = [UIFont italicSystemFontOfSize:13];
  self.statusLabel.textColor = [UIColor tertiaryLabelColor];
  self.statusLabel.textAlignment = NSTextAlignmentCenter;
  self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.statusLabel];

  // ==========================================
  // TableView pour afficher la liste des élèves
  // ==========================================
  self.tableView =
      [[UITableView alloc] initWithFrame:CGRectZero
                                   style:UITableViewStyleInsetGrouped];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:@"EleveCell"];
  [self.view addSubview:self.tableView];

  // ==========================================
  // Contraintes Auto Layout
  // ==========================================
  [NSLayoutConstraint activateConstraints:@[
    // Titre
    [self.titleLabel.topAnchor
        constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
                       constant:15],
    [self.titleLabel.leadingAnchor
        constraintEqualToAnchor:self.view.leadingAnchor
                       constant:20],
    [self.titleLabel.trailingAnchor
        constraintEqualToAnchor:self.view.trailingAnchor
                       constant:-20],

    // Sous-titre
    [subtitleLabel.topAnchor
        constraintEqualToAnchor:self.titleLabel.bottomAnchor
                       constant:5],
    [subtitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:20],
    [subtitleLabel.trailingAnchor
        constraintEqualToAnchor:self.view.trailingAnchor
                       constant:-20],

    // Boutons
    [buttonStack.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor
                                          constant:20],
    [buttonStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                              constant:20],
    [buttonStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                               constant:-20],
    [buttonStack.heightAnchor constraintEqualToConstant:50],

    // Statut
    [self.statusLabel.topAnchor constraintEqualToAnchor:buttonStack.bottomAnchor
                                               constant:12],
    [self.statusLabel.leadingAnchor
        constraintEqualToAnchor:self.view.leadingAnchor
                       constant:20],
    [self.statusLabel.trailingAnchor
        constraintEqualToAnchor:self.view.trailingAnchor
                       constant:-20],

    // TableView
    [self.tableView.topAnchor
        constraintEqualToAnchor:self.statusLabel.bottomAnchor
                       constant:10],
    [self.tableView.leadingAnchor
        constraintEqualToAnchor:self.view.leadingAnchor],
    [self.tableView.trailingAnchor
        constraintEqualToAnchor:self.view.trailingAnchor],
    [self.tableView.bottomAnchor
        constraintEqualToAnchor:self.view.bottomAnchor],
  ]];
}

// ==========================================
// Action quand on appuie sur un bouton de classe
// ==========================================
- (void)classeButtonTapped:(UIButton *)sender {
  NSArray *classes = @[ @"RT1FA", @"RT1FI", @"RT2FA", @"RT2FI" ];
  NSString *classe = classes[sender.tag];

  NSLog(@"Bouton appuyé : %@", classe);

  // Mise à jour du statut
  dispatch_async(dispatch_get_main_queue(), ^{
    self.statusLabel.text =
        [NSString stringWithFormat:@"Connexion au serveur pour %@...", classe];
    self.statusLabel.textColor = [UIColor systemOrangeColor];
  });

  // Connexion au serveur dans un thread séparé
  [self connecterAuServeurAvecClasse:classe];
}

// ==========================================
// Connexion socket au serveur (même logique que simpleClientSocket.c)
// ==========================================
- (void)connecterAuServeurAvecClasse:(NSString *)classe {

  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int sockfd, n;
        struct sockaddr_in serv_addr;
        struct hostent *server;
        char buffer[256];

        // 1) Création du socket (comme dans simpleClientSocket.c)
        sockfd = socket(PF_INET, SOCK_STREAM, 0);
        if (sockfd < 0) {
          NSLog(@"ERREUR : impossible d'ouvrir le socket");
          [self afficherErreur:@"Impossible d'ouvrir le socket"];
          return;
        }

        // 2) Résolution du nom d'hôte
        server = gethostbyname("127.0.0.1");
        if (server == NULL) {
          NSLog(@"ERREUR : hôte introuvable");
          close(sockfd);
          [self afficherErreur:@"Hôte introuvable"];
          return;
        }

        // 3) Configuration de l'adresse du serveur
        bzero((char *)&serv_addr, sizeof(serv_addr));
        serv_addr.sin_family = AF_INET;
        bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr,
              server->h_length);
        serv_addr.sin_port = htons(5001);

        // 4) Connexion au serveur
        if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) <
            0) {
          NSLog(@"ERREUR : connexion au serveur impossible (port 5001)");
          close(sockfd);
          [self afficherErreur:
                    @"Impossible de se connecter au serveur.\n\nAssurez-vous "
                    @"que le serveur est lancé :\ncd src2023 && ./serveur"];
          return;
        }

        NSLog(@"Connecté au serveur sur le port 5001");

        // 5) Envoi du nom de la classe au serveur (comme dans
        // simpleClientSocket.c)
        const char *classeStr = [classe UTF8String];
        n = (int)write(sockfd, classeStr, strlen(classeStr));
        if (n < 0) {
          NSLog(@"ERREUR : écriture sur le socket impossible");
          close(sockfd);
          [self afficherErreur:@"Erreur d'écriture sur le socket"];
          return;
        }

        NSLog(@"Classe demandée envoyée au serveur : %@", classe);

        // 6) Lecture de la réponse du serveur (comme dans simpleClientSocket.c)
        NSMutableString *reponse = [NSMutableString string];
        bzero(buffer, 256);

        while ((n = (int)read(sockfd, buffer, 255)) > 0) {
          buffer[n] = '\0';
          [reponse appendFormat:@"%s", buffer];
          bzero(buffer, 256);
        }

        // 7) Fermeture du socket
        close(sockfd);

        // ==========================================
        // Affichage dans le terminal (NSLog) comme simpleClientSocket.c
        // ==========================================
        NSLog(@"\n\n===================================");
        NSLog(@"   Liste des élèves - %@", classe);
        NSLog(@"===================================");
        NSLog(@"%@", reponse);
        NSLog(@"===================================\n\n");

        // ==========================================
        // Parsing du CSV et mise à jour de l'interface
        // ==========================================
        NSArray *lignes = [reponse
            componentsSeparatedByCharactersInSet:[NSCharacterSet
                                                     newlineCharacterSet]];
        NSMutableArray *nouveauxEleves = [NSMutableArray array];

        for (NSInteger i = 0; i < lignes.count; i++) {
          NSString *ligne = lignes[i];

          // Ignorer les lignes vides
          if (ligne.length == 0)
            continue;

          NSArray *champs = [ligne componentsSeparatedByString:@";"];

          // On a besoin d'au moins 7 champs, et on saute la ligne d'en-tête
          if (champs.count >= 7) {
            // Vérifier si c'est l'en-tête (première ligne)
            if ([champs[0] isEqualToString:@"etudid"])
              continue;

            NSDictionary *eleve = @{
              @"nom" : champs[4],
              @"prenom" : champs[6],
              @"civilite" : champs[3],
              @"etat" : champs[2],
              @"tp" : (champs.count >= 8) ? champs[7] : @""
            };
            [nouveauxEleves addObject:eleve];

            // Affichage de chaque élève dans le terminal
            NSLog(@"  → %@ %@ %@ (TP: %@)", eleve[@"civilite"], eleve[@"nom"],
                  eleve[@"prenom"], eleve[@"tp"]);
          }
        }

        NSLog(@"\nTotal : %lu élèves", (unsigned long)nouveauxEleves.count);

        // ==========================================
        // Mise à jour de l'interface sur le thread principal
        // ==========================================
        dispatch_async(dispatch_get_main_queue(), ^{
          self.eleves = nouveauxEleves;
          self.titleLabel.text =
              [NSString stringWithFormat:@"📚 Classe %@", classe];
          self.statusLabel.text = [NSString
              stringWithFormat:@"✅ %lu élèves chargés depuis le serveur",
                               (unsigned long)nouveauxEleves.count];
          self.statusLabel.textColor = [UIColor systemGreenColor];
          [self.tableView reloadData];
        });
      });
}

// ==========================================
// Afficher une alerte d'erreur
// ==========================================
- (void)afficherErreur:(NSString *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.statusLabel.text = @"❌ Erreur de connexion";
    self.statusLabel.textColor = [UIColor systemRedColor];

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Erreur de connexion"
                         message:message
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
  });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.eleves.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"EleveCell"
                                      forIndexPath:indexPath];

  NSDictionary *eleve = self.eleves[indexPath.row];

  // Configuration de la cellule
  UIListContentConfiguration *config =
      [UIListContentConfiguration subtitleCellConfiguration];

  // Nom et prénom
  config.text = [NSString stringWithFormat:@"%@ %@ %@", eleve[@"civilite"],
                                           eleve[@"nom"], eleve[@"prenom"]];

  // Groupe TP en sous-titre
  config.secondaryText =
      [NSString stringWithFormat:@"Groupe : %@", eleve[@"tp"]];

  // Style
  config.textProperties.font = [UIFont systemFontOfSize:16
                                                 weight:UIFontWeightMedium];
  config.secondaryTextProperties.font = [UIFont systemFontOfSize:13];
  config.secondaryTextProperties.color = [UIColor secondaryLabelColor];

  // Icône selon l'état
  if ([eleve[@"etat"] isEqualToString:@"I"]) {
    config.image = [UIImage systemImageNamed:@"person.fill"];
    config.imageProperties.tintColor = [UIColor systemGreenColor];
  } else {
    config.image = [UIImage systemImageNamed:@"person.badge.minus"];
    config.imageProperties.tintColor = [UIColor systemRedColor];
  }

  cell.contentConfiguration = config;

  return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section {
  if (self.eleves.count > 0) {
    return @"Liste des élèves";
  }
  return nil;
}

@end

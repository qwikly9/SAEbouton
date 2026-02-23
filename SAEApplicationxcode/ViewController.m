#import "ViewController.h"
#include "client.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // On initialise le tableau vide au lancement
    self.donneesObjC = [[NSMutableArray alloc] init];
    
    // On dit au tableau que c'est ce code qui gère ses données
    self.maTableView.dataSource = self;
    self.maTableView.delegate = self;
}

- (void)chargerClasse:(NSString *)nomPromo {
    int sockfd = se_connecter_au_serveur("127.0.0.1", 5001);
    
    if (sockfd >= 0) {
        // [nomPromo UTF8String] transforme le texte Apple en char C
        demander_classe(sockfd, (char *)[nomPromo UTF8String]);
        
        // On vide l'ancien affichage
        [self.donneesObjC removeAllObjects];
        
        // On transforme le tableau C en tableau Objective-C
        for (int i = 0; i < nb_eleves; i++) {
            NSString *nomComplet = [NSString stringWithUTF8String:liste_eleves[i]];
            [self.donneesObjC addObject:nomComplet];
        }
        
        // On dit au TableView de se mettre à jour avec les nouveaux noms !
        [self.maTableView reloadData];
        
    } else {
        printf("Erreur : Impossible de joindre le serveur.\n");
    }
}


- (IBAction)clickBoutonRT1FA:(id)sender {
    [self chargerClasse:@"RT1FA"];
}

- (IBAction)clickBoutonRT1FI:(id)sender {
    [self chargerClasse:@"RT1FI"];
}

- (IBAction)clickBoutonRT2FA:(id)sender {
    [self chargerClasse:@"RT2FA"];
}

- (IBAction)clickBoutonRT2FI:(id)sender {
    [self chargerClasse:@"RT2FI"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.donneesObjC.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CelluleEleve" forIndexPath:indexPath];
    cell.textLabel.text = self.donneesObjC[indexPath.row];
    return cell;
}

@end

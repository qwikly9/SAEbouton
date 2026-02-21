#import "ViewController.h"
#include "client.h"

// On ajoute UITableViewDataSource et UITableViewDelegate (c'est ce qui fait marcher le tableau)
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *maTableView;
@property (strong, nonatomic) NSMutableArray *donneesObjC; // Le tableau version Apple

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // On initialise le tableau vide au lancement
    self.donneesObjC = [[NSMutableArray alloc] init];
    
    // On dit au tableau que c'est ce code qui gère ses données
    self.maTableView.dataSource = self;
    self.maTableView.delegate = self;
}

- (IBAction)clickBoutonRT1FA:(id)sender {
    int sockfd = se_connecter_au_serveur("127.0.0.1", 5001);
    
    if (sockfd >= 0) {
        demander_classe(sockfd, "RT1FA"); // Ça remplit notre tableau en C !
        close(sockfd);
        
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

// --- LES DEUX FONCTIONS OBLIGATOIRES DU TUTORIEL TABLEVIEW ---

// 1. Combien y a-t-il de lignes dans le tableau ?
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.donneesObjC.count;
}

// 2. Que met-on dans chaque case du tableau ?
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // On récupère la cellule qu'on a nommée "CelluleEleve" dans le Storyboard
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CelluleEleve" forIndexPath:indexPath];
    
    // On écrit le nom de l'élève dedans
    cell.textLabel.text = self.donneesObjC[indexPath.row];
    
    return cell;
}

@end

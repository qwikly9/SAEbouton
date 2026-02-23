//
//  ViewController.h
//  SAEApplicationxcode
//
//  Created by etudiant on 21/02/2026.
//

#import <UIKit/UIKit.h>

// On met les protocoles ici
@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// On déclare la TableView et notre tableau ici
@property (weak, nonatomic) IBOutlet UITableView *maTableView;
@property (strong, nonatomic) NSMutableArray *donneesObjC;

@end


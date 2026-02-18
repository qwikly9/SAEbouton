//
//  ViewController.h
//  SAEAppli
//
//  Created by etudiant on 10/02/2026.
//

#import <UIKit/UIKit.h>

@interface ViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableViewEleves;
@property(nonatomic, strong) NSMutableArray *elevesArray;

@end

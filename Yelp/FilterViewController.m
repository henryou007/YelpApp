//
//  FilterViewController.m
//  Yelp
//
//  Created by Jin You on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "SwitchCell.h"

@interface FilterViewController ()  <UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate>

@property (strong, nonatomic) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *filtersTableView;
@property (strong, nonatomic) NSArray *optionSections;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *sortOptions;
@property (strong, nonatomic) NSArray *distOptions;
@property (assign, nonatomic) BOOL dealFilterOn;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSMutableSet *selectedSortOptions;
@property (nonatomic, strong) NSMutableSet *selectedDistOptions;
@property (assign, nonatomic) BOOL distCellExpanded;
@property (assign, nonatomic) BOOL categoryListExpanded;


@end

@implementation FilterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.selectedCategories = [NSMutableSet set];
        self.selectedSortOptions = [NSMutableSet set];
        self.selectedDistOptions = [NSMutableSet set];
        [self initCategories];
        [self initSections];
        [self initSortOptions];
        [self initdistOptions];
        self.dealFilterOn = NO;
        self.distCellExpanded = NO;
        self.categoryListExpanded = NO;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.filtersTableView.delegate = self;
    self.filtersTableView.dataSource = self;
    [self.filtersTableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonTap)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButtonTap)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    if (indexPath.section == 0) {
        // Sort by
        cell.on = [self.selectedSortOptions containsObject:self.sortOptions[indexPath.row]];
        cell.delegate = self;
        cell.titleLabel.text = self.sortOptions[indexPath.row][@"name"];
    } else if (indexPath.section == 1) {
        // Distance
        if (self.distCellExpanded) {
            if (indexPath.row == 0) {
                cell.on = self.distCellExpanded;
                cell.delegate = self;
                cell.titleLabel.text = @"Options";
            } else {
                cell.on = [self.selectedDistOptions containsObject:self.distOptions[indexPath.row - 1]];
                cell.delegate = self;
                cell.titleLabel.text = self.distOptions[indexPath.row - 1][@"name"];
            }
        } else {
            cell.on = self.distCellExpanded;
            cell.delegate = self;
            if ([self.selectedDistOptions count] > 0) {
                cell.titleLabel.text = [self.selectedDistOptions anyObject][@"name"];
            } else {
                cell.titleLabel.text = @"Auto";
            }
        }
    } else if (indexPath.section == 2) {
        // Deals
        cell.on = self.dealFilterOn;
        cell.delegate = self;
        cell.titleLabel.text = @"Deals";
    } else {
        // Cetegory
        if (self.categoryListExpanded) {
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.delegate = self;
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
        } else {
            if (indexPath.row == 4) {
                cell.on = NO;
                cell.delegate = self;
                cell.titleLabel.text = @"See All";
            } else {
                cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                cell.delegate = self;
                cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            }
        }
        

    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.optionSections[section][@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num_rows = 0;
    if (section == 0) {
        // Sort by
        num_rows = 3;
    } else if (section == 1) {
        // Distance
        if (self.distCellExpanded) {
            num_rows = 6;
        } else {
            num_rows = 1;
        }
    } else if (section == 2) {
        // Deals
        num_rows = 1;
    } else {
        // Cetegory
        if (self.categoryListExpanded) {
            num_rows = 169;
        } else {
            num_rows = 5;
        }
    }
    return num_rows;
}

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.filtersTableView indexPathForCell:cell];
    
    if (indexPath.section == 0) {
        // Sort by
        if (value) {
            self.selectedSortOptions = [NSMutableSet set];
            [self.selectedSortOptions addObject:self.sortOptions[indexPath.row]];
        } else {
            [self.selectedSortOptions removeObject:self.sortOptions[indexPath.row]];
        }
    } else if (indexPath.section == 1) {
        // Distance
        
        if (self.distCellExpanded && indexPath.row > 0) {
            if (value) {
                self.selectedDistOptions = [NSMutableSet set];
                [self.selectedDistOptions addObject:self.distOptions[indexPath.row - 1]];
            } else {
                [self.selectedDistOptions removeObject:self.distOptions[indexPath.row - 1]];
            }
            self.distCellExpanded = NO;
        } else {
            self.distCellExpanded = !self.distCellExpanded;
        }
    } else if (indexPath.section == 2) {
        // Deals
        self.dealFilterOn = value;
    } else {
        // Cetegory
        if (!self.categoryListExpanded && indexPath.row == 4) {
            self.categoryListExpanded = YES;
        } else {
            
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
        }
    }
    
    [self.filtersTableView reloadData];
}

- (NSDictionary *) filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }

    if (self.selectedSortOptions.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *sort in self.selectedSortOptions) {
            [names addObject:sort[@"code"]];
        }
        NSString *sortFilter = [names componentsJoinedByString:@","];
        [filters setObject:sortFilter forKey:@"sort"];
    }
    
    if (self.selectedDistOptions.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *dist in self.selectedDistOptions) {
            [names addObject:dist[@"code"]];
        }
        NSString *distFilter = [names componentsJoinedByString:@","];
        [filters setObject:distFilter forKey:@"radius_filter"];
    }
    
    if (self.dealFilterOn) {
        [filters setObject:@YES forKey:@"deals_filter"];
    }
    
    return filters;
}

- (void)onCancelButtonTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButtonTap {
    [self.delegate filterViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSections {
    self.optionSections = @[
                            @{@"title" : @"Sort by"},
                            @{@"title" : @"Distance"},
                            @{@"title" : @"Deals"},
                            @{@"title" : @"Category"},
                            ];
}

- (void)initSortOptions {
    self.sortOptions =
    @[
      @{@"name" : @"Best Match", @"code" : @"0"},
      @{@"name" : @"Distance", @"code" : @"1"},
      @{@"name" : @"Highest Rated", @"code" : @"2"},
      ];
}

- (void)initdistOptions {
    self.distOptions =
    @[
      @{@"name" : @"Auto", @"code" : @"1609"},
      @{@"name" : @"0.3 miles", @"code" : @"483"},
      @{@"name" : @"1 miles", @"code" : @"1609"},
      @{@"name" : @"5 miles", @"code" : @"8047"},
      @{@"name" : @"20 miles", @"code" : @"32187"},
      ];
}

- (void)initCategories {
    self.categories =
    @[
      @{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Arabian", @"code": @"arabian" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Armenian", @"code": @"armenian" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Asturian", @"code": @"asturian" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Baguettes", @"code": @"baguettes" },
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Bavarian", @"code": @"bavarian" },
      @{@"name" : @"Beer Garden", @"code": @"beergarden" },
      @{@"name" : @"Beer Hall", @"code": @"beerhall" },
      @{@"name" : @"Beisl", @"code": @"beisl" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Bistros", @"code": @"bistros" },
      @{@"name" : @"Black Sea", @"code": @"blacksea" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Canadian", @"code": @"New)" },
      @{@"name" : @"Canteen", @"code": @"canteen" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Chech", @"code": @"chech" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chilean", @"code": @"chilean" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
      @{@"name" : @"Cypriot", @"code": @"cypriot" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
      @{@"name" : @"Danish", @"code": @"danish" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Dumplings", @"code": @"dumplings" },
      @{@"name" : @"Eastern European", @"code": @"eastern_european" },
      @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
      @{@"name" : @"Galician", @"code": @"galician" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"Georgian", @"code": @"georgian" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Giblets", @"code": @"giblets" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Heuriger", @"code": @"heuriger" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"International", @"code": @"international" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Island Pub", @"code": @"island_pub" },
      @{@"name" : @"Israeli", @"code": @"israeli" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Jewish", @"code": @"jewish" },
      @{@"name" : @"Kebab", @"code": @"kebab" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Kurdish", @"code": @"kurdish" },
      @{@"name" : @"Laos", @"code": @"laos" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Meatballs", @"code": @"meatballs" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Milk Bars", @"code": @"milkbars" },
      @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"New Zealand", @"code": @"newzealand" },
      @{@"name" : @"Night Food", @"code": @"nightfood" },
      @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
      @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
      @{@"name" : @"Oriental", @"code": @"oriental" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
      @{@"name" : @"Parma", @"code": @"parma" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pita", @"code": @"pita" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Potatoes", @"code": @"potatoes" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Pub Food", @"code": @"pubfood" },
      @{@"name" : @"Rice", @"code": @"riceshop" },
      @{@"name" : @"Romanian", @"code": @"romanian" },
      @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
      @{@"name" : @"Rumanian", @"code": @"rumanian" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
      @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Swabian", @"code": @"swabian" },
      @{@"name" : @"Swedish", @"code": @"swedish" },
      @{@"name" : @"Swiss Food", @"code": @"swissfood" },
      @{@"name" : @"Tabernas", @"code": @"tabernas" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
      @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
      @{@"name" : @"Trattorie", @"code": @"trattorie" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Venison", @"code": @"venison" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
      @{@"name" : @"Wok", @"code": @"wok" },
      @{@"name" : @"Wraps", @"code": @"wraps" },
      @{@"name" : @"Yugoslav", @"code": @"yugoslav" }
      ];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

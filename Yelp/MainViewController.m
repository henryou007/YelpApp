//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "RestaurantTableViewCell.h"
#import "FilterViewController.h"

#import "UIImageView+AFNetworking.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <FilterViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;

@property (weak, nonatomic) IBOutlet UITableView *restaurantTableView;
@property (strong, nonatomic) UISearchBar *restaurantSearchBar;
@property (strong, nonatomic) NSArray *restaurantData;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self reloadDataWithSearchTerm:@"Thai" andParams:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.restaurantTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.restaurantTableView.dataSource = self;
    self.restaurantTableView.delegate =self;
    [self.restaurantTableView registerNib:[UINib nibWithNibName:@"RestaurantTableViewCell" bundle:nil] forCellReuseIdentifier:@"RestaurantTableViewCell"];
    self.restaurantTableView.rowHeight = UITableViewAutomaticDimension;
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButtonTap)];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    
    self.restaurantSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 44.0)];
    self.restaurantSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.restaurantSearchBar.delegate = self;
    self.navigationItem.titleView = self.restaurantSearchBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.restaurantData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantTableViewCell *cell = [self.restaurantTableView dequeueReusableCellWithIdentifier:@"RestaurantTableViewCell"];
    NSDictionary *restaurantInfo = self.restaurantData[indexPath.row];
    cell.restaurantNameLabel.text = restaurantInfo[@"name"];
    cell.addressLabel.text = [[restaurantInfo valueForKeyPath:@"location.display_address"] componentsJoinedByString:@", "];
    cell.numReviewLabel.text = [NSString stringWithFormat:@"%@ Reviews", restaurantInfo[@"review_count"]];
    cell.pricelabel.text = @"$$";
    float distInMiles = [restaurantInfo[@"distance"] floatValue]/1609.34;
    cell.distLabel.text = [NSString stringWithFormat:@"%.1f mi", distInMiles];
    
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (NSArray *category in restaurantInfo[@"categories"]) {
        [categories addObject:category[0]];
    }
    cell.cuisineLabel.text = [categories componentsJoinedByString:@", "];
    
    [cell.ratingImageView setImageWithURL:[NSURL URLWithString:restaurantInfo[@"rating_img_url"]]];
    [cell.restaurantImageview setImageWithURL:[NSURL URLWithString:restaurantInfo[@"image_url"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onFilterButtonTap {
    FilterViewController *fvc = [[FilterViewController alloc] init];
    fvc.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self reloadDataWithSearchTerm:searchBar.text andParams:nil];
}

- (void)reloadDataWithSearchTerm: (NSString *)term andParams:(NSDictionary *)params{
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
    self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    
    [self.client searchWithTerm:term params:params success:^(AFHTTPRequestOperation *operation, id response) {
        
        self.restaurantData = ((NSDictionary *)response)[@"businesses"];
        NSLog(@"%@", self.restaurantData);
        
        [self.restaurantTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)filterViewController:(FilterViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    // TODO: fire a new network event here.
    NSLog(@"%@", filters);
    [self reloadDataWithSearchTerm:self.restaurantSearchBar.text andParams:filters];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

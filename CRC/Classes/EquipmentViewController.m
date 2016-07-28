//
//  EquipmentViewController.m
//  CRC
//
//  Created by Jinhui Lee on 11/29/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "EquipmentViewController.h"
#import "EquipmentCell.h"
#import "EquipmentData.h"
#import "SearchBar.h"
#import "SBJSON.h"
#import "SwipeView.h"
#import "MBProgressHUD.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, ConnectionStatus) {
    ConnectionStatusDownloadFilter,
    ConnectionStatusDownloadData,
};

@interface EquipmentViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate ,SearchBarDelegate>
{
    BOOL                _bReloading;
    BOOL                _bInit;
    BOOL                _bEnable;
    
    ConnectionStatus    _connectionStatus;
    
    UITableView*        _tableView;
    UIRefreshControl*   _refresh;
    
    NSMutableData*      _receivedData;
    NSURLConnection*    _connection;
}

@property (strong, nonatomic)   UITableView* tableViewFilter;
@property (strong, nonatomic)   UITableView* tableViewSearch;

@property (strong, nonatomic)   SwipeView*  filterView;

@property (assign, nonatomic)   NSInteger selectedIndex;
@property (assign, nonatomic)   NSInteger highlightedIndex;

@property (weak, nonatomic) IBOutlet UILabel *lblCameraLental;
@property (weak, nonatomic) IBOutlet SearchBar *searcher;
@property (weak, nonatomic) IBOutlet UIButton *btSearch;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet TouchView *topView;

@end

@implementation EquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init data
    _bInit = YES;
    
    self.selectedIndex = -1;
    self.highlightedIndex = -1;
    
    // init tableView
    CGRect  frame  = self.container.frame;
    
    self.tableViewSearch = [[UITableView alloc] initWithFrame:frame];
    self.tableViewSearch.dataSource = self;
    self.tableViewSearch.delegate = self;
    self.tableViewSearch.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.filterView = [[SwipeView alloc] initWithFrame:frame];
    
    CGFloat height = CGRectGetHeight(self.filterView.frame);
    frame = CGRectOffset(frame, 0, height);
    frame.size.height -= height;
    
    self.tableViewFilter = [[UITableView alloc] initWithFrame:frame];
    self.tableViewFilter.dataSource = self;
    self.tableViewFilter.delegate = self;
    self.tableViewFilter.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    self.filterView.contentView = self.tableViewFilter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ClearCart)
                                                 name:kEquipmentClearNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filterSearch:)
                                                 name:kEquipmentFilterChangedNotification object:nil];

    [self.view addSubview:self.filterView];
    [self.view addSubview:self.tableViewFilter];
    [self.view addSubview:self.tableViewSearch];
    
    frame = self.topView.frame;
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = kForeColor;
    [self.view addSubview:view];
    
    [self.view addSubview:self.topView];
    self.topView.parentView = self.filterView;
    
    self.btBack.hidden = YES;
    self.searcher.hidden = YES;
    self.tableViewSearch.hidden = YES;

    _tableView = self.tableViewFilter;
    
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    _refresh.tintColor = [UIColor blackColor];
    
    [self.tableViewFilter addSubview:_refresh];
    
    [_refresh beginRefreshing];
    [self enableControls:NO];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self downloadFilter];
}

- (void)refreshView:(UIRefreshControl *)refresh  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // (...code to get new data here...)
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"refreshView");
            //any UI refresh
            [_refresh endRefreshing];
        });
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(_bInit)
    {
        _bInit = NO;
        _bEnable = YES;
        
        CGFloat width = CGRectGetWidth(self.container.frame);
        
        self.btBack.frame = CGRectOffset(self.btBack.frame, -width, 0);
        self.searcher.frame = CGRectOffset(self.searcher.frame, -width, 0);
        self.tableViewSearch.frame = CGRectOffset(self.tableViewSearch.frame, -width, 0);
        
        self.btBack.hidden = NO;
        self.searcher.hidden = NO;
        self.tableViewSearch.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.view setNeedsLayout];

    _bReloading = YES;
    
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AddToCart:)
                                                 name:kEquipmentAddToCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RemoveFromCart:)
                                                 name:kEquipmentRemoveFromCartNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEquipmentAddToCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEquipmentRemoveFromCartNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Enable Controls

- (void)enableControls:(BOOL)enable
{
    self.btBack.enabled = enable;
    self.btSearch.enabled = enable;
}

#pragma mark - Serach Button action

- (IBAction)OnSearch:(id)sender
{
    CGFloat width = CGRectGetWidth(self.container.frame);

    self.selectedIndex      = -1;
    self.highlightedIndex   = -1;
    _tableView              = self.tableViewSearch;

    [[EquipmentData sharedData] searchWithString:self.searcher.text];
    [_tableView reloadData];

    _bEnable = NO;

    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         self.btBack.frame = CGRectOffset(self.btBack.frame, width, 0);
                         self.searcher.frame = CGRectOffset(self.searcher.frame, width, 0);
                         self.tableViewSearch.frame = CGRectOffset(self.tableViewSearch.frame, width, 0);
                         
                         self.btSearch.frame = CGRectOffset(self.btSearch.frame, width, 0);
                         self.lblCameraLental.frame = CGRectOffset(self.lblCameraLental.frame, width, 0);
                         self.tableViewFilter.frame = CGRectOffset(self.tableViewFilter.frame, width, 0);
                         self.filterView.frame = CGRectOffset(self.filterView.frame, width, 0);
                     }
                     completion:^(BOOL finished){
                         _bEnable = YES;
                     }];
    [UIView commitAnimations];
}

- (IBAction)OnBack:(id)sender
{
    CGFloat width = CGRectGetWidth(self.container.frame);
    
    self.selectedIndex      = -1;
    self.highlightedIndex   = -1;
    _tableView              = self.tableViewFilter;

    [self.view endEditing:YES];

    [[EquipmentData sharedData] searchWithFilter:[self.filterView searchFilter]];
    [_tableView reloadData];

    _bEnable = NO;

    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         self.btBack.frame = CGRectOffset(self.btBack.frame, -width, 0);
                         self.searcher.frame = CGRectOffset(self.searcher.frame, -width, 0);
                         self.tableViewSearch.frame = CGRectOffset(self.tableViewSearch.frame, -width, 0);
                         
                         self.btSearch.frame = CGRectOffset(self.btSearch.frame, -width, 0);
                         self.lblCameraLental.frame = CGRectOffset(self.lblCameraLental.frame, -width, 0);
                         self.tableViewFilter.frame = CGRectOffset(self.tableViewFilter.frame, -width, 0);
                         self.filterView.frame = CGRectOffset(self.filterView.frame, -width, 0);
                     }
                     completion:^(BOOL finished){
                         _bEnable = YES;
                     }];
    [UIView commitAnimations];
}

#pragma mark - process cart

- (void)AddToCart:(NSNotification*)notification
{
    NSIndexPath* indexPath = (NSIndexPath*)[notification object];
    
    [self searchDone];
    
    [[EquipmentData sharedData] addToCartWithIndex:indexPath.row];

    self.highlightedIndex = -1;
    self.selectedIndex = indexPath.row;
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)RemoveFromCart:(NSNotification*)notification
{
    NSIndexPath* indexPath = (NSIndexPath*)[notification object];
    
    NSMutableDictionary* dic = [[EquipmentData sharedData] equipmentDataWithIndex:indexPath.row];

    [[EquipmentData sharedData] RemoveFromCart:dic];
    
    self.highlightedIndex = -1;
    self.selectedIndex = -1;
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)ClearCart
{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [[EquipmentData sharedData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellID = @"EquipmentCellID";
    EquipmentCell *cell = (EquipmentCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[EquipmentCell alloc] initWithReuseIdentifier:cellID];
    }

    NSMutableDictionary* dic = [[EquipmentData sharedData] equipmentDataWithIndex:indexPath.row];
    
    if(dic)
    {
        cell.information = [EquipmentData infoOfEquipment:dic];
        cell.cost = [EquipmentData costOfEquipment:dic];
        cell.imageURL = [NSURL URLWithString:[EquipmentData imagePathOfEquipment:dic]];
        
        cell.state = _bReloading ? EquipmentCellStateReload : EquipmentCellStateNone;
        
        if(self.highlightedIndex == indexPath.row)
        {
            cell.state = EquipmentCellStateHighlighted;
        }
        else
        {
            if([[EquipmentData sharedData] cartWithSortIndex:indexPath.row])
                cell.state = EquipmentCellStateSelected;
            else
                cell.state = EquipmentCellStateNormal;
        }
    }
    else{
        cell.information = @"";
        cell.cost = @"";
        cell.imageURL = nil;
        cell.state = EquipmentCellStateNone;
    }
   
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(self.highlightedIndex == indexPath.row)
        return [EquipmentCell expandHeight];
    
    return [EquipmentCell height];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_bEnable)
        return;
        
    NSIndexPath* oldPath = nil;
    NSIndexPath* newPath = nil;
    EquipmentCell* oldCell = nil;
    
    // Cancel search..
    if(_tableView == self.tableViewSearch)
        [self searchDone];
    
    // hide filter..
    else if (_tableView == self.tableViewFilter)
        [self.filterView swipe:NO];

    // process..
    if(self.selectedIndex != indexPath.row &&
       self.selectedIndex >= 0)
    {
        oldCell = (EquipmentCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        
        if(oldCell.state == EquipmentCellStateHighlighted)
        {
            oldPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        }
    }

    EquipmentCell* cell = (EquipmentCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    self.selectedIndex = indexPath.row;
    self.highlightedIndex = -1;
    
    if(cell.state == EquipmentCellStateNormal)
    {
        self.highlightedIndex = indexPath.row;
        
        newPath = indexPath;
    }
    else if(cell.state == EquipmentCellStateHighlighted)
    {
        cell.state = EquipmentCellStateNormal;
        newPath = indexPath;
    }
    else if(cell.state == EquipmentCellStateSelected)
    {
        cell.state = EquipmentCellStateNormal;
    }
    
    if(oldPath)
    {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:oldPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if(newPath)
    {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        _bReloading = NO;
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    _bReloading = YES;
    
    // Cancel search..
    if(_tableView == self.tableViewSearch)
        [self searchDone];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.dragging && _tableView == self.tableViewFilter && [self.filterView isExpanded])
    {
        UIPanGestureRecognizer* gs = scrollView.panGestureRecognizer;
        CGFloat minY = CGRectGetMinY(self.tableViewFilter.frame) - 16;
        CGFloat curY = [gs locationInView:self.view].y;
        
        if(curY < minY)
            [self.filterView swipe:NO];
    }
}

#pragma mark - SwipeView Search Method

- (void)filterSearch:(NSNotification*)notification
{
    NSArray* filters = (NSArray*)[notification object];
    
    if([[EquipmentData sharedData] searchWithFilter:filters])
    {
        self.selectedIndex = -1;
        self.highlightedIndex = -1;
        
        _bReloading = YES;
        [self.tableViewFilter reloadData];
    }
}

#pragma mark - UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];

    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([[EquipmentData sharedData] searchWithString:searchBar.text])
    {
        [self.tableViewSearch reloadData];
        
        self.highlightedIndex = -1;
        self.selectedIndex = -1;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];

    if([[EquipmentData sharedData] searchWithString:searchBar.text])
    {
        [self.tableViewSearch reloadData];
        
        self.highlightedIndex = -1;
        self.selectedIndex = -1;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];

    searchBar.text = @"";
    if([[EquipmentData sharedData] searchWithString:searchBar.text])
    {
        [self.tableViewSearch reloadData];

        self.highlightedIndex = -1;
        self.selectedIndex = -1;
    }
}

#pragma mark - 

- (void)searchDone
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - download and process server data..

- (NSMutableArray*)_processFilter:(NSArray*)data withKey:(NSString*)key withDepth:(NSUInteger)depth
{
    NSMutableArray  *filters        = [[NSMutableArray alloc] init];
    NSMutableArray  *subFilters     = [[NSMutableArray alloc] init];
    NSMutableArray  *matchFilters   = [[NSMutableArray alloc] init];
    NSArray         *kinds          = nil;
    
    for(NSArray* subFilter in data)
    {
        if(subFilter.count != 3)
            continue;

        kinds = [subFilter[0] componentsSeparatedByString:@"."];
        if(kinds.count < (depth+1) || (key.length > 0 && ![subFilter[0] hasPrefix:key]))
            continue;
        
        if(kinds.count > (depth+1))
            [subFilters addObject:subFilter];
        else
            [matchFilters addObject:subFilter];
    }

    for(NSArray* subArray in matchFilters)
    {
        
        kinds = [subArray[0] componentsSeparatedByString:@"."];
        
        if(key.length > 0 && ![subArray[0] hasPrefix:key])
            continue;
        
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:subArray[0] forKey:kFilterIDKey];
        [dic setObject:subArray[1] forKey:kFilterDisplayNameKey];
        [dic setObject:subArray[2] forKey:kFilterNameKey];

        if(subFilters.count > 0)
        {
            NSMutableArray* subFilter = [self _processFilter:subFilters withKey:subArray[0] withDepth:depth+1];

            if(subFilter.count > 0)
                [dic setObject:subFilter forKey:kFilterSubFilterKey];
        }
        
        [filters addObject:dic];
    }
    
    return filters;
}

- (void)processFilter:(NSArray*)data
{
    self.filterView.filters = [self _processFilter:data withKey:nil withDepth:0];
}

- (void)processData:(NSArray*)data
{
    [[EquipmentData sharedData] initWithData:data];
    
    _bReloading = YES;
    [_tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // (...code to get new data here...)
        dispatch_async(dispatch_get_main_queue(), ^{
            //any UI refresh
            [self enableControls:YES];
            [_refresh endRefreshing];
        });
    });
}

#pragma mark - JSON Parse
- (void) parseData
{
    NSString*   parseString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    SBJSON*     JSONParser  = [[SBJSON alloc] init];
    NSArray *   data        = (NSArray *)[JSONParser objectWithString:parseString];
    
    if(_connectionStatus == ConnectionStatusDownloadFilter)
    {
        [self processFilter:data];
        
        _connectionStatus = ConnectionStatusDownloadData;
        
        [self downloadData];
    }
    else{
        [self processData:data];
    }
}

#pragma mark - download filter and data from internet..

- (void)downloadFilter
{
    NSURL           *URL            = [NSURL URLWithString:[EQUIPMENT_FILTER_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest    *request        = [NSURLRequest requestWithURL:URL];
    
    _connectionStatus               = ConnectionStatusDownloadFilter;
    
    _receivedData = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)downloadData
{
    NSURL           *URL            = [NSURL URLWithString:[EQUIPMENT_DOWNLOAD_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest    *request        = [NSURLRequest requestWithURL:URL];
    
    _connectionStatus               = ConnectionStatusDownloadData;
    
    _receivedData = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // (...code to get new data here...)
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Connection fail : %@", error.description);
            
            [self enableControls:YES];
            [_refresh endRefreshing];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet connection fail!"
                                                                message:@"Try again after network state check."
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        });
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // (...code to get new data here...)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseData];
        });
    });
}

@end

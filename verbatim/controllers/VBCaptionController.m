//
//  VBCaptionScreen.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionController.h"
#import "VBInputSourceManager.h"

@interface VBCaptionController ()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStateLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *captions;


@end

@implementation VBCaptionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)captions
{
    if (!_captions) {
        _captions = [@[] mutableCopy];
    }
    return _captions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // subscribe to channel for debug listening
    [[NSNotificationCenter defaultCenter]
     addObserverForName:VBInputSourceManagerDidFinishWithResultsNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *notification) {
         NSLog(@"Caption controller received notification: %@",notification.userInfo[@"best"]);
         self.caption = notification.userInfo[@"best"];
     }];
    
}

-(void)setCaption:(NSString *)caption
{
    _caption = caption;
    self.captionLabel.text = caption;
    [self.captions addObject:caption];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.captions count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [self.captions objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)controller
{
    return [[self alloc] init];
}

@end

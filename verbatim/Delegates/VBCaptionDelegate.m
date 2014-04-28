//
//  VBCaptionDelegate.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/28/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionDelegate.h"
#import "VBFont.h"

@implementation VBCaptionDelegate

+(instancetype)delegateWithDataSource:(VBCaptionDataSource *)dataSource;
{
    return [[self alloc] initWithDataSource:dataSource];
}

-(instancetype)initWithDataSource:(VBCaptionDataSource *)dataSource
{
    self = [super init];
    if (self) self.dataSource = dataSource;
    return self;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *caption = [self.dataSource captionForIndexPath:indexPath];
    NSDictionary *attrs = @{ NSFontAttributeName:[VBFont defaultFontWithSize:19] };
    NSAttributedString *acaption = [[NSAttributedString alloc] initWithString:caption attributes:attrs];
    CGRect rect = [acaption boundingRectWithSize:CGSizeMake(320, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return MAX(rect.size.height, 70);
}

@end

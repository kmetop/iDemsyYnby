//
//  NewsViewController.m
//  demsy
//
//  Created by yongshan ji on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DemsyWebInfoTableController.h"
#import "DemsyWebInfoDetailController.h"
#import "DemsyUtils.h"
#import "DemsyAsyncImageView.h"

@interface DemsyWebInfoTableController ()

@end

@implementation DemsyWebInfoTableController

@synthesize detailController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"新闻"; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.detailController = nil;
}

- (void)dealloc
{
    [super dealloc];
    
    [detailController release];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WebInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    
    if([indexPath row] == ([self.dataRows count])) { 
        if(cell == nil){
            cell = [[[UITableViewCell alloc] initWithFrame: CGRectMake(0, 0, 100, 20)] autorelease]; 
        }
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        //自动加载分页数据
        if(!self.noMore){
            cell.textLabel.text=[NSString stringWithFormat: @"正在加载第 %d 页...", self.pageIndex + 1]; 
            [self performSelectorInBackground:@selector(loadMore) withObject:nil];
        }else {
            cell.textLabel.text = [NSString stringWithFormat: @"共 %d 条记录!", self.dataRows.count]; 
        }
    }else{
        
        if(cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DemsyWebInfoTableCell" owner:self options:nil];
            if([nib count] > 0){
                cell = self.tableViewCell;
            }else{
                NSLog(@"failed to load DemsyWebInfoTableCell nib file!");
            }
        }

        DemsyWebInfo *dataModel = [self dataModelForRow:[indexPath row]];
            
        UILabel *titleLabel = (UILabel *)[self.tableViewCell viewWithTag:1];
        titleLabel.text = [dataModel title];
    
        UILabel *summLabel = (UILabel *)[self.tableViewCell viewWithTag:2];
        summLabel.text = [dataModel summary];
    
        UIImageView *imageView = (UIImageView *)[self.tableViewCell viewWithTag:3];
    
        NSString *cachedFile = [self getCachedFileName:dataModel.image];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:cachedFile];
        if(image != nil){
            imageView.image = image;
        }else{
            DemsyAsyncImageView *asyncImage = [[[DemsyAsyncImageView alloc] init] autorelease];
            asyncImage.cachedFile = cachedFile;
            asyncImage.imageView = imageView;
            NSURL *url = [DemsyUtils url:dataModel.image];
            [asyncImage loadImageFromURL:url];
        }
        
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row == [self.dataRows count]) { 
        //UITableViewCell *loadMoreCell=[tableView cellForRowAtIndexPath:indexPath]; 
        //loadMoreCell.textLabel.text=@"正在加载..."; 
        //[self performSelectorInBackground:@selector(loadMore) withObject:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    }else {    
        
        if(detailController == nil){
            DemsyWebInfoDetailController *controller = [[DemsyWebInfoDetailController alloc] initWithNibName:@"DemsyWebInfoDetailView" bundle:nil];
            self.detailController = controller;
            [controller release];
        }
    
        [self.navigationController pushViewController:detailController animated:YES];
    
        DemsyWebInfo *model = [self dataModelForRow:[indexPath row]];
        detailController.dataModel = model;
        detailController.title = [model title];
        [detailController.webView clearsContextBeforeDrawing];
    
        [detailController reload];
        
    } 
}

#pragma mark - override methods

- (NSString *) getCachedFileName{
    NSString *documentsDirectory =[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
    NSString* path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"webinfodata.plist"];
    
    return path;
}

- (NSURL *) getURLForPageIndex: (NSInteger) pageIndex
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%s%s/%d",DEMSY_WEB_SERVER,DEMSY_URL_WEBINFO_PLIST,pageIndex]];
}

- (DemsyWebInfo *) dataModelForRow: (NSInteger) row
{
    DemsyWebInfo *model = [[[DemsyWebInfo alloc] init] autorelease];
        
    NSDictionary *dataRow = (NSDictionary *)[self.dataRows objectAtIndex:row];
    model.ID = [dataRow objectForKey:@"id"];
    model.commentCount = [dataRow objectForKey: @"comment-count"];
    model.image = [dataRow objectForKey:@"image"];
    model.title = [dataRow objectForKey:@"title"];
    model.summary = [dataRow objectForKey:@"summary"];
    model.updated = [dataRow objectForKey:@"updated"];
    model.content = [dataRow objectForKey:@"content"];
    
    return model;
}



@end

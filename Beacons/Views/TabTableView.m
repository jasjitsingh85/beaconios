//
//  TabTableView.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabTableView.h"
#import "TabItem.h"

@interface TabTableView ()

@end

@implementation TabTableView


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)setTabItems:(NSArray *)tabItems
{
    _tabItems = tabItems;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tabSummary) {
         return self.tabItems.count + 1;
    } else {
        return self.tabItems.count + 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 22;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.tabItems.count) {
        TabItem *tabItem = self.tabItems[indexPath.row];
        NSString *CellIdentifier = [NSString stringWithFormat:@"%@", tabItem.menuItemID];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            UILabel *itemNumber = [[UILabel alloc] initWithFrame:CGRectMake(37, 0, self.view.width, 20)];
            itemNumber.font = [ThemeManager lightFontOfSize:12];
            itemNumber.textAlignment = NSTextAlignmentLeft;
            itemNumber.text = @"1";
            [cell.contentView addSubview:itemNumber];
            
            UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, self.view.width, 20)];
            itemName.font = [ThemeManager lightFontOfSize:12];
            itemName.textAlignment = NSTextAlignmentLeft;
            itemName.text = tabItem.name;
            [cell.contentView addSubview:itemName];
            
            UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 0, 40, 20)];
            itemPrice.font = [ThemeManager lightFontOfSize:12];
            itemPrice.textAlignment = NSTextAlignmentRight;
            itemPrice.text = [NSString stringWithFormat:@"$%.2f", [tabItem.price doubleValue]];
            [cell.contentView addSubview:itemPrice];
        }
        return cell;
    } else if (self.tabSummary) {
        NSString *CellIdentifier = @"SUBTOTAL";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(45, 3, self.view.width - 95, 0.5)];
            topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
            [cell.contentView addSubview:topBorder];
            
            UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(52, 8, self.view.width - 185, 20)];
            itemName.font = [ThemeManager boldFontOfSize:12];
            itemName.textAlignment = NSTextAlignmentRight;
            itemName.text = @"SUBTOTAL";
            [cell.contentView addSubview:itemName];
            
            UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 8, 40, 20)];
            itemPrice.font = [ThemeManager boldFontOfSize:12];
            itemPrice.textAlignment = NSTextAlignmentRight;
            itemPrice.text = [NSString stringWithFormat:@"$%.2f", 16.00];
            [cell.contentView addSubview:itemPrice];
        }
        return cell;
    } else {
        int itemNumber = (int)indexPath.row - (int)self.tabItems.count;
        if (itemNumber == 0) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"conveniencefee"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, self.view.width - 185, 20)];
                itemName.font = [ThemeManager lightFontOfSize:12];
                itemName.textAlignment = NSTextAlignmentRight;
                itemName.text = @"Convenience Fee";
                [cell.contentView addSubview:itemName];
                
                UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 0, 40, 20)];
                itemPrice.font = [ThemeManager lightFontOfSize:12];
                itemPrice.textAlignment = NSTextAlignmentRight;
                itemPrice.text = [NSString stringWithFormat:@"$%.2f", 0.50];
                [cell.contentView addSubview:itemPrice];
            }
            return cell;
        } else if (itemNumber == 2) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"tax"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, self.view.width - 185, 20)];
                itemName.font = [ThemeManager lightFontOfSize:12];
                itemName.textAlignment = NSTextAlignmentRight;
                itemName.text = @"Tax";
                [cell.contentView addSubview:itemName];
                
                UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 0, 40, 20)];
                itemPrice.font = [ThemeManager lightFontOfSize:12];
                itemPrice.textAlignment = NSTextAlignmentRight;
                itemPrice.text = [NSString stringWithFormat:@"$%.2f", 0.50];
                [cell.contentView addSubview:itemPrice];
            }
            return cell;
        } else if (itemNumber == 1) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"tip"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, self.view.width - 185, 20)];
                itemName.font = [ThemeManager lightFontOfSize:12];
                itemName.textAlignment = NSTextAlignmentRight;
                itemName.text = @"Tip (20%)";
                [cell.contentView addSubview:itemName];
                
                UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 0, 40, 20)];
                itemPrice.font = [ThemeManager lightFontOfSize:12];
                itemPrice.textAlignment = NSTextAlignmentRight;
                itemPrice.text = [NSString stringWithFormat:@"$%.2f", 3.20];
                [cell.contentView addSubview:itemPrice];
            }
            return cell;
        } else if (itemNumber == 3) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"total"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(45, 3, self.view.width - 95, 0.5)];
                topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
                [cell.contentView addSubview:topBorder];
                
                UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(52, 8, self.view.width - 185, 20)];
                itemName.font = [ThemeManager boldFontOfSize:12];
                itemName.textAlignment = NSTextAlignmentRight;
                itemName.text = @"TOTAL";
                [cell.contentView addSubview:itemName];
                
                UILabel *itemPrice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 8, 40, 20)];
                itemPrice.font = [ThemeManager boldFontOfSize:12];
                itemPrice.textAlignment = NSTextAlignmentRight;
                itemPrice.text = [NSString stringWithFormat:@"$%.2f", 20.20];
                [cell.contentView addSubview:itemPrice];
            }
            return cell;
        }
    }
}

@end

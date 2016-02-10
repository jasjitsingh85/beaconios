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
#import "Tab.h"
#import "ActionSheetPicker.h"

@interface TabTableView ()

@property (assign, nonatomic) int tipInt;
@property (assign, nonatomic) long tipValue;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UILabel *totalAmount;

@end

@implementation TabTableView


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView.backgroundColor = [[ThemeManager sharedTheme] lightGrayColor];
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tipInt = 8;
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

-(void)changeTip:(id)sender
{
    NSArray *percentages = [NSArray arrayWithObjects:@"10%", @"11%",@"12%",@"13%",@"14%",@"15%",@"16%",@"17%",@"18%",@"19%",@"20%",@"21%",@"22%",@"23%",@"24%",@"25%",@"26%",@"27%",@"28%",@"29%", @"30%", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Change Tip"
                                            rows:percentages
                                initialSelection:self.tipInt
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Picker: %@, Index: %ld, value: %@",
                                                 picker, (long)selectedIndex, selectedValue);
                                           self.tipInt = (int)selectedIndex;
                                           self.tipLabel.text = [NSString stringWithFormat:@"Tip (%@)", selectedValue];
                                           [self updateTipAmount];
                                           [self updateTotalAmount];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

-(float)getTipAmount
{
    return [self.tab.subtotal floatValue] * ((self.tipInt + 10)/100.);
}

-(void)updateTipAmount
{
    self.tipAmount.text = [NSString stringWithFormat:@"$%.2f", [self getTipAmount]];
}

-(void)updateTotalAmount
{
    self.totalAmount.text = [NSString stringWithFormat:@"$%.2f", [self getTotalAmount]];
}

-(float)getTotalAmount
{
    return [self.tab.subtotal floatValue] + ([self.tab.subtotal floatValue] * ((self.tipInt + 10)/100.)) + [self.tab.tax floatValue] + [self.tab.convenienceFee floatValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.tabItems.count) {
        TabItem *tabItem = self.tabItems[indexPath.row];
        NSString *CellIdentifier = [NSString stringWithFormat:@"%@ %ld", tabItem.name, (long)indexPath.row];
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
            
            UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(40, 3, self.view.width - 85, 0.5)];
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
            itemPrice.text = [NSString stringWithFormat:@"$%@", self.tab.subtotal];
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
                itemPrice.text = [NSString stringWithFormat:@"$%@", self.tab.convenienceFee];
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
                itemPrice.text = [NSString stringWithFormat:@"$%@", self.tab.tax];
                [cell.contentView addSubview:itemPrice];
            }
            return cell;
        } else if (itemNumber == 1) {
            NSString *CellIdentifier = [NSString stringWithFormat:@"tip"];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.size = CGSizeMake(50, 18);
                button.centerX = 105;
                button.y = 1;
                button.titleLabel.font = [ThemeManager regularFontOfSize:8];
                button.layer.cornerRadius = 2;
                button.layer.borderWidth = 1;
                button.layer.borderColor = [UIColor blackColor].CGColor;
                [button setTitle:@"CHANGE" forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
                [button addTarget:self action:@selector(changeTip:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button];
                
                self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, self.view.width - 185, 20)];
                self.tipLabel.font = [ThemeManager lightFontOfSize:12];
                self.tipLabel.textAlignment = NSTextAlignmentRight;
                self.tipLabel.text = @"Tip (18%)";
                [cell.contentView addSubview:self.tipLabel];
                
                self.tipAmount = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 0, 40, 20)];
                self.tipAmount.font = [ThemeManager lightFontOfSize:12];
                self.tipAmount.textAlignment = NSTextAlignmentRight;
                [self updateTipAmount];
                [cell.contentView addSubview:self.tipAmount];
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
                
                self.totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 85, 8, 40, 20)];
                self.totalAmount.font = [ThemeManager boldFontOfSize:12];
                self.totalAmount.textAlignment = NSTextAlignmentRight;
                [self updateTotalAmount];
                [cell.contentView addSubview:self.totalAmount];
            }
            return cell;
        }
    }
}

@end

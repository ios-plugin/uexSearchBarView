//
//  EUExSearchBarView.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "EUExSearchBarView.h"
#import "JSON.h"
#import "EUtility.h"
#import "SearchBarTableViewCell.h"
@interface EUExSearchBarView()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIButton *cancelBtn;
    UIColor *itemTextColor;
    UIColor *clearHistoryButtonTextColor;
}
@property(nonatomic,retain)UIImageView *bgImageView;
@property(nonatomic,retain)UITextField *searchTextField;
@property(nonatomic,retain)UITableView *searchTableView;
@property(nonatomic,retain)NSMutableArray *dataList;
@property(nonatomic,retain)UIColor *itemTextColor;
@property(nonatomic,retain)UIColor *clearHistoryButtonTextColor;

@end;
@implementation EUExSearchBarView
@synthesize dataList,itemTextColor,clearHistoryButtonTextColor;
-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
        
    }
    return self;
}
-(void)clean{
    [self close:nil];
    [super clean];
}
-(void)dealloc{
    [self close:nil];
    [super dealloc];
}
-(void)clearHistoryBtnClicked:(id)sender{
    _searchTextField.text = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"searchBarView_Plugin"];
    [self.dataList removeAllObjects];
    [_searchTableView reloadData];
    UIView *iconView = [_searchTableView viewWithTag:100];
    if (!iconView) {
        iconView = [self iconView];
        iconView.center = _searchTableView.center;
        [iconView setTag:100];
        [_searchTableView addSubview:iconView];
    }
    [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _searchTableView.tableFooterView = nil;
}
-(UIView *)iconView{
    UIView *iconView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 137.5, 275.0)] autorelease];
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.0, 137.5, 137.5)];
    [iconImg setImage:[UIImage imageNamed:@"uexSearchBarView/uexSearchBar_plugin_SearchIcon.png"]];
    [iconView addSubview:iconImg];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 143, 137.5, 45.0)];
    [titlelabel setText:@"没有搜索历史记录"];
    if (self.clearHistoryButtonTextColor) {
        [titlelabel setTextColor:self.clearHistoryButtonTextColor];
    }
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [iconView addSubview:titlelabel];
    [titlelabel release];
    return iconView;
}
-(UIView *)TableFooterView:(CGRect)rect{
    UIView *footerView = [[[UIView alloc] initWithFrame:rect] autorelease];
    [footerView setBackgroundColor:[UIColor clearColor]];
//    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5)];
//    [line setBackgroundColor:[UIColor lightGrayColor]];
//    [footerView addSubview:line];
//    [line release];
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearBtn setFrame:CGRectMake((rect.size.width-136.0)/2,5, 136.0, 41.5)];
    [clearBtn setBackgroundImage:[UIImage imageNamed:@"uexSearchBarView/uexSearchBar_plugin_clearhistory.png"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearHistoryBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:clearBtn];
    [footerView setTag:3];
    return footerView;
}
-(void)open:(NSMutableArray *)array{
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    NSDictionary *dict = [[array objectAtIndex:0] JSONValue];
    CGFloat x = [[dict objectForKey:@"x"] floatValue];
    CGFloat y = [[dict objectForKey:@"y"] floatValue];
    CGFloat width = [[dict objectForKey:@"w"] floatValue];
    CGFloat height = [[dict objectForKey:@"h"] floatValue];
    if (!self.bgImageView) {
        UIImageView *tempbgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [tempbgImageView setBackgroundColor:[UIColor whiteColor]];
        [tempbgImageView setUserInteractionEnabled:YES];
        self.bgImageView = tempbgImageView;
        [tempbgImageView release];
    }
    if (!self.searchTextField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, width-50.0, 37)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        UIImage *image = [UIImage imageNamed:@"uexSearchBarView/uexSearchBar_plugin_Searchbg.png"];
        [textField setBackground:image];
        self.searchTextField = textField;
        [textField setText:@""];
        textField.returnKeyType = UIReturnKeySearch;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentCenter;
        [textField release];
    }
    [self.bgImageView addSubview:self.searchTextField];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [cancelBtn setFrame:CGRectMake(width-45, 5, 45, 37)];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgImageView addSubview:cancelBtn];
    
    if (!self.dataList) {
        self.dataList = [NSMutableArray arrayWithCapacity:1];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *defaultsArray = (NSMutableArray *)[defaults objectForKey:@"searchBarView_Plugin"];
    [self.dataList addObjectsFromArray:defaultsArray];
    
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 37.0, width, height-37) style:UITableViewStylePlain];
        [_searchTableView setDelegate:self];
        [_searchTableView setDataSource:self];
        if ([self.dataList count]>0) {
            _searchTableView.tableFooterView = [self TableFooterView:CGRectMake(0, 0, _searchTableView.frame.size.width, 51.5)];
            [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            UIView *iconImg = (UIView *)[_searchTableView viewWithTag:100];
            if (iconImg) {
                [iconImg removeFromSuperview];
            }
        }else{
            UIView *iconView = [_searchTableView viewWithTag:100];
            if (!iconView) {
                iconView = [self iconView];
                iconView.center = _searchTableView.center;
                [iconView setTag:100];
                [_searchTableView addSubview:iconView];
            }
            [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
    }
    [self.bgImageView addSubview:_searchTableView];
    
    [EUtility brwView:self.meBrwView addSubview:self.bgImageView];
}
-(void)cancelBtnClicked:(id)sender{
    [_searchTextField resignFirstResponder];
    _searchTextField.text = @"";
}
-(void)close:(NSMutableArray *)array{
    if (self.bgImageView) {
        [self.bgImageView removeFromSuperview];
        self.bgImageView = nil;
    }
    if (self.searchTextField) {
        [self.searchTextField removeFromSuperview];
        [_searchTextField release];
        _searchTextField = nil;
    }
    if (_searchTableView) {
        [_searchTableView release];
        _searchTableView = nil;
    }
    if (self.dataList) {
        self.dataList = nil;
    }
    if (self.itemTextColor) {
        self.itemTextColor = nil;
    }
    if (self.clearHistoryButtonTextColor) {
        self.clearHistoryButtonTextColor = nil;
    }
}
-(void)clearHistory:(NSMutableArray *)array{
    [self clearHistoryBtnClicked:nil];
}
-(void)setViewStyle:(NSMutableArray *)array{
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    NSString *jsonStr = [array objectAtIndex:0];
    NSDictionary *dict = [jsonStr JSONValue];
    NSDictionary *searchBarDict = [dict objectForKey:@"searchBar"];
    NSString *placehoderText = [searchBarDict objectForKey:@"placehoderText"];
    _searchTextField.placeholder = placehoderText;
    NSString *textColorStr = [searchBarDict objectForKey:@"textColor"];
    _searchTextField.textColor = [EUtility ColorFromString:textColorStr];
    NSString *inputBgColorStr = [searchBarDict objectForKey:@"inputBgColor"];
    _searchTextField.backgroundColor = [EUtility ColorFromString:inputBgColorStr];

    NSDictionary *listViewDict = [dict objectForKey:@"listView"];
    NSString *bgColorText = [listViewDict objectForKey:@"bgColor"];
    _searchTableView.backgroundColor = [EUtility ColorFromString:bgColorText];
    NSString *separatorLineColorText = [listViewDict objectForKey:@"separatorLineColor"];
    _searchTableView.separatorColor = [EUtility ColorFromString:separatorLineColorText];
    NSString *itemTextColorText = [listViewDict objectForKey:@"itemTextColor"];
    self.itemTextColor =[EUtility ColorFromString:itemTextColorText];
    NSString *clearHistoryButtonTextColorText = [listViewDict objectForKey:@"clearHistoryButtonTextColor"];
    self.clearHistoryButtonTextColor =[EUtility ColorFromString:clearHistoryButtonTextColorText];
    [_searchTableView reloadData];
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentLeft;
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField setTextAlignment:NSTextAlignmentCenter];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField.text isEqualToString:@""]) {
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSArray *array = (NSArray *)[defaults objectForKey:@"searchBarView_Plugin"];
    NSMutableArray *defaultsArray = [NSMutableArray arrayWithArray:array];
    if ([defaultsArray containsObject:textField.text]) {
        [defaultsArray removeObject:textField.text];
    }else{
        
    }
    [defaultsArray insertObject:textField.text atIndex:0];
    NSArray *saveArray = [NSArray arrayWithArray:defaultsArray];
    [defaults setObject:saveArray forKey:@"searchBarView_Plugin"];
    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:saveArray];
    if ([self.dataList count]>0) {
        UIView *iconImg = (UIView *)[_searchTableView viewWithTag:100];
        if (iconImg) {
            [iconImg removeFromSuperview];
        }
        _searchTableView.tableFooterView = [self TableFooterView:CGRectMake(0, 0, _searchTableView.frame.size.width, 51.5)];
        [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_searchTableView setSeparatorColor:[EUtility ColorFromString:@"#666666"]];
    }
    [_searchTableView reloadData];
    return YES;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.dataList count]>0) {
        return [self.dataList count];
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    SearchBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SearchBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease] ;
    }
    cell.textLabel.text = [self.dataList objectAtIndex:indexPath.row];
    if (self.itemTextColor) {
        cell.textLabel.textColor = self.itemTextColor;
    }
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 41.5;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *jsonStr = [NSString stringWithFormat:@"{\"index\":\"%d\",\"keyword\":\"%@\"}",indexPath.row,[self.dataList objectAtIndex:indexPath.row]];
    NSString *json = [NSString stringWithFormat:@"uexSearchBarView.onItemClick('%@')",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:json];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.dataList removeObjectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *saveArray = [NSArray arrayWithArray:self.dataList];
    [defaults setObject:saveArray forKey:@"searchBarView_Plugin"];
    
    NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
    [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
    if ([self.dataList count] == 0) {
        UIView *iconView = [self iconView];
        iconView.center = _searchTableView.center;
        [iconView setTag:100];
        [_searchTableView addSubview:iconView];
        [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _searchTableView.tableFooterView = nil;
    }
}
@end

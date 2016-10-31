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
#import "ColorConvert.h"


@interface EUExSearchBarView()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIButton *cancelBtn;
    UIColor *itemTextColor;
    UIColor *clearHistoryButtonTextColor;
}
@property(nonatomic,retain)UIImageView *bgImageView;
@property(nonatomic,retain)UITextField *searchTextField;
@property(nonatomic,retain)UITextField *suggestionTextField;
@property(nonatomic,retain)UITableView *searchTableView;
@property(nonatomic,retain)NSMutableArray *dataList;
@property(nonatomic,retain)NSArray *sourceList;
@property(nonatomic,retain)NSMutableArray *suggestionList;
@property(nonatomic,retain)UIColor *itemTextColor;
@property(nonatomic,retain)UIColor *clearHistoryButtonTextColor;
@property(nonatomic,assign)NSUInteger maxAllowRows;
@property(nonatomic,assign)BOOL isSuggestion;
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
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 137.5, 275.0)] ;
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.0, 137.5, 137.5)];
    UIImage *image = [self imagesNamedFromCustomBundle:@"uexSearchBar_plugin_SearchIcon"];
    [iconImg setImage:image];
    
    [iconView addSubview:iconImg];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 143, 137.5, 45.0)];
    [titlelabel setText:@"没有搜索历史记录"];
    if (self.clearHistoryButtonTextColor) {
        [titlelabel setTextColor:self.clearHistoryButtonTextColor];
    }
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [iconView addSubview:titlelabel];
    
    return iconView;
}
-(UIView *)TableFooterView:(CGRect)rect{
    UIView *footerView = [[UIView alloc] initWithFrame:rect];
    [footerView setBackgroundColor:[UIColor clearColor]];
    //    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5)];
    //    [line setBackgroundColor:[UIColor lightGrayColor]];
    //    [footerView addSubview:line];
    //    [line release];
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearBtn setFrame:CGRectMake((rect.size.width-136.0)/2,5, 136.0, 41.5)];
     UIImage *image = [self imagesNamedFromCustomBundle:@"uexSearchBar_plugin_clearhistory"];
    [clearBtn setBackgroundImage:image forState:UIControlStateNormal];
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
    self.isSuggestion = NO;
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
        
    }
    if (!self.searchTextField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, width-50.0, 37)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        UIImage *image = [self imagesNamedFromCustomBundle:@"uexSearchBar_plugin_Searchbg"];
        [textField setBackground:image];
        self.searchTextField = textField;
        [textField setText:@""];
        textField.returnKeyType = UIReturnKeySearch;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentCenter;
        
    }
    if (dict[@"searchBar"]) {
        NSDictionary *searchBarDict = [dict objectForKey:@"searchBar"];
        NSString *placehoderText = [searchBarDict objectForKey:@"placehoderText"];
        _searchTextField.placeholder = placehoderText;
        NSString *textColorStr = [searchBarDict objectForKey:@"textColor"];
        _searchTextField.textColor = [ColorConvert returnUIColorFromHex:textColorStr];
        NSString *inputBgColorStr = [searchBarDict objectForKey:@"inputBgColor"];
        _searchTextField.backgroundColor = [ColorConvert returnUIColorFromHex:inputBgColorStr];
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
    if (dict[@"listView"]) {
        NSDictionary *listViewDict = [dict objectForKey:@"listView"];
        NSString *bgColorText = [listViewDict objectForKey:@"bgColor"];
        _searchTableView.backgroundColor = [ColorConvert returnUIColorFromHex:bgColorText];
        NSString *separatorLineColorText = [listViewDict objectForKey:@"separatorLineColor"];
        _searchTableView.separatorColor = [ColorConvert returnUIColorFromHex:separatorLineColorText];
        NSString *itemTextColorText = [listViewDict objectForKey:@"itemTextColor"];
        self.itemTextColor =[ColorConvert returnUIColorFromHex:itemTextColorText];
        NSString *clearHistoryButtonTextColorText = [listViewDict objectForKey:@"clearHistoryButtonTextColor"];
        self.clearHistoryButtonTextColor =[ColorConvert returnUIColorFromHex:clearHistoryButtonTextColorText];
    }
    [self.bgImageView addSubview:_searchTableView];
    
    [EUtility brwView:self.meBrwView addSubview:self.bgImageView];
}
-(void)openWithSuggestion:(NSMutableArray *)array{
    
    if ([array count] ==0) {
        NSLog(@"paragms is error!!");
        return;
    }
    self.isSuggestion = YES;
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
        
    }
    if (!self.suggestionTextField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, width-50.0, 37)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.delegate = self;
        UIImage *image = [self imagesNamedFromCustomBundle:@"uexSearchBar_plugin_Searchbg"];
        [textField setBackground:image];
        self.suggestionTextField = textField;
        [textField setText:@""];
        textField.returnKeyType = UIReturnKeySearch;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentCenter;
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:self.suggestionTextField];
    if (dict[@"searchBar"] &&self.searchTextField) {
        NSDictionary *searchBarDict = [dict objectForKey:@"searchBar"];
        NSString *placehoderText = [searchBarDict objectForKey:@"placehoderText"];
        self.suggestionTextField.placeholder = placehoderText;
        NSString *textColorStr = [searchBarDict objectForKey:@"textColor"];
        self.suggestionTextField.textColor = [ColorConvert returnUIColorFromHex:textColorStr];
        NSString *inputBgColorStr = [searchBarDict objectForKey:@"inputBgColor"];
        self.suggestionTextField.backgroundColor = [ColorConvert returnUIColorFromHex:inputBgColorStr];
    }
    
    [self.bgImageView addSubview:self.suggestionTextField];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [cancelBtn setFrame:CGRectMake(width-45, 5, 45, 37)];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgImageView addSubview:cancelBtn];
    if (!self.suggestionList) {
        self.suggestionList = [NSMutableArray array];
    }
    if (dict[@"suggestionCount"]) {
        self.maxAllowRows =  [[NSString stringWithFormat:@"%@",dict[@"suggestionCount"]] integerValue];
    }
    if (dict[@"suggestionList"]) {
        NSArray *suggestionArr = dict[@"suggestionList"];
        if (self.maxAllowRows != 0) {
            NSMutableArray *arr = [NSMutableArray array];
            for (int i =0; i<self.maxAllowRows; i++) {
                [arr addObject:suggestionArr[i]];
            }
            self.sourceList = arr;
        }else{
            self.sourceList = suggestionArr;
        }
        
    }
    
   
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 37.0, width, height-37) style:UITableViewStylePlain];
        [_searchTableView setDelegate:self];
        [_searchTableView setDataSource:self];
        if ([self.suggestionList count]>0) {
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
    if (dict[@"listView"] &&_searchTableView) {
        NSDictionary *listViewDict = [dict objectForKey:@"listView"];
        NSString *bgColorText = [listViewDict objectForKey:@"bgColor"];
        _searchTableView.backgroundColor = [ColorConvert returnUIColorFromHex:bgColorText];
        NSString *separatorLineColorText = [listViewDict objectForKey:@"separatorLineColor"];
        _searchTableView.separatorColor = [ColorConvert returnUIColorFromHex:separatorLineColorText];
        NSString *itemTextColorText = [listViewDict objectForKey:@"itemTextColor"];
        self.itemTextColor =[ColorConvert returnUIColorFromHex:itemTextColorText];
        NSString *clearHistoryButtonTextColorText = [listViewDict objectForKey:@"clearHistoryButtonTextColor"];
        self.clearHistoryButtonTextColor =[ColorConvert returnUIColorFromHex:clearHistoryButtonTextColorText];
    }
    [self.bgImageView addSubview:_searchTableView];
    
    [EUtility brwView:self.meBrwView addSubview:self.bgImageView];
}
- (void)textFieldTextDidChange{
    [self.suggestionList removeAllObjects];
    NSMutableArray *showList = [NSMutableArray array];
    NSLog(@"%@",self.suggestionTextField.text);
    for (NSString *source in self.sourceList) {
        if ([source containsString:self.suggestionTextField.text]) {
            [showList addObject:source];
        }
    }
    self.suggestionList = showList;
    if ([self.suggestionList count]>0) {
        UIView *iconImg = (UIView *)[_searchTableView viewWithTag:100];
        if (iconImg) {
            [iconImg removeFromSuperview];
        }
        _searchTableView.tableFooterView = [self TableFooterView:CGRectMake(0, 0, _searchTableView.frame.size.width, 51.5)];
        [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_searchTableView setSeparatorColor:[ColorConvert returnUIColorFromHex:@"#666666"]];
    }
    [_searchTableView reloadData];
}
-(void)cancelBtnClicked:(id)sender{
    if (_isSuggestion) {
        [_suggestionTextField resignFirstResponder];
        _suggestionTextField.text = @"";
    }else{
        [_searchTextField resignFirstResponder];
        _searchTextField.text = @"";
    }
    
}
-(void)close:(NSMutableArray *)array{
    if (self.bgImageView) {
        [self.bgImageView removeFromSuperview];
        self.bgImageView = nil;
    }
    if (self.searchTextField) {
        [self.searchTextField removeFromSuperview];
        _searchTextField = nil;
    }
    if (self.suggestionTextField) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.suggestionTextField];
        [self.suggestionTextField removeFromSuperview];
        self.suggestionTextField = nil;
    }
    if (self.suggestionList) {
        [self.suggestionList removeAllObjects];
        self.suggestionList = nil;
    }
    if (_searchTableView) {
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
    if (self.isSuggestion) {
        NSString *jsonStr1=[NSString stringWithFormat:@"uexSearchBarView.onSearch('%@')",[@{@"keyword":textField.text} JSONRepresentation]];
        [EUtility brwView:self.meBrwView evaluateScript:jsonStr1];
        
    }else{
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
            [_searchTableView setSeparatorColor:[ColorConvert returnUIColorFromHex:@"#666666"]];
        }
        [_searchTableView reloadData];
        NSMutableDictionary *result=[[NSMutableDictionary alloc]init];
        [result setObject:[self.dataList firstObject]forKey:@"keyword"];
        NSError *error=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:result
                                                     options:NSJSONReadingAllowFragments
                                                       error:&error];
        NSString *jsonStr1=[NSString stringWithFormat:@"uexSearchBarView.onSearch('%@')",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
        [EUtility brwView:self.meBrwView evaluateScript:jsonStr1];
    }
    
    
    
    
    return YES;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSuggestion) {
        if ([self.suggestionList count]>0) {
            return [self.suggestionList count];
        }
        
    }else{
        if ([self.dataList count]>0) {
            return [self.dataList count];
        }
    }
    
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    SearchBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]  ;
    }
    if (_isSuggestion) {
       cell.textLabel.text = [self.suggestionList objectAtIndex:indexPath.row];
    } else {
       cell.textLabel.text = [self.dataList objectAtIndex:indexPath.row];
    }
    
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
    NSString *jsonStr = nil;
    if (_isSuggestion) {
        self.suggestionTextField.text = [self.suggestionList objectAtIndex:indexPath.row];
         jsonStr = [NSString stringWithFormat:@"{\"index\":\"%ld\",\"keyword\":\"%@\"}",(long)indexPath.row,[self.suggestionList objectAtIndex:indexPath.row]];
    } else {
        jsonStr = [NSString stringWithFormat:@"{\"index\":\"%ld\",\"keyword\":\"%@\"}",(long)indexPath.row,[self.dataList objectAtIndex:indexPath.row]];
    }
   
    NSString *json = [NSString stringWithFormat:@"uexSearchBarView.onItemClick('%@')",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:json];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSuggestion) {
        [self.suggestionList removeObjectAtIndex:indexPath.row];
        NSArray *array = [NSArray arrayWithObjects:indexPath, nil];
        [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
        if ([self.suggestionList count] == 0) {
            UIView *iconView = [self iconView];
            iconView.center = _searchTableView.center;
            [iconView setTag:100];
            [_searchTableView addSubview:iconView];
            [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            _searchTableView.tableFooterView = nil;
        }

    } else {
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
    
}
- (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName
{
    
    NSBundle *bundle = [EUtility bundleForPlugin:@"uexSearchBarView"];
    NSString *img_path = [[bundle resourcePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imgName]];
    return [UIImage imageWithContentsOfFile:img_path];
}
@end

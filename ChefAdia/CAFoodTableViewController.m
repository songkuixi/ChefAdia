//
//  CAFoodTableViewController.m
//  ChefAdia
//
//  Created by 宋 奎熹 on 2016/11/8.
//  Copyright © 2016年 宋 奎熹. All rights reserved.
//

#import "CAFoodTableViewController.h"
#import "CAFoodTableViewCell.h"
#import "CAFoodManager.h"
#import "CAFoodMenu.h"
#import "Utilities.h"
#import "CAFoodDetailTableViewController.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

@interface CAFoodTableViewController (){
    NSString *fontName;
}

@end

@implementation CAFoodTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    fontName = [Utilities getFont];
    
    //加载食物大类
    _menuArr = [[NSMutableArray alloc] init];
    [self loadMenu];
    
    _backgroundView.image = [UIImage imageNamed:@"FOOD_TITLE"];
    _menuLabel.font = [UIFont fontWithName:fontName size:15];
    _name1Label.font = [UIFont fontWithName:[Utilities getBoldFont] size:40];
    _name2Label.font = [UIFont fontWithName:fontName size:20];
    _contactLabel.font = [UIFont fontWithName:fontName size:15];
    
    _name1Label.text = @"KRAYC'S";
    _name2Label.text = @"CHINESE FOOD";
    _contactLabel.text = @"XIANLIN AVENUE\n10:00 A.M. ~ 22:00 P.M.";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadMenu{

    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/plain",
                                                         @"text/html",
                                                         nil];
    [manager GET:@"http://139.196.179.145/ChefAdia-1.0-SNAPSHOT/getMenu"
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
             for(NSDictionary *dict in (NSArray *)responseObject){
                 CAFoodMenu *tmpMenu = [[CAFoodMenu alloc] initWithID:[[dict valueForKey:@"id"] intValue]
                                                               andPic:[dict valueForKey:@"picture"]
                                                              andName:[dict valueForKey:@"name"]
                                                               andNum:[[dict valueForKey:@"dishnum"] intValue]];
                 [weakSelf.menuArr addObject:[tmpMenu copy]];
             }
             [weakSelf.tableView reloadData];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
         }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [_menuArr count];
        default:
            return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        //注册 nib 的方法，来使用.xib 的cell
        static NSString *CellIdentifier = @"CAFoodTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"CAFoodTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        CAFoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //配置 cell 细节
        CAFoodMenu *item = _menuArr[indexPath.row];
        cell.nameLabel.text = [item name];
        cell.numberLabel.text = [NSString stringWithFormat:@"%d SELECTION%s", [item number], [item number] <= 1 ? "" : "S"];
        
        //tmp
        [cell.bgView setImage:[UIImage imageNamed:@"FOOD_TITLE"]];
//        [cell.bgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"FOOD_%@",item.name]]];
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        [self performSegueWithIdentifier:@"detailSegue" sender:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 250;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailSegue"]){
        CAFoodDetailTableViewController *caFoodDetailTableViewController = (CAFoodDetailTableViewController *)[segue destinationViewController];
        NSIndexPath *path = (NSIndexPath *)sender;
        CAFoodMenu *caFoodMenu = (CAFoodMenu *)_menuArr[path.row];
        [caFoodDetailTableViewController setFoodType:caFoodMenu];
    }
}

@end

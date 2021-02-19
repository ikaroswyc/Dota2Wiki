//
//  MasterTableViewController.m
//  Dota
//
//  Created by Yuchen Wang on 2021/2/18.
//

#define kAPI_KEY @"485A05D946DD48F21C204FCCCAA5C8A2"

#import "MasterTableViewController.h"
#import "DetailTableViewController.h"
#import "HeroTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface MasterTableViewController ()
{
    NSString *docPath;
}
@property (nonatomic, strong) NSArray *heroList;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDictionary *heroesDetail;
@end

@implementation MasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    self.heroList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Heros" ofType:@"plist"]];
    self.title = @"Dota 2 Heropedia";
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [self fetchHeroerList];
//    [self fetchHeroesDetailData];
//    [self fetchHeroAbilityData];
    [self setupDataSource];
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TODETAIL"]) {
        DetailTableViewController *detailVC = [segue destinationViewController];
//        detailVC.hero = self.heroList[self.tableView.indexPathForSelectedRow.row];
        
        NSString *selectedHero = [self.heroList[self.tableView.indexPathForSelectedRow.row][@"name"] stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""];
        detailVC.heroName = selectedHero;
    }
}
- (void)fetchHeroesDetailData {
    NSURL *apiURL = [NSURL URLWithString:@"http://www.dota2.com/jsfeed/heropickerdata"];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:apiURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.heroesDetail = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        
        [self.heroesDetail writeToFile:[docPath stringByAppendingPathComponent:@"DetailData.plist"] atomically:YES];
        
        
    }];
    
    [dataTask resume];
}

- (void)fetchHeroerList {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=%@&language=zh_cn", kAPI_KEY]];
    

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:apiURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        self.heroList = json[@"result"][@"heroes"];
        [self.heroList writeToFile:[docPath stringByAppendingPathComponent:@"ListData.plist"] atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        
    }];
    
    [dataTask resume];

}

- (void)fetchHeroAbilityData {
    NSURL *apiURL = [NSURL URLWithString:@"http://www.dota2.com/jsfeed/abilitydata"];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:apiURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        NSDictionary *abilityData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"abilitydata"];
        

        [abilityData writeToFile:[docPath stringByAppendingPathComponent:@"AbilityData.plist"] atomically:YES];
        
    }];
    
    [dataTask resume];
}

- (void)setupDataSource {
    if ([[NSFileManager defaultManager]fileExistsAtPath:[docPath stringByAppendingPathComponent:@"ListData.plist"]]) {
        self.heroList = [NSArray arrayWithContentsOfFile:[docPath stringByAppendingPathComponent:@"ListData.plist"]];
    }else {
        [self fetchHeroerList];
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:[docPath stringByAppendingPathComponent:@"DetailData.plist"]]) {
        self.heroesDetail = [NSDictionary dictionaryWithContentsOfFile :[docPath stringByAppendingPathComponent:@"DetailData.plist"]];
    }else {
        [self fetchHeroesDetailData];
    }

    if ([[NSFileManager defaultManager]fileExistsAtPath:[docPath stringByAppendingPathComponent:@"AbilityData.plist"]]) {
//        self.heroList = [NSArray arrayWithContentsOfFile:[docPath stringByAppendingPathComponent:@"ListData.plist"]];
    }else {
        [self fetchHeroAbilityData];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.heroList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeroTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    cell.textLabel.text = self.heroList[indexPath.row][@"name"];
    
//    NSString *name = [[self.heroList[indexPath.row][@"name"] lowercaseString] stringByAppendingString:@"_hphover.png"];
//    cell.iconImageView.image = [UIImage imageNamed:name];
//    cell.nameLabel.text = self.heroList[indexPath.row][@"name"];
    
    NSString *sourceName = self.heroList[indexPath.row][@"name"];
    NSString *realName = [sourceName stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString:@""];
    
    NSString *urlString = [NSString stringWithFormat:@"http://cdn.dota2.com.cn/apps/dota2/images/heroes/%@_full.png",realName];
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    cell.nameLabel.text = self.heroList[indexPath.row][@"localized_name"];
    cell.typeLabel.text = self.heroesDetail[realName][@"atk_l"];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 60;
//}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

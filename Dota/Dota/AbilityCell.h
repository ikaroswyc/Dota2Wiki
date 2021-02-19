//
//  AbilityCell.h
//  Dota
//
//  Created by Yuchen Wang on 2021/2/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AbilityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *abilityImageView;
@property (weak, nonatomic) IBOutlet UILabel *abilityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *abilityDetailLabel;

@end

NS_ASSUME_NONNULL_END

//
//  jfgConfigManager.m
//  JiafeigouiOS
//
//  Created by yl on 2017/7/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "jfgConfigManager.h"
#import "OemManager.h"
#import "CommonMethod.h"

@implementation jfgConfigManager

+(NSArray <NSArray <AddDevConfigModel *>*>*)getAllDevModel
{
    NSString *configPath =  [[NSBundle mainBundle] pathForResource:@"jfgConfig_addDev" ofType:@"plist"];
    
    NSDictionary *mainDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
    NSArray *addDevs = [mainDict objectForKey:@"addDevList"];
    NSMutableArray *modelList = [NSMutableArray new];
    for (NSArray *subArr in addDevs) {
        
        NSMutableArray *subModels = [NSMutableArray new];
        for (NSDictionary *dic in subArr) {
            
            AddDevConfigModel *model = [AddDevConfigModel new];
            model.iconName = dic[@"icon"];
            model.title = dic[@"title"];
            model.gifName = dic[@"gif"];
            model.osList = dic[@"osList"];
            model.typeMark = dic[@"typeMark"];
            model.userActionTitle = dic[@"userActionTitle"];
            model.ledState = dic[@"ledState"];
            model.ledTitle = dic[@"ledTitle"];
            model.oems = dic[@"oem"];
            model.cidPrefixList = dic[@"cidPrefixList"];
            model.homeIconName = dic[@"home_icon"];
            model.homeDisableIconName = dic[@"home_diable_icon"];
            [subModels addObject:model];
            
        }
        [modelList addObject:subModels];
        
    }
    return modelList;
}

+(NSArray <NSArray <AddDevConfigModel *>*>*)getAddDevModel
{
    NSString *configPath =  [[NSBundle mainBundle] pathForResource:@"jfgConfig_addDev" ofType:@"plist"];
    
    NSDictionary *mainDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
    NSArray *addDevs = [mainDict objectForKey:@"addDevList"];
    NSMutableArray *modelList = [NSMutableArray new];
    for (NSArray *subArr in addDevs) {
        
        NSMutableArray *subModels = [NSMutableArray new];
        for (NSDictionary *dic in subArr) {
            
            AddDevConfigModel *model = [AddDevConfigModel new];
            model.iconName = dic[@"icon"];
            model.title = dic[@"title"];
            model.gifName = dic[@"gif"];
            model.osList = dic[@"osList"];
            model.typeMark = dic[@"typeMark"];
            model.userActionTitle = dic[@"userActionTitle"];
            model.ledState = dic[@"ledState"];
            model.ledTitle = dic[@"ledTitle"];
            model.oems = dic[@"oem"];
            model.cidPrefixList = dic[@"cidPrefixList"];
            model.homeIconName = dic[@"home_icon"];
            model.homeDisableIconName = dic[@"home_diable_icon"];
            
            //判断此厂家是否支持显示此添加类型
            if ([OemManager oemType] == oemTypeDoby) {
                
                for (NSString *oem in model.oems) {
                    if ([oem isEqualToString:@"doby"]) {
                        [subModels addObject:model];
                        break;
                    }
                }
                
            }else{
                
                for (NSString *oem in model.oems) {
                    if ([oem isEqualToString:@"cylan"]) {
                        [subModels addObject:model];
                        break;
                    }
                }
            }
        }
        [modelList addObject:subModels];
        
    }
    return modelList;
}


+(NSArray <PorwerWarnModel *> *)getPoewerModel
{
    NSString *configPath =  [[NSBundle mainBundle] pathForResource:@"jfgConfig" ofType:@"plist"];
    NSDictionary *mainDict = [[NSDictionary alloc]initWithContentsOfFile:configPath];
    NSArray *addDevs = [mainDict objectForKey:@"PorwerTip"];
    NSMutableArray *modelList = [NSMutableArray new];
    for (NSDictionary *dict in addDevs) {
        
        NSArray *oslist = dict[@"osList"];
        NSNumber *porw = dict[@"porwer"];
        PorwerWarnModel *model = [[PorwerWarnModel alloc]init];
        model.osList = [[NSArray alloc]initWithArray:oslist];
        model.porwer = porw;
        [modelList addObject:model];
    }
    return modelList;
}


+(BOOL)devIsDoorBellForPid:(NSString *)pid
{
    BOOL isDoorBell = NO;
    NSArray *arr = [self getAllDevModel];
    for (NSArray *subArr in arr) {
        
        for (AddDevConfigModel *model in subArr) {
            
            for (NSNumber *os in model.osList) {
                
                if ([os integerValue] == [pid integerValue]) {
                    
                    if ([model.typeMark integerValue] == 3 ||
                        [model.typeMark integerValue] == 7 ||
                        [model.typeMark integerValue] == 6) {
                        isDoorBell = YES;
                        break;
                    }
                }
                
            }
            if (isDoorBell) {
                break;
            }
            
        }
        if (isDoorBell) {
            break;
        }
    }
    return isDoorBell;
}

+(BOOL)devIsCatEyeForPid:(NSString *)pid
{
    BOOL isDoorBell = NO;
    NSArray *arr = [self getAllDevModel];
    for (NSArray *subArr in arr) {
        
        for (AddDevConfigModel *model in subArr) {
            
            for (NSNumber *os in model.osList) {
                
                if ([os integerValue] == [pid integerValue]) {
                    
                    if ([model.typeMark integerValue] == 6) {
                        isDoorBell = YES;
                        break;
                    }
                }
                
            }
            if (isDoorBell) {
                break;
            }
            
        }
        if (isDoorBell) {
            break;
        }
    }
    return isDoorBell;
}

+(BOOL)devIsSupportSafetyForPid:(NSString *)pid
{
    //不支持安全防护功能os列表
    NSArray *osList = @[@6,@8,@11,@21,@25,@27,@44,@46,@1089,@1093,@1160,@1344,@1345];
    BOOL isSupport = YES;
    for (NSNumber *os in osList) {
        if ([os integerValue] == [pid integerValue]) {
            isSupport = NO;
            break;
        }
    }
    return isSupport;
}

+(BOOL)isAPModel
{
    BOOL isAPModel = NO;
    NSString *currentWifi = [CommonMethod currentConnecttedWifi];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSArray *aps = [infoDictionary objectForKey:@"Jfgsdk_ap_prefix"];
    if ([aps isKindOfClass:[NSArray class]]) {
        for (NSString *ap in aps) {
            if ([ap isKindOfClass:[NSString class]]) {
                if ([[currentWifi lowercaseString] hasPrefix:[ap lowercaseString]]) {
                    isAPModel = YES;
                    break;
                }
            }
        }
    }
    return isAPModel;
}

@end


@implementation AddDevConfigModel

@end

@implementation PorwerWarnModel

@end

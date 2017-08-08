//
//  Pano720PhotoModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720PhotoModel.h"
#import "FileManager.h"

@interface Pano720PhotoModel()

@property (nonatomic, assign) FileType panoFileType;
@property (nonatomic, copy) NSString *videoDurationStr;

@property (nonatomic, copy) NSString *thumbNailFilePath;
@property (nonatomic, copy) NSString *filePath;


@end

@implementation Pano720PhotoModel

- (FileType)panoFileType
{
    if ([self.fileName hasSuffix:@".jpg"])
    {
        _panoFileType = FileTypePhoto;
    }
    else
    {
        _panoFileType = FileTypeVideo;
    }
    
    return _panoFileType;
}

- (NSString *)filePath
{
    if (_filePath == nil)
    {
        _filePath = [NSString stringWithFormat:@"%@/%@",[FileManager jfgPano720PhotoDirPath:self.cid], self.fileName];
    }
    
    return _filePath;
}

- (NSString *)thumbNailFilePath
{
    if (_thumbNailFilePath == nil)
    {
        _thumbNailFilePath = [NSString stringWithFormat:@"%@/%@.thumb", [FileManager jfgPano720PhotoThumbnailsPath:self.cid], [self.fileName stringByDeletingPathExtension]];
    }
    
    return _thumbNailFilePath;
}

- (long long)fileTime
{
    long long resutTime = 0;
    if (self.fileName != nil && ![self.fileName isEqualToString:@""])
    {
        if (self.fileName.length >= 10)
        {
            resutTime = [[self.fileName substringToIndex:10] longLongValue];
        }
    }
    return resutTime;
}

- (NSString *)videoDurationStr
{
    
    if (self.fileName != nil && ![self.fileName isEqualToString:@""])
    {
        NSString *timeString = [self.fileName stringByDeletingPathExtension];
        
        if ([timeString containsString:@"_"])
        {
            NSArray *elements = [timeString componentsSeparatedByString:@"_"];
            if (elements.count >= 2)
            {
                int duraton = [[elements objectAtIndex:1] intValue];
                int minute = duraton/60;
                int second = duraton%60;
                
                _videoDurationStr = [NSString stringWithFormat:@"%0.2d:%0.2d",minute, second];
            }
        }
    }
    
    return _videoDurationStr;
}

@end

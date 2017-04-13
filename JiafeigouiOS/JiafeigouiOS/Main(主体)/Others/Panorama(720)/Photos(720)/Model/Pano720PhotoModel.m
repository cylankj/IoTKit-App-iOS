//
//  Pano720PhotoModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720PhotoModel.h"
#import "FileManager.h"

@implementation Pano720PhotoModel

- (FileType)fileType
{
    if ([self.fileName hasSuffix:@".jpg"])
    {
        _fileType = FileTypePhoto;
    }
    else
    {
        _fileType = FileTypeVideo;
    }
    
    return _fileType;
}

- (NSString *)filePath
{
    if (_filePath == nil)
    {
        _filePath = [NSString stringWithFormat:@"%@/%@",[FileManager jfgPano720PhotoDirPath:self.cid], self.fileName];
    }
    
    return _filePath;
}

@end

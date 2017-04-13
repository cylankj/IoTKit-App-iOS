//
//  FTBase64.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTBase64 : NSObject

NSData * b64_encode( NSData * data );
NSData * b64_decode( NSData * data );
void decodeblock( unsigned char in[4], unsigned char out[3] );

@end

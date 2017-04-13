//
//  FTBase64.m
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FTBase64.h"

@implementation FTBase64

/*
 ** Translation Table as described in RFC1113
 */
static const char cb64[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/*
 ** Translation Table to decode (created by author)
 */
static const char cd64[]="|$$$}rstuvwxyz{$$$$$$$>?@ABCDEFGHIJKLMNOPQRSTUVW$$$$$$XYZ[\\]^_`abcdefghijklmnopq";

/*
 ** encodeblock
 **
 ** encode 3 8-bit binary bytes as 4 '6-bit' characters
 */
static void encodeblock( unsigned char in[3], unsigned char out[4], int len )
{
    out[0] = cb64[ in[0] >> 2 ];
    out[1] = cb64[ ((in[0] & 0x03) << 4) | ((in[1] & 0xf0) >> 4) ];
    out[2] = (unsigned char) (len > 1 ? cb64[ ((in[1] & 0x0f) << 2) | ((in[2] & 0xc0) >> 6) ] : '=');
    out[3] = (unsigned char) (len > 2 ? cb64[ in[2] & 0x3f ] : '=');
}

/*
 ** encode
 **
 ** base64 encode a stream adding padding and line breaks as per spec.
 */
NSData * b64_encode( NSData * data )
{
    uint8_t in[3], out[4];
    int i, len;
    
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    NSUInteger bytesLen = [data length];
    NSUInteger offset = 0;
    
    NSMutableData * outputData = [[NSMutableData alloc] initWithCapacity: bytesLen + (bytesLen/4) + 1];
    
    while( offset < bytesLen )
    {
        len = 0;
        for( i = 0; i < 3; i++ )
        {
            if ( offset < bytesLen )
            {
                in[i] = bytes[offset++];
                len++;
            }
            else
            {
                in[i] = 0;
            }
        }
        
        if ( len != 0 )
        {
            encodeblock( in, out, len );
            [outputData appendBytes: out length: 4];
        }
    }
    
    NSData * result = [outputData copy];
    return result;
}

/*
 ** decodeblock
 **
 ** decode 4 '6-bit' characters into 3 8-bit binary bytes
 */
void decodeblock( unsigned char in[4], unsigned char out[3] )
{
    out[ 0 ] = (unsigned char ) (in[0] << 2 | in[1] >> 4);
    out[ 1 ] = (unsigned char ) (in[1] << 4 | in[2] >> 2);
    out[ 2 ] = (unsigned char ) (((in[2] << 6) & 0xc0) | in[3]);
}

/*
 ** decode
 **
 ** decode a base64 encoded stream discarding padding, line breaks and noise
 */
NSData * b64_decode( NSData * data )
{
    uint8_t in[4], out[3], v;
    int i, len;
    
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    NSUInteger bytesLen = [data length];
    NSUInteger offset = 0;
    
    NSMutableData * outputData = [[NSMutableData alloc] initWithCapacity: bytesLen];
    
    while ( offset < bytesLen )
    {
        for ( len = 0, i = 0; i < 4 && offset < bytesLen; i++ )
        {
            v = 0;
            while ( offset < bytesLen && v == 0 )
            {
                v = bytes[offset++];
                v = ((v < 43 || v > 122) ? 0 : cd64[ v - 43 ]);
                
                if ( v != 0 )
                {
                    v = ((v == '$') ? 0 : v - 61);
                }
            }
            
            if ( (offset < (bytesLen+1)) && (v != 0) )
            {
                len++;
                if ( v != 0 )
                {
                    in[ i ] = (v - 1);
                }
            }
            else
            {
                in[i] = 0;
            }
        }
        
        if ( len )
        {
            decodeblock( in, out );
            [outputData appendBytes: out length: len-1];
        }
    }
    
    NSData * result = [outputData copy];
    return result;
}

@end

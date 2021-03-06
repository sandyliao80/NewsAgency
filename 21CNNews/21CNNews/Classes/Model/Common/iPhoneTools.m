//
//  iPhoneTools.m
//  Model
//
//  Created by chenggk on 13-4-5.
//  Copyright (c) 2013年 21cn. All rights reserved.
//

#import "iPhoneTools.h"
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_init.h>
#include <mach/task.h>
#include <mach/task_info.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <uuid/uuid.h>
#include <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <dirent.h>
#import <sys/stat.h>
#import <sys/types.h>

const char * getiPhoneMac() {
	
	int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = (char*)malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
		printf("Error: sysctl, take 2");
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)] uppercaseString];
	free(buf);
	return [outstring UTF8String];
}


const char * getMD5(const char * str) {
	
    unsigned char result[16];
    CC_MD5( str, strlen(str), result );
    return [[[NSString stringWithFormat:
              @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
              result[0], result[1], result[2], result[3],
              result[4], result[5], result[6], result[7],
              result[8], result[9], result[10], result[11],
              result[12], result[13], result[14], result[15]
              ] lowercaseString] UTF8String];
}

char* getIMEI(char* buffer)
{
	if(buffer == NULL)
	{
		return NULL;
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SEL sel = sel_registerName("uniqueIdentifier");
    NSString *str = nil;
    
    if ([[UIDevice currentDevice] respondsToSelector:sel])
    {
        str = [[UIDevice currentDevice] performSelector:sel];
    }
    
    //< 如果uniqueIdentifier获取不到，则使用mac地址代替
	if (str == nil || [str compare:@""] == NSOrderedSame || str.length<20)
	{
		const char * iPhoneMac = getiPhoneMac();
		if (iPhoneMac)
		{
			strcpy(buffer, getMD5(iPhoneMac));  ///< 对mac地址进行md5加密
		}
		else
		{
			strcpy(buffer, "21CN_IPHONE_DEFAULT_IMEI");    ///< 如果mac地址都获取不到，则用默认字符串代替，一般不会进入带分支
		}
        
	}
	else
	{
		strcpy(buffer,[str UTF8String]);
	}
	[ pool release ];  
	return buffer;	
}



@implementation iPhoneTools

+ (NSString*)getIMEI
{
    char buffer[128] = {0};
    getIMEI(buffer);
    
    return [NSString stringWithUTF8String:buffer];
}


+ (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


+ (NSString *)cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


+ (BOOL)isFileExists:(NSString*)filePath
{
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+ (bool)isDirExists:(NSString*)dirPath
{
    if(!dirPath)
    {
        return false;
    }
    
	DIR* dir;
	dir= opendir([dirPath UTF8String]);
	if(dir == NULL)
	{
		return false;
	}
	closedir(dir);
	return true;
}

+ (bool)createDir:(NSString*)dir
{
	return [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
}


+ (bool)createDirIfNoExists:(NSString*)dir
{
    if ([self isDirExists:dir])
    {
        return NO;
    }
    
    return [self createDir:dir];
}


//获取新闻客户端cache，注意：目前仅计算了图片cache
+ (NSString*)getCacheSize
{
    NSString* cachePath = [self cachePath];
    NSString* fullPath = [NSString stringWithFormat:@"%@/com.news.21cn.-1CNNews/EGOCache", cachePath];
    uint64_t size = [self fileSizeOnDisk:fullPath]; ///< 获取图片缓存文件目录大小
    
    if (size >= 102)    ///< 减去文件夹及配置文件所占用的空间大小
    {
        size -= 102;
    }
    
    if (size >= 1024)
    {
        return [NSString stringWithFormat:@"%lldM", size / 1024];
    }
    
        
    return [NSString stringWithFormat:@"%lldK", size];
}


//获取客户端版本号
+ (NSString*)getCurrentVersion
{
    return @"v1.3版本";
}


//获取对应路径所占磁盘空间大小
+ (uint64_t)fileSizeOnDisk:(NSString*)path
{
    if (path && [path length] > 0)
    {
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSDictionary *attributes = [manager attributesOfItemAtPath:path error:NULL];
        [manager release];
        if (attributes)
        {
            return [attributes fileSize];
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}


@end

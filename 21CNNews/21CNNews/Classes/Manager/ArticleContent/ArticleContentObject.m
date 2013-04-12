//
//  ArticleContentObject.m
//  Model
//
//  Created by chenggk on 13-4-7.
//  Copyright (c) 2013年 21cn. All rights reserved.
//

#import "ArticleContentObject.h"
#import "LSThreadPool.h"
#import "LSURLDispatcher.h"
#import "LSURLDispatchOperation.h"
#import "LSURLDispatchDelegate.h"
#import "DBCommonHeader.h"
#import "ServicerCommonKey.h"
#import "UserSerialNumManager.h"


@implementation ArticleContentObject


- (id)initWithArticleId:(int)articleId
            articleType:(int)articleType
             articleUrl:(NSString*)articleUrl
                content:(NSString*)content
             createTime:(NSDate*)createTime
             leaderette:(NSString*)leaderette
           originalLink:(NSString*)originalLink
            publishTime:(NSDate*)publishTime
           sourceStatus:(int)sourceStatus
                  title:(NSString*)title
                topTime:(NSDate*)topTime
             sourceName:(NSString*)sourceName
                summary:(NSString*)summary
{
    self = [super init];
    if (self)
    {
        _articleId = articleId;
        _articleType = articleType;
        _articleUrl = [articleUrl copy];
        _content = [content copy];
        _createTime = [createTime copy];
        _leaderette = [leaderette copy];
        _originalLink = [originalLink copy];
        _publishTime = [publishTime copy];
        _sourceStatus = sourceStatus;
        _title = [title copy];
        _topTime = [topTime copy];
        _sourceName = [sourceName copy];
        _summary = [summary copy];
    }
    
    return self;
}



+ (ArticleContentObject*)articleContentObjectWithArticleId:(int)articleId
                                               articleType:(int)articleType
                                                articleUrl:(NSString*)articleUrl
                                                   content:(NSString*)content
                                                createTime:(NSDate*)createTime
                                                leaderette:(NSString*)leaderette
                                              originalLink:(NSString*)originalLink
                                               publishTime:(NSDate*)publishTime
                                              sourceStatus:(int)sourceStatus
                                                     title:(NSString*)title
                                                   topTime:(NSDate*)topTime
                                                sourceName:(NSString*)sourceName
                                                   summary:(NSString*)summary
{
    return [[[ArticleContentObject alloc] initWithArticleId:articleId
                                               articleType:articleType
                                                articleUrl:articleUrl
                                                   content:content
                                                createTime:createTime
                                                leaderette:leaderette
                                              originalLink:originalLink
                                               publishTime:publishTime
                                              sourceStatus:sourceStatus
                                                     title:title
                                                   topTime:topTime
                                                sourceName:sourceName
                                                    summary:summary] autorelease];
}



- (void)dealloc
{
    [_articleUrl release];
    [_content release];
    [_createTime release];
    [_leaderette release];
    [_originalLink release];
    [_publishTime release];
    [_title copy];
    [_topTime copy];
    [_sourceName copy];
    [_summary copy];
    
    [super dealloc];
}


@end

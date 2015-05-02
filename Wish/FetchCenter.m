//
//  FetchCenter.m
//  Wish
//
//  Created by Xinyi Zhuang on 2015-01-21.
//  Copyright (c) 2015 Xinyi Zhuang. All rights reserved.
//

#import "FetchCenter.h"
#import "AppDelegate.h"
#import "User.h"
#import "SDWebImageCompat.h"
//#define BASE_URL @"http://182.254.167.228/superplan/"


#define INNER_NETWORK_URL @"http://182.254.167.228"
#define OUTTER_NETWORK_URL @"http://120.24.73.51"
#define PROJECT @"/superplan/"

#define PLAN @"plan/"
#define GET_LIST @"splan_plan_getlist.php"
#define CREATE_PLAN @"splan_plan_create.php"
#define DELETE_PLAN @"splan_plan_delete_id.php"
#define UPDATE_PLAN_STATUS @"splan_plan_set_state.php"
#define UPDATE_PLAN @"splan_plan_update.php"

#define FEED @"feeds/"
#define PIC @"pic/"
#define UPLOAD_IMAGE @"splan_pic_upload.php"
#define GET_IMAGE @"splan_pic_get.php"
#define kFetchedImage @"fetchedImage" // for constructing NSDictionary with image data
#define CREATE_FEED @"splan_feeds_create.php"
#define LIKE_FEED @"splan_feeds_like.php"
#define UNLIKE_FEED @"splan_feeds_unlike.php"
#define LOAD_FEED_LIST @"splan_feeds_getlist.php"
#define DELETE_FEED @"splan_feeds_delete_id.php"

#define FOLLOW @"follow/"
#define GET_FOLLOW_LIST @"splan_follow_get_feedslist.php"


#define USER @"man/"
#define GETUID @"splan_get_uid.php"
#define UPDATE_USER_INFO @"splan_man_update.php"
#define SET_USER_INFO @"splan_man_set.php"

#define OTHER @"other/"
#define CHECK_NEW_VERSION @"splan_other_new_version.php"
#define FEED_BACK @"splan_other_support_set.php"


#define DISCOVER @"find/"
#define GET_DISCOVER_LIST @"splan_find_planlist.php"



typedef enum{
    FetchCenterGetOpCreatePlan = 0,
    FetchCenterGetOpDeletePlan,
    FetchCenterGetOpUploadImage,
    FetchCenterGetOpCreateFeed,
    FetchCenterGetOpGetPlanList,
    FetchCenterGetOpSetPlanStatus,
    FetchCenterGetOpUpdatePlan,
    FetchCenterGetOpFollowingPlanList,
    FetchCenterGetOpLoginForUidAndUkey,
    FetchCenterGetOpCheckNewVersion,
    FetchCenterGetOpUpdatePersonalInfo,
    FetchCenterGetOpSetPersonalInfo,
    FetchCenterGetOpDiscoverPlans,
    FetchCenterGetOpLikeAFeed,
    FetchCenterGetOpUnLikeAFeed,
    FetchCenterGetOpDeleteFeed,
    FetchCenterGetOpLoadFeedList,
    FetchCenterGetOpFeedBack
}FetchCenterGetOp;

typedef enum{
    FetchCenterPostOpUploadImageForCreatingFeed = 0,
    FetchCenterPostOpUploadImageForUpdaingProfile
}FetchCenterPostOp;

@interface FetchCenter ()
@property (nonatomic,strong) NSString *baseUrl;
@end
@implementation FetchCenter

- (NSString *)baseUrl{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_USE_INNER_NETWORK]) {
        _baseUrl = [NSString stringWithFormat:@"%@%@",INNER_NETWORK_URL,PROJECT];
    }else{
        _baseUrl = [NSString stringWithFormat:@"%@%@",OUTTER_NETWORK_URL,PROJECT];
    }
//    NSLog(@"%@",_baseUrl);
    return _baseUrl;
}


#pragma mark - Feed
//superplan/feeds/splan_feeds_delete_id.php
- (void)deleteFeed:(Feed *)feed{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,DELETE_FEED];
    NSDictionary *args = @{@"id":feed.feedId,
                           @"picId":feed.imageId,
                           @"planId":feed.plan.planId};
    [self getRequest:rqtStr
           parameter:args
           operation:FetchCenterGetOpDeleteFeed
              entity:feed];
}


- (void)loadFeedsListForPlan:(Plan *)plan pageInfo:(NSDictionary *)info{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LOAD_FEED_LIST];
    NSString *infoStr = info ? [self convertDictionaryToString:info] : @"";
    NSDictionary *args = @{@"id":plan.planId,@"attachInfo":infoStr};
    [self getRequest:rqtStr
           parameter:args
           operation:FetchCenterGetOpLoadFeedList
              entity:plan];
}

- (NSString*)convertDictionaryToString:(NSDictionary*)dict{
    NSError* error;
    //giving error as it takes dic, array,etc only. not custom object.
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)uploadToCreateFeed:(Feed *)feed{
    [self postImageWithOperation:feed postOp:FetchCenterPostOpUploadImageForCreatingFeed];
}

- (void)likeFeed:(Feed *)feed{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,LIKE_FEED];
    [self getRequest:rqtStr
           parameter:@{@"id":feed.feedId}
           operation:FetchCenterGetOpLikeAFeed
              entity:feed];
}

- (void)unLikeFeed:(Feed *)feed{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,UNLIKE_FEED];
    [self getRequest:rqtStr
           parameter:@{@"id":feed.feedId}
           operation:FetchCenterGetOpUnLikeAFeed
              entity:feed];
    
}

#pragma mark - following list
- (void)fetchFollowingPlanList{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FOLLOW,GET_FOLLOW_LIST];
    [self getRequest:rqtStr
           parameter:@{@"id":[User uid]}
           operation:FetchCenterGetOpFollowingPlanList
              entity:nil];
}

#pragma mark - Discovery Related

- (void)getDiscoveryList{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,DISCOVER,GET_DISCOVER_LIST];
    [self getRequest:rqtStr parameter:nil operation:FetchCenterGetOpDiscoverPlans entity:nil];
}


#pragma mark - Login&out & update personal info

- (void)sendFeedback:(NSString *)title content:(NSString *)content{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,OTHER,FEED_BACK];
    NSString *newTitle = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *newContent = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *moreInfo = [[[Reachability reachabilityForInternetConnection] currentReachabilityString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self getRequest:rqtStr
           parameter:@{@"title":newTitle,
                       @"content":newContent,
                       @"moreInfo":moreInfo}
           operation:FetchCenterGetOpFeedBack
              entity:nil];
}
- (void)checkVersion{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,OTHER,CHECK_NEW_VERSION];
    [self getRequest:rqtStr
           parameter:nil
           operation:FetchCenterGetOpCheckNewVersion
              entity:nil];
}


- (void)fetchUidandUkeyWithOpenId:(NSString *)openId accessToken:(NSString *)token{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,GETUID];
    [self getRequest:rqtStr
           parameter:@{@"openid":openId,
                       @"token":token}
           operation:FetchCenterGetOpLoginForUidAndUkey
              entity:nil];
}

#pragma mark - personal

- (void)uploadNewProfilePicture:(UIImage *)picture{
    [self postImageWithOperation:picture postOp:FetchCenterPostOpUploadImageForUpdaingProfile];
}


- (void)updatePersonalInfo:(NSString *)nickName gender:(NSString *)gender{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,UPDATE_USER_INFO];
    [self getRequest:rqtStr parameter:@{@"name":[nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"gender":[gender isEqualToString:@"男"] ? @(0):@(1)}
           operation:FetchCenterGetOpUpdatePersonalInfo
              entity:@[nickName,gender]];

}

- (void)setPersonalInfo:(NSString *)nickName gender:(NSString *)gender imageId:(NSString *)imageId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,USER,SET_USER_INFO];
    [self getRequest:rqtStr parameter:@{@"name":[nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"gender":[gender isEqualToString:@"男"] ? @(0):@(1),
                                        @"headUrl":imageId}
           operation:FetchCenterGetOpSetPersonalInfo
              entity:@[nickName,gender]];
    
}
#pragma mark - Plan
- (void)updatePlan:(Plan *)plan{
    //输入样例：id=hello_1421235901&title=hello_title2&finishDate=3&backGroudPic=bg3&private=1&state=1&finishPercent=20
    //—— 每一项都可以单独更新
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN];
    [self getRequest:rqtStr parameter:@{@"id":plan.planId,
                                        @"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        @"finishDate":@([SystemUtil daysBetween:plan.createDate and:plan.finishDate]),
                                        @"private":plan.isPrivate}
           operation:FetchCenterGetOpUpdatePlan
              entity:plan];
   
}
- (void)updateStatus:(Plan *)plan{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,UPDATE_PLAN_STATUS];
    [self getRequest:rqtStr parameter:@{@"id":plan.planId,
                                        @"state":plan.planStatus}
           operation:FetchCenterGetOpSetPlanStatus entity:plan];

}
- (void)fetchPlanList:(NSString *)ownerId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,GET_LIST];
    [self getRequest:rqtStr parameter:@{@"id":ownerId} operation:FetchCenterGetOpGetPlanList entity:nil];

}

-(void)uploadToCreatePlan:(Plan *)plan{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,CREATE_PLAN];
    NSDictionary *args = @{@"title":[plan.planTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           @"finishDate":@([SystemUtil daysBetween:[NSDate date] and:plan.finishDate]),
                           @"private":plan.isPrivate};
    [self getRequest:baseUrl parameter:args operation:FetchCenterGetOpCreatePlan entity:plan];
}


- (void)postToDeletePlan:(Plan *)plan
{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,PLAN,DELETE_PLAN];
    NSDictionary *args = @{@"id":plan.planId};
    [self getRequest:baseUrl parameter:args operation:FetchCenterGetOpDeletePlan entity:plan];
}



- (void)didFinishSendingPostRequest:(NSDictionary *)json operation:(FetchCenterPostOp)op entity:(NSManagedObject *)obj{
    
    NSString *fetchedImageId = [json valueForKeyPath:@"data.id"];
    switch (op){
        case FetchCenterPostOpUploadImageForCreatingFeed:{
            if (fetchedImageId){
                Feed *feed = (Feed *)obj;
                feed.imageId = fetchedImageId;
                NSLog(@"fetched image ID: %@",fetchedImageId);
                //upload feed
                NSString *baseURL = [NSString stringWithFormat:@"%@%@%@",self.baseUrl,FEED,CREATE_FEED];
                NSDictionary *args;
                if (feed.plan.planId && feed.feedTitle) {
                    args = @{@"picurl":fetchedImageId,
                             @"content":[feed.feedTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"planId":feed.plan.planId};
                    [self getRequest:baseURL
                           parameter:args
                           operation:FetchCenterGetOpCreateFeed entity:obj];
                }
            }
        }
            break;
        case FetchCenterPostOpUploadImageForUpdaingProfile:{
            //update local User info
            if (fetchedImageId){
                [User updateAttributeFromDictionary:@{PROFILE_PICTURE_ID_CUSTOM:fetchedImageId}];
                NSLog(@"image uploaded %@",fetchedImageId);
                [self.delegate didFinishUploadingPictureForProfile:json];
            }
        }
            break;
        default:
            break;
    }
}

- (void)didFinishSendingGetRequest:(NSDictionary *)json operation:(FetchCenterGetOp)op entity:(id)obj{
    dispatch_main_async_safe((^{
        switch (op)
        {
            case FetchCenterGetOpGetPlanList:
                //get plan list
                break;
            case FetchCenterGetOpDeletePlan:{
                AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [delegate saveContext];
                NSLog(@"deleted successed %@",json);
            }
                break;
            case FetchCenterGetOpCreateFeed:{
                NSString *fetchedFeedID = [json valueForKeyPath:@"data.id"];
                if (fetchedFeedID){
                    Feed *feed = (Feed *)obj;
                    feed.feedId = fetchedFeedID;
                    [self.delegate didFinishUploadingFeed:feed];
                    NSLog(@"upload feed successed, ID: %@",fetchedFeedID);
                }
            }
                break;
            case FetchCenterGetOpCreatePlan:{
                NSString *fetchedPlanId = [json valueForKeyPath:@"data.id"];
                NSString *bgString = [json valueForKeyPath:@"data.backGroudPic"];
                if (fetchedPlanId && bgString) {
                    Plan *plan = (Plan *)obj;
                    plan.planId = fetchedPlanId;
                    plan.backgroundNum = bgString;
                    [self.delegate didFinishUploadingPlan:plan];
                    NSLog(@"create plan succeed, ID: %@",fetchedPlanId);
                }
            }
                break;
            case FetchCenterGetOpSetPlanStatus:{
                NSLog(@"updated plan status (from server)");
                NSLog(@"updated status : %@",((Plan *)obj).planStatus);
            }
                break;
            case FetchCenterGetOpFollowingPlanList:{
                //            NSLog(@"FetchCenterOpGetFollowingPlanList \n %@",json);
                //save the response following plan list
                for (NSDictionary *planItem in [json valueForKeyPath:@"data.planList"]) {
                    Plan *plan = [Plan updatePlanFromServer:planItem];
                    NSDictionary *userInfo = [json valueForKeyPath:[NSString stringWithFormat:@"data.manList.%@",plan.ownerId]];
                    plan.owner = [Owner updateOwnerFromServer:userInfo];
                    NSArray *feedsList = planItem[@"feedsList"];
                    if (feedsList.count) {
                        //create all feeds
                        for (NSDictionary *feedItem in feedsList) {
                            [Feed createFeedFromServer:feedItem forPlan:plan];
                            //use alternative way to load and cache image
                        }
                    }
                }
                [self.delegate didFinishFetchingFollowingPlanList];
            }
                break;
            case FetchCenterGetOpLoginForUidAndUkey:{
                NSString *uid = [json valueForKeyPath:@"data.uid"];
                NSString *ukey = [json valueForKeyPath:@"data.ukey"];
                BOOL isNewUser = [[json valueForKeyPath:@"data.isNew"] boolValue];
                NSDictionary *userInfo = [json valueForKeyPath:@"data.maninfo"];
                [self.delegate didFinishReceivingUid:uid
                                                uKey:ukey
                                           isNewUser:isNewUser
                                            userInfo:userInfo];
            }
                break;
            case FetchCenterGetOpUpdatePlan:{
                Plan *plan = (Plan *)obj;
                [self.delegate didFinishUpdatingPlan:plan];
            }
                break;
            case FetchCenterGetOpCheckNewVersion:{
                BOOL hasNewVersion = [[json valueForKeyPath:@"data.haveNew"] boolValue];
                [self.delegate didFinishCheckingNewVersion:hasNewVersion];
            }
                break;
            case FetchCenterGetOpSetPersonalInfo:{
                NSArray *info = (NSArray *)obj; // nickname,gender
                [User updateAttributeFromDictionary:@{USER_DISPLAY_NAME:info[0],
                                                      GENDER:info[1]}];
                [self.delegate didFinishSettingPersonalInfo];
            }
                break;
            case FetchCenterGetOpUpdatePersonalInfo:{
                NSArray *info = (NSArray *)obj;
                [User updateAttributeFromDictionary:@{USER_DISPLAY_NAME:info[0],GENDER:info[1]}];
                [self.delegate didFinishUpdatingPersonalInfo];
            }
                break;
            case FetchCenterGetOpDiscoverPlans:{
                //stored the lastet
                NSMutableArray *plans = [[NSMutableArray alloc] init];
                NSArray *planList = [json valueForKeyPath:@"data.planList"];
                NSDictionary *manList = [json valueForKeyPath:@"data.manList"];
                if (planList && manList){
                    for (NSDictionary *planInfo in planList){
                        Plan *plan = [Plan updatePlanFromServer:planInfo];
                        plan.owner = [Owner updateOwnerFromServer:[manList valueForKey:plan.ownerId]];
                        [plans addObject:plan];
                        
                    }
                }
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveContext];
                [self.delegate didfinishFetchingDiscovery:plans];
            }
                break;
            case FetchCenterGetOpLikeAFeed:{
                Feed *feed = (Feed *)obj;
                NSLog(@"liked feed ID %@",feed.feedId);
            }
                break;
            case FetchCenterGetOpUnLikeAFeed:{
                Feed *feed = (Feed *)obj;
                NSLog(@"unliked feed ID %@",feed.feedId);
            }
                break;
            case FetchCenterGetOpDeleteFeed:{
                [self.delegate didFinishDeletingFeed:obj];
            }
                break;
            case FetchCenterGetOpLoadFeedList:{
                
                NSArray *feeds = [json valueForKeyPath:@"data.feedsList"];
                BOOL hasNextPage = [[json valueForKeyPath:@"data.isMore"] boolValue];
                NSDictionary *pageInfo = [json valueForKeyPath:@"data.attachInfo"];
                for (NSDictionary *info in feeds){
                    [Feed createFeedFromServer:info forPlan:obj]; // obj is Plan*
                }
                [self.delegate didFinishLoadingFeedList:pageInfo hasNextPage:hasNextPage];
            }
                break;
            case FetchCenterGetOpFeedBack:
                [self.delegate didFinishSendingFeedBack];
                break;
            default:
                break;
        }
        NSLog(@"%@",json);
        
    }));
}

#pragma mark - main get and post method

- (NSString *)argumentStringWithDictionary:(NSDictionary *)dict{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dict.allKeys.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }];
    return [array componentsJoinedByString:@"&"];
}



- (BOOL)hasActiveInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return reachability.currentReachabilityStatus != NotReachable;
}



- (void)getRequest:(NSString *)baseURL parameter:(NSDictionary *)dict operation:(FetchCenterGetOp)op entity:(id)obj{
    
    //check internet connection
    if (![self hasActiveInternetConnection]){
        [self.delegate didFailSendingRequestWithInfo:@{@"ret":@"网络故障",@"msg":@"请检查网络连接"} entity:obj];
        return;
    }
    //base url with version
    baseURL = [baseURL stringByAppendingString:@"?"];
    baseURL = [self versionForBaseURL:baseURL operation:op];
    
    
    //content arguments
    NSString *rqtStr = [baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtStr]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                      if ([responseJson[@"ret"] integerValue] == -305) {
                                          NSLog(@"-305: invalid system version");
                                          return;
                                      }
                                      if (!error && ![responseJson[@"ret"] boolValue]){ //successed "ret" = 0;
                                          [self didFinishSendingGetRequest:responseJson operation:op entity:obj];
                                      }else{
                                          NSLog(@"Fail Get Request :%@\n op: %d \n baseUrl: %@ \n parameter: %@ \n response: %@ \n error:%@",rqtStr,op,baseURL,dict,responseJson,error);
                                          [self.delegate didFailSendingRequestWithInfo:responseJson entity:obj];
                                      }
                                  }];
    [task resume];
    
    
}

- (void)postImageWithOperation:(id)obj postOp:(FetchCenterPostOp)postOp{ //obj :NSManagedObject or UIimage
    
    //chekc internet
    if (![self hasActiveInternetConnection]){
        [self.delegate didFailUploadingImageWithInfo:@{@"ret":@"网络故障",@"msg":@"请检查网络连接"} entity:obj];
        return;
    }

    NSString *rqtUploadImage = [NSString stringWithFormat:@"%@%@%@?",self.baseUrl,PIC,UPLOAD_IMAGE];
    rqtUploadImage = [self versionForBaseURL:rqtUploadImage operation:-1];
    
    UIImage *image; // = [obj valueForKey:@"image"];
    if ([obj isKindOfClass:[UIImage class]]){
        image = obj;
    }else if ([obj isKindOfClass:[NSManagedObject class]]){
        image = [obj valueForKey:@"image"];
    }else{
        NSAssert(true, @"postImageWithOperation :invalid obj");
    }
    
    //upload image
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rqtUploadImage]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    request.HTTPMethod = @"POST";

    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:[self compressImage:image]
                                                      completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                          {
                                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingAllowFragments
                                                                                                     error:nil];
                                              
                                              if (!error && ![json[@"ret"] boolValue]){ //upload image successed
                                                  [self didFinishSendingPostRequest:json
                                                                          operation:postOp
                                                                             entity:obj];
                                              }else{
                                                  NSLog(@"fail to upload image \n response:%@",json);
                                                  [self.delegate didFailUploadingImageWithInfo:json entity:obj];
                                              }
                                          }];
    [uploadTask resume];
    
}



#pragma mark - version control 

//return a new base url string with appened version argument
- (NSString *)versionForBaseURL:(NSString *)baseURL operation:(FetchCenterGetOp)op{
    NSMutableDictionary *dict = [@{@"version":@"2.2.2",
                                   @"loginType":@"qq",
                                   @"sysVersion":[UIDevice currentDevice].systemVersion,
                                   @"sysModel":[[UIDevice currentDevice].model stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} mutableCopy];
    if (op != FetchCenterGetOpLoginForUidAndUkey) {
        [dict addEntriesFromDictionary:@{@"uid":[User uid],@"ukey":[User uKey]}];
        dict[@"loginType"] = @"uid";
    }
    return [[baseURL stringByAppendingString:[self argumentStringWithDictionary:dict]] stringByAppendingString:@"&"];
}

#pragma mark - get image url wraper

- (NSURL *)urlWithImageID:(NSString *)imageId{
    NSString *rqtStr = [NSString stringWithFormat:@"%@%@%@?",self.baseUrl,PIC,GET_IMAGE];
    NSString *url = [NSString stringWithFormat:@"%@id=%@",[self versionForBaseURL:rqtStr operation:-1],imageId];
    return [NSURL URLWithString:url];
}

#pragma mark - image compression 

- (NSData *)compressImage:(UIImage *)image{
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
    CGFloat maxHeight = 600.0;
    CGFloat maxWidth = 800.0;
    CGFloat imgRatio = actualWidth/actualHeight;
    CGFloat maxRatio = maxWidth/maxHeight;
    CGFloat compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
}

@end

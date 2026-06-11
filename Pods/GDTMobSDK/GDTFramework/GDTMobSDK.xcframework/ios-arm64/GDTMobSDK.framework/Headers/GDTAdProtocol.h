//
//  GDTAdProtocol.h
//  GDTMobApp
//
//  Created by rowanzhang on 2021/12/23.
//  Copyright © 2021 Tencent. All rights reserved.
//

#ifndef GDTAdProtocol_h
#define GDTAdProtocol_h

#define GDT_REQ_ID_KEY @"request_id"
#define GDT_M_W_E_COST_PRICE @"expectCostPrice"
#define GDT_M_W_H_LOSS_PRICE @"highestLossPrice"
#define GDT_M_L_WIN_PRICE @"winPrice"
#define GDT_M_L_LOSS_REASON @"lossReason"
#define GDT_M_ADNID  @"adnId"
#define GDT_M_MEDIATIONCACHE  @"mediationCache"

@protocol GDTAdProtocol <NSObject>

@optional
- (NSDictionary *)extraInfo;

/**
 *  竞胜之后调用, 需要在调用广告 show 之前调用，旧的- (void)sendWinNotificationWithPrice:(NSInteger)price已废弃
 *
 *  @param winInfo 字典类型，支持的key为以下，注：key是个宏，在GDTAdProtocol.h中有定义，可以参考demo中的使用方法

 *  GDT_M_W_E_COST_PRICE：竞胜价格 (单位: 分)，值类型为NSNumber *
 *  GDT_M_W_H_LOSS_PRICE：最高失败出价，值类型为NSNumber  *
 *
 */
- (void)sendWinNotificationWithInfo:(NSDictionary *)winInfo;

/**
 *  竞败之后或未参竞调用，旧的- (void)sendLossNotificationWithWinnerPrice:(NSInteger)price lossReason:(GDTAdBiddingLossReason)reason winnerAdnID:(NSString *)adnID已废弃
 *
 *  @pararm lossInfo 竞败信息，字典类型，注：key是个宏，在GDTAdProtocol.h中有定义，可以参考demo中的使用方法
 *  GDT_M_L_WIN_PRICE ：竞胜价格 (单位: 分)，值类型为NSNumber *，选填
 *  GDT_M_L_LOSS_REASON ：优量汇广告竞败原因，竞败原因参考枚举GDTAdBiddingLossReason中的定义，值类型为NSNumber *，必填
 *  GDT_M_ADNID  ：竞胜方渠道ID，值类型为NSString *，必填
 */
- (void)sendLossNotificationWithInfo:(NSDictionary *)lossInfo;

@end

@protocol GDTAdDelegate <NSObject>

@optional
/**
  投诉成功回调
  @params ad 广告对象实例
 */
- (void)gdtAdComplainSuccess:(id)ad;


/// 广告达到激励条件回调
/// - Parameters:
///   - adInstance: Ad 实例
///   - info: 包含此次广告行为的一些信息，例如
///   {@"GDT_TRANS_ID":@"930f1fc8ac59983bbdf4548ee40ac353",@"GDT_REWARD_EXT":@"{\"count\":500,\"type\":\"金币\"}"}
///   通过GDT_TRANS_ID可获取此次广告行为的交易id，
///   通过GDT_REWARD_EXT获取奖励信息
/// - Important: 部分广告存在历史激励回调，例如激励视频广告/插屏广告。开发者仅实现一个就好，后续历史激励回调会逐渐废弃，收拢到此。
- (void)gdt_adDidRewardEffective:(id <GDTAdProtocol>)adInstance info:(NSDictionary *)info;

@end
#endif /* GDTAdProtocol_h */

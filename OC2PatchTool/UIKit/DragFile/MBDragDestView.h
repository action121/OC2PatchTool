//
//  SFDragDestView.h
//  SFIM
//
//  Created by 吴晓明 on 2018/4/25.
//  Copyright © 2018年 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBDraggingDestinationProtocol.h"

/*
 【接收】文件拖拽事件的视图
 如果不拖出自己的视图区域正常拖入释放的话，调用顺序是
 1. draggingEntered //拖入
 2. prepareForDragOperation //松手进行判断，拖入准备
 3. performDragOperation //执行拖入过程
 */
IB_DESIGNABLE
@interface MBDragDestView : NSView<MBDraggingDestination>

@property(nonatomic,weak)IBOutlet id<MBDraggingDestination> dragDestDelegate;

@property(nonatomic,strong)NSString *dragingTipMessage;

@end

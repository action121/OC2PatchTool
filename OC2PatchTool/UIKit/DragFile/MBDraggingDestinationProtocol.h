//
//  SFDraggingDestinationProtocol.h
//  SFIM
//
//  Created by 吴晓明 on 2018/4/25.
//  Copyright © 2018年 . All rights reserved.
//

/**
 外界文件拖拽到APP里面的代理
 */
@protocol MBDraggingDestination <NSDraggingDestination>

- (BOOL)shouldAllowDragDestination:(id<NSDraggingInfo>)sender;
-(void)mbPerformDragOperation:(id <NSDraggingInfo>)sender;

@end

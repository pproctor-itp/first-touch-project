//
//  MyCustomView.h
//  FirstTouch
//
//  Created by Patrick Proctor on 2/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyCustomView : UIView
{
	CGFloat                    squareSize;
	CGFloat                    rotation;
	CGColorRef                 aColor;
	CGFloat                    initialDistance;
	BOOL                       twoFingers;
	
	IBOutlet UILabel           *xField;
	IBOutlet UILabel           *yField;
	IBOutlet UILabel           *zField;
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

@end

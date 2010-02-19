//
//  MyCustomView.m
//  RotateMe
//
//  Created by David Nolen on 2/16/09.
//  Copyright 2009 David Nolen. All rights reserved.
//

#import "MyCustomView.h"
#import "math.h"

#define kAccelerometerFrequency        10 //Hz

@implementation MyCustomView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
	}
	return self;
}

- (void) awakeFromNib
{
	// you have to initialize your view here since it's getting
	// instantiated by the nib
	squareSize = 100.0f;
	twoFingers = NO;
	rotation = 0.5f;
	initialDistance = 0;
	
	// You have to explicity turn on multitouch for the view
	self.multipleTouchEnabled = YES;
	
	// configure for accelerometer
	[self configureAccelerometer];
}

-(void)configureAccelerometer
{
	UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
	
	if(theAccelerometer)
	{
		theAccelerometer.updateInterval = 1 / kAccelerometerFrequency;
		theAccelerometer.delegate = self;
	}
	else
	{
		NSLog(@"Oops we're not running on the device!");
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	UIAccelerationValue x, y, z;
	x = acceleration.x;
	y = acceleration.y;
	z = acceleration.z;
	
	// Do something with the values.
	xField.text = [NSString stringWithFormat:@"%.5f", x];
	yField.text = [NSString stringWithFormat:@"%.5f", y];
	zField.text = [NSString stringWithFormat:@"%.5f", z];
	NSLog(@"Wrote Fields");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touches began count %d, %@", [touches count], touches);
	
	if([touches count] > 1)
	{
		twoFingers = YES;
		
		//Track the initial distance between two fingers.
		UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
		UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
		
		initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:self] 
												 toPoint:[touch2 locationInView:self]];
	}
	
	// tell the view to redraw
	[self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	NSLog(@"touches moved count %d, %@", [touches count], touches);
	
	if (twoFingers)
	{
		//The image is being zoomed in or out.
		
		UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
		UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
		
		//Calculate the distance between the two fingers.
		CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:self]
													   toPoint:[touch2 locationInView:self]];
		
		//Check if zoom in or zoom out.
		if(initialDistance > finalDistance && squareSize > 10) 
		{
			squareSize-=5;
		} 
		else if (squareSize < 300) 
		{
			squareSize+=5;
		}
	}
	else
	{
		for (UITouch* touch in touches) 
		{
			CGPoint loc = [touch locationInView:self];
			CGPoint prevloc = [touch previousLocationInView:self];
			
			CGRect rect = self.frame;
			
			// Use the origin of the square along with trig to calculate rotation
			CGFloat centerx = rect.size.width/2;
			CGFloat centery = rect.size.height/2;
			
			CGFloat oppositeCurrent = loc.y - centery;
			CGFloat adjacentCurrent = loc.x - centerx;
			
			CGFloat oppositePrevious = prevloc.y - centery;
			CGFloat adjacentPrevious = prevloc.x - centerx;
			
			CGFloat currentAngle = atan(oppositeCurrent/adjacentCurrent);
			CGFloat previousAngle = atan(oppositePrevious/adjacentPrevious);
			
			rotation += (currentAngle - previousAngle);
		}
	}
	
	// tell the view to redraw
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touches moved count %d, %@", [touches count], touches);
	
	// reset the var
	twoFingers = NO;
	initialDistance = -1;
	
	// tell the view to redraw
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
	NSLog(@"drawRect");
	
	CGFloat centerx = rect.size.width/2;
	CGFloat centery = rect.size.height/2;
	CGFloat half = squareSize/2;
	CGRect theRect = CGRectMake(-half, -half, squareSize, squareSize);
	
	// Grab the drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// like Processing pushMatrix
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, centerx, centery);
	
	// Uncomment to see the rotated square
	CGContextRotateCTM(context, rotation);
	
	// Set red stroke
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	
	// Set different based on multitouch
	if(!twoFingers)
	{
		CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	}
	else
	{
		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	}
	
	// Draw a rect with a red stroke
	CGContextFillRect(context, theRect);
	CGContextStrokeRect(context, theRect);
	
	// like Processing popMatrix
	CGContextRestoreGState(context);
}

- (void) dealloc
{
	[super dealloc];
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	
	float x = toPoint.x - fromPoint.x;
	float y = toPoint.y - fromPoint.y;
	
	return sqrt(x * x + y * y);
}

@end
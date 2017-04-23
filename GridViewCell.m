/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A collection view cell that displays a thumbnail image.
 */

#import "GridViewCell.h"

@interface GridViewCell ()
@end

@implementation GridViewCell

/*
-(void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    self.selectedImageTick.hidden = !selected;
    if (selected)
        NSLog(@"Yes %X", &self);
    else
        NSLog(@"No %X", &self);
}*/

-(void)setSelection:(BOOL)selected {
    
    [super setSelected:selected];
    self.selectedImageTick.hidden = !selected;
//    if (selected)
//        NSLog(@"Yes %X", &self);
//    else
//        NSLog(@"No %X", &self);
}



@end

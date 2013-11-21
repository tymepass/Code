//
//  FontSettings.m
//  Timepass
//
//  Created by Mahmood1 on 22/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UISettings.h"
#import "QuartzCore/QuartzCore.h"

@implementation UISettings
@synthesize appFont;
@synthesize appFontBold;

@synthesize headerFont;
@synthesize headerDetailFont;
@synthesize footerFont;
@synthesize footerDetailFont;
@synthesize cellFont;
@synthesize cellDetailFont;
@synthesize textViewFont;
@synthesize buttonFont;
@synthesize monthCalendarDayNumberFont;
@synthesize dayCalendarHoursFont;

@synthesize headerFontSize;
@synthesize headerDetailFontSize;
@synthesize footerFontSize;
@synthesize footerDetailFontSize;
@synthesize cellFontSize;
@synthesize cellDetailFontSize;
@synthesize textViewFontSize;
@synthesize buttonFontSize;
@synthesize monthCalendarDayNumberFontSize;
@synthesize dayCalendarHoursFontSize;

@synthesize headerColorRed;
@synthesize headerColorGreen;
@synthesize headerColorBlue;
@synthesize headerDetailColorRed;
@synthesize headerDetailColorGreen;
@synthesize headerDetailColorBlue;
@synthesize footerColorRed;
@synthesize footerColorGreen;
@synthesize footerColorBlue;
@synthesize footerDetailColorRed;
@synthesize footerDetailColorGreen;
@synthesize footerDetailColorBlue;
@synthesize cellColorRed;
@synthesize cellColorGreen;
@synthesize cellColorBlue;
@synthesize cellDetailColorRed;
@synthesize cellDetailColorGreen;
@synthesize cellDetailColorBlue;
@synthesize textViewColorRed;
@synthesize textViewColorGreen;
@synthesize textViewColorBlue;
@synthesize navigationBarTintColorRed;
@synthesize navigationBarTintColorGreen;
@synthesize navigationBarTintColorBlue;
@synthesize buttonBackgroundColorRed;
@synthesize buttonBackgroundColorGreen;
@synthesize buttonBackgroundColorBlue;
@synthesize monthCalendarDayNumberColorRed;
@synthesize monthCalendarDayNumberColorGreen;
@synthesize monthCalendarDayNumberColorBlue;
@synthesize dayCalendarHoursColorRed;
@synthesize dayCalendarHoursColorGreen;
@synthesize dayCalendarHoursColorBlue;

@synthesize yesImage;
@synthesize noImage;
@synthesize maybeImage;
@synthesize declineImage;
@synthesize changetimeImage;

@synthesize backgroundImage;

@synthesize units;

@synthesize profileImagePixels;
@synthesize profileThumbImagePixels;

- (id)init
{
    self = [super init];
    if (self) {
        appFont = [NSString stringWithFormat:@"HelveticaNeue"];
        appFontBold = [NSString stringWithFormat:@"HelveticaNeue-Bold"];

        headerFont = appFontBold;
        headerDetailFont = appFont;
        footerFont = appFontBold;
        footerDetailFont = appFontBold;
        cellFont = appFontBold;
        cellDetailFont = appFont;
        textViewFont = appFont;
        buttonFont = appFontBold;
        monthCalendarDayNumberFont = appFont;
        dayCalendarHoursFont = appFontBold;
        
        headerFontSize = 13.0;
        headerDetailFontSize = 11.0;
        footerFontSize = 13.0;
        footerDetailFontSize = 12.0;
        cellFontSize = 17.0;
        cellDetailFontSize = 15.0;
        textViewFontSize = 13.0;
        buttonFontSize = 15.0;
        monthCalendarDayNumberFontSize = 14.0;
        dayCalendarHoursFontSize = 14.0;
        
        headerColorRed = 0.0/255.0;
        headerColorGreen = 114.0/255.0;
        headerColorBlue = 188.0/255.0;
        
        headerDetailColorRed = 111.0/255.0;
        headerDetailColorGreen = 176.0/255.0;
        headerDetailColorBlue = 24.0/255.0;
        
        footerColorRed = 0.0/255.0;
        footerColorGreen = 114.0/255.0;
        footerColorBlue = 188.0/255.0;
        
        footerDetailColorRed = 128.0/255.0;
        footerDetailColorGreen = 128.0/255.0;
        footerDetailColorBlue = 128.0/255.0;
        
        cellColorRed = 204.0/255.0;
        cellColorGreen = 204.0/255.0;
        cellColorBlue = 204.0/255.0;
        
        cellDetailColorRed = 111.0/255.0;
        cellDetailColorGreen = 176.0/255.0;
        cellDetailColorBlue = 24.0/255.0;
        
        textViewColorRed = 128.0/255.0;
        textViewColorGreen = 128.0/255.0;
        textViewColorBlue = 128.0/255.0;
        
        navigationBarTintColorRed = 0.0/255.0;
        navigationBarTintColorGreen = 108.0/255.0;
        navigationBarTintColorBlue = 184.0/255.0;
        
        buttonBackgroundColorRed = 0.0/255.0;
        buttonBackgroundColorGreen = 108.0/255.0;
        buttonBackgroundColorBlue = 184.0/255.0;
        
        monthCalendarDayNumberColorRed = 0.0/255.0;
        monthCalendarDayNumberColorGreen = 114.0/255.0;
        monthCalendarDayNumberColorBlue = 188.0/255.0;
        
        dayCalendarHoursColorRed = 111.0/255.0;
        dayCalendarHoursColorGreen = 176.0/255.0;
        dayCalendarHoursColorBlue = 24.0/255.0;
        
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
			backgroundImage = [UIImage imageNamed:@"main_bg@2x.png"];
		} else {
			backgroundImage = [UIImage imageNamed:@"main_bg.png"];
		}
        
        yesImage = [UIImage imageNamed:@"yes_btn.png"];
        noImage = [UIImage imageNamed:@"no_btn.png"];
        maybeImage = [UIImage imageNamed:@"maybe_btn.png"];
        declineImage = [UIImage imageNamed:@"decline_btn.png"];
        changetimeImage = [UIImage imageNamed:@"change_time_btn.png"];
        
        units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit;
        
        profileImagePixels = 200;
        profileThumbImagePixels = 35;
    }
    
    return self;
}

-(UITextField *) createCellTextField:(CGFloat)width textHeight:(CGFloat) height placeholder:(NSString *)placeholderLabel inputAccessoryView:(UIToolbar *)toolBar {
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, -2, width - 30, height)];
    
    //textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.clearsOnBeginEditing = NO;
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    textField.textColor = [[UIColor alloc] initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];//initWithRed:headerDetailColorRed green:headerDetailColorGreen blue:headerDetailColorBlue [UIColor blackColor];
    textField.font = [UIFont fontWithName:cellFont size:cellFontSize];
    textField.placeholder = placeholderLabel;
    textField.inputAccessoryView = toolBar;
    
    return textField;
}

-(UITextField *) createBorderedTextField {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 249.0, 43.0)];
    
    textField.borderStyle = UITextBorderStyleNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.ContentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.cornerRadius = 10;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [[[UIColor alloc] initWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0] CGColor];
    textField.clearsOnBeginEditing = NO;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont fontWithName:cellFont size:cellFontSize];
    
    return textField;
}

-(UILabel *) createTableViewHeaderLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [[UIColor alloc] initWithRed:headerColorRed green:headerColorGreen blue:headerColorBlue alpha:1.0];
    lbl.font = [UIFont fontWithName:headerFont size:headerFontSize];
    
    return lbl;
}

-(UILabel *) createSmallGreenLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
    lbl.font = [UIFont fontWithName:headerDetailFont size:12.0];
    
    return lbl;
}

-(UILabel *) createTableViewHeaderDetailLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 15.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [UIColor grayColor];//initWithRed:headerDetailColorRed green:headerDetailColorGreen blue:headerDetailColorBlue alpha:1.0];
    lbl.font = [UIFont fontWithName:headerDetailFont size:headerDetailFontSize];
    
    return lbl;    
}

-(UILabel *) createTableViewHeaderDetailBlueLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 15.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [[UIColor alloc] initWithRed:headerDetailColorRed green:headerDetailColorGreen blue:headerDetailColorBlue alpha:1.0];
    lbl.font = [UIFont fontWithName:headerFont size:headerDetailFontSize];
    
    return lbl;
}

-(UILabel *) createTableViewFooterLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [[UIColor alloc] initWithRed:footerColorRed green:footerColorGreen blue:footerColorBlue alpha:1.0];
    lbl.font = [UIFont fontWithName:footerFont size:footerFontSize];
    
    return lbl;
}

-(UILabel *) createTableViewFooterDetailLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 15.0, 300.0, 20.0)];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [[UIColor alloc] initWithRed:footerDetailColorRed green:footerDetailColorGreen blue:footerDetailColorBlue alpha:1.0];
    lbl.font = [UIFont fontWithName:footerFont size:footerDetailFontSize];
    
    return lbl;    
}

-(UIButton *) createButton:(NSString *)title {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 30.0)];
    
    button.clipsToBounds = YES;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:buttonFont size:buttonFontSize];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setBackgroundImage:[UIImage imageNamed:@"action_button_bg.png"] forState:UIControlStateNormal];
	if ([title isEqualToString:@""] == FALSE) {
		[button setBackgroundImage:[UIImage imageNamed:@"action_button_pressed_bg.png"] forState:UIControlStateHighlighted];
	}
    
    return button;    
}

-(UILabel *) createEventViewDetailsLabel {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 65.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [UIColor grayColor];
    lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
    
    return lbl;
}


@end

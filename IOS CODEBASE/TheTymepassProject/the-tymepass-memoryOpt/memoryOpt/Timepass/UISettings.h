//
//  FontSettings.h
//  Timepass
//
//  Created by Mahmood1 on 22/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UISettings : NSObject {
    NSString *appFont;
    NSString *appFontBold;
    
    NSString *headerFont;
    NSString *headerDetailFont;
    NSString *footerFont;
    NSString *footerDetailFont;
    NSString *cellFont;
    NSString *cellDetailFont;
    NSString *textViewFont;
    NSString *buttonFont;
    NSString *monthCalendarDayNumberFont;
    NSString *dayCalendarHoursFont;
    
    float headerFontSize;
    float headerDetailFontSize;
    float footerFontSize;
    float footerDetailFontSize;
    float cellFontSize;
    float cellDetailFontSize;
    float textViewFontSize;
    float buttonFontSize;
    float monthCalendarDayNumberFontSize;
    float dayCalendarHoursFontSize;
    
    float headerColorRed;
    float headerColorGreen; 
    float headerColorBlue;
    float headerDetailColorRed;
    float headerDetailColorGreen;
    float headerDetailColorBlue;
    float footerColorRed;
    float footerColorGreen; 
    float footerColorBlue;
    float footerDetailColorRed;
    float footerDetailColorGreen;
    float footerDetailColorBlue;
    float cellColorRed;
    float cellColorGreen;
    float cellColorBlue;
    float cellDetailColorRed;
    float cellDetailColorGreen;
    float cellDetailColorBlue;
    float textViewColorRed;
    float textViewColorGreen;
    float textViewColorBlue;
    float navigationBarTintColorRed;
    float navigationBarTintColorGreen;
    float navigationBarTintColorBlue;
    float buttonBackgroundColorRed;
    float buttonBackgroundColorGreen;
    float buttonBackgroundColorBlue;
    float monthCalendarDayNumberColorRed;
    float monthCalendarDayNumberColorGreen;
    float monthCalendarDayNumberColorBlue;
    float dayCalendarHoursColorRed;
    float dayCalendarHoursColorGreen;
    float dayCalendarHoursColorBlue;
    
    UIImage *backgroundImage;
    
    UIImage *yesImage;
    UIImage *noImage;
    UIImage *maybeImage;
    UIImage *declineImage;
    UIImage *changetimeImage;
    
    unsigned units;
    
    float profileImagePixels;
    float profileThumbImagePixels;
}

@property (nonatomic, retain) NSString *appFont;
@property (nonatomic, retain) NSString *appFontBold;

@property (nonatomic, retain) NSString *headerFont;
@property (nonatomic, retain) NSString *headerDetailFont;
@property (nonatomic, retain) NSString *footerFont;
@property (nonatomic, retain) NSString *footerDetailFont;
@property (nonatomic, retain) NSString *cellFont;
@property (nonatomic, retain) NSString *cellDetailFont;
@property (nonatomic, retain) NSString *textViewFont;
@property (nonatomic, retain) NSString *buttonFont;
@property (nonatomic, retain) NSString *monthCalendarDayNumberFont;
@property (nonatomic, retain) NSString *dayCalendarHoursFont;

@property (nonatomic) float headerFontSize;
@property (nonatomic) float headerDetailFontSize;
@property (nonatomic) float footerFontSize;
@property (nonatomic) float footerDetailFontSize;
@property (nonatomic) float cellFontSize;
@property (nonatomic) float cellDetailFontSize;
@property (nonatomic) float textViewFontSize;
@property (nonatomic) float buttonFontSize;
@property (nonatomic) float monthCalendarDayNumberFontSize;
@property (nonatomic) float dayCalendarHoursFontSize;

@property (nonatomic) float headerColorRed;
@property (nonatomic) float headerColorGreen;
@property (nonatomic) float headerColorBlue;
@property (nonatomic) float headerDetailColorRed;
@property (nonatomic) float headerDetailColorGreen;
@property (nonatomic) float headerDetailColorBlue;
@property (nonatomic) float footerColorRed;
@property (nonatomic) float footerColorGreen;
@property (nonatomic) float footerColorBlue;
@property (nonatomic) float footerDetailColorRed;
@property (nonatomic) float footerDetailColorGreen;
@property (nonatomic) float footerDetailColorBlue;
@property (nonatomic) float cellColorRed;
@property (nonatomic) float cellColorGreen;
@property (nonatomic) float cellColorBlue;
@property (nonatomic) float cellDetailColorRed;
@property (nonatomic) float cellDetailColorGreen;
@property (nonatomic) float cellDetailColorBlue;
@property (nonatomic) float textViewColorRed;
@property (nonatomic) float textViewColorGreen;
@property (nonatomic) float textViewColorBlue;
@property (nonatomic) float navigationBarTintColorRed;
@property (nonatomic) float navigationBarTintColorGreen;
@property (nonatomic) float navigationBarTintColorBlue;
@property (nonatomic) float buttonBackgroundColorRed;
@property (nonatomic) float buttonBackgroundColorGreen;
@property (nonatomic) float buttonBackgroundColorBlue;
@property (nonatomic) float monthCalendarDayNumberColorRed;
@property (nonatomic) float monthCalendarDayNumberColorGreen;
@property (nonatomic) float monthCalendarDayNumberColorBlue;
@property (nonatomic) float dayCalendarHoursColorRed;
@property (nonatomic) float dayCalendarHoursColorGreen;
@property (nonatomic) float dayCalendarHoursColorBlue;

@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic) unsigned units;

@property (nonatomic) float profileImagePixels;
@property (nonatomic) float profileThumbImagePixels;


@property (nonatomic, retain) UIImage *yesImage;
@property (nonatomic, retain) UIImage *noImage;
@property (nonatomic, retain) UIImage *maybeImage;
@property (nonatomic, retain) UIImage *declineImage;
@property (nonatomic, retain) UIImage *changetimeImage;

-(UITextField *) createCellTextField:(CGFloat)width textHeight:(CGFloat) height placeholder:(NSString *)placeholderLabel inputAccessoryView:(UIToolbar *)toolBar;
-(UITextField *) createBorderedTextField;
-(UILabel *) createTableViewHeaderLabel;
-(UILabel *) createTableViewHeaderDetailLabel;
-(UILabel *) createTableViewHeaderDetailBlueLabel;
-(UILabel *) createTableViewFooterLabel;
-(UILabel *) createTableViewFooterDetailLabel;
-(UIButton *) createButton:(NSString *)title;
-(UILabel *) createEventViewDetailsLabel;
-(UILabel *) createSmallGreenLabel;

@end

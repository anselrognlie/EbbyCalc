//
//  ViewController.m
//  Minidesk Calculator
//
//  Created by Ansel Rognlie on 10/23/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

#import "ViewController.h"

#import "EWCGridLayoutView.h"
#import "EWCRoundedCornerButton.h"
#import "EWCCalculator.h"
#import "EWCCalculatorUserDefaultsData.h"

typedef NS_ENUM(NSInteger, EWCApplicationLayout) {
  EWCApplicationRegularDefaultLayout = 0,
  EWCApplicationRegularWideLayout = 1,
  EWCApplicationRegularTallLayout,
  EWCApplicationCompactWideLayout,
  EWCApplicationCompactTallLayout,
};

@interface ViewController () {
  IBOutlet EWCGridLayoutView *_grid;
  IBOutlet UILabel *_displayArea;
  IBOutlet NSLayoutConstraint *_gridTopConstraint;
  IBOutlet NSLayoutConstraint *_gridBottomConstraint;
  EWCApplicationLayout _layout;
  CGFloat _layoutWidth;
  CGFloat _layoutHeight;
  IBOutlet UIStackView *_statusDisplay;
  IBOutlet UILabel *_memoryIndicator;
  IBOutlet UILabel *_errorIndicator;
  IBOutlet UILabel *_taxIndicator;
  IBOutlet UILabel *_taxPlusIndicator;
  IBOutlet UILabel *_taxMinusIndicator;
  IBOutlet UILabel *_taxPercentIndicator;
  IBOutlet NSLayoutConstraint *_statusLeftConstraint;
  NSLayoutConstraint *_statusRightConstraint;
  NSMutableArray<UILabel *> *_statusLabels;
  NSMutableArray<EWCRoundedCornerButton *> *_textButtons;
  NSMutableArray<EWCRoundedCornerButton *> *_digitButtons;
  NSMutableArray<EWCRoundedCornerButton *> *_opButtons;
  NSMutableArray<EWCRoundedCornerButton *> *_allButtons;
  EWCCalculator *_calculator;
  UIButton *_clearButton;
  UIButton *_taxPlusButton;
  UIButton *_taxMinusButton;
}

@property (nonatomic) BOOL memoryVisible;
@property (nonatomic) BOOL errorVisible;
@property (nonatomic) BOOL taxVisible;
@property (nonatomic) BOOL taxPlusVisible;
@property (nonatomic) BOOL taxMinusVisible;
@property (nonatomic) BOOL taxPercentVisible;

@end

static const float TEXT_SIZE_AS_PERCENT_OF_WIDTH = 0.049;
static const float STATUS_SIZE_AS_PERCENT_OF_WIDTH = 0.024;
static const float DIGIT_SIZE_AS_PERCENT_OF_WIDTH = 0.049 * 2;
static const float OP_SIZE_AS_PERCENT_OF_WIDTH = 0.049 * 2;
static const float DISPLAY_FONT_SIZE_AS_PERCENT_OF_WIDE = 0.126;
static const float DISPLAY_FONT_SIZE_AS_PERCENT_OF_TALL = 0.180;
//static const float DISPLAY_HEIGHT_FROM_FONT = 1.390;
static const float DISPLAY_HEIGHT_FROM_FONT = 1.500;
static const float TWO_GRID_HEIGHT_WIDTH_RATIO = 1.900;

@implementation ViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

+ (UIColor *)regularTextColor {
  return [UIColor darkGrayColor];
}

+ (UIColor *)shiftedTextColor {
  return [UIColor colorWithRed:.1 green:.5 blue:.7 alpha:1];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _layout = EWCApplicationRegularDefaultLayout;
  _layoutWidth = 0;
  _layoutHeight = 0;

  _textButtons = [NSMutableArray<EWCRoundedCornerButton *> new];
  _digitButtons = [NSMutableArray<EWCRoundedCornerButton *> new];
  _opButtons = [NSMutableArray<EWCRoundedCornerButton *> new];
  _allButtons = [NSMutableArray<EWCRoundedCornerButton *> new];

  _displayArea.adjustsFontSizeToFitWidth = YES;
  _displayArea.minimumScaleFactor = .25;

  [self setupCalculator];

  // Do any additional setup after loading the view.
  [self setupGrid];

  [self updateDisplayFromCalculator];
}

- (void)setupCalculator {
  _calculator = [EWCCalculator new];
  
  __weak ViewController *controller = self;
  [_calculator registerUpdateCallbackWithBlock:^{
    [controller updateDisplayFromCalculator];
  }];

//  _calculator.maximumDigits = 2;
  _calculator.maximumDigits = 16;
  _calculator.dataProvider = [EWCCalculatorUserDefaultsData new];
}

- (void)setupGrid {

  CGFloat width = self.view.bounds.size.width;

  _grid.rows = @[@1.0, @1.0, @1.0, @1.0, @1.0];
  _grid.columns = @[@1.0, @1.0, @1.0, @1.0, @1.0, @1.0];
  _grid.minRowGutter = .02;
  _grid.minColumnGutter = .02;

  // add buttons
  [self addButtons];

  // constrain status trailing to rate button
  _statusRightConstraint = [NSLayoutConstraint
    constraintWithItem:_statusDisplay attribute:NSLayoutAttributeTrailing
    relatedBy:NSLayoutRelationEqual
    toItem:self.view attribute:NSLayoutAttributeTrailing
    multiplier:1.0 constant:[self getTrailingStatusConstant:width]];
  [self.view addConstraint:_statusRightConstraint];
  _statusLeftConstraint.constant = [self getLeadingStatusConstant:width];

  _statusLabels = [@[
    _memoryIndicator,
    _errorIndicator,
    _taxIndicator,
    _taxPlusIndicator,
    _taxMinusIndicator,
    _taxPercentIndicator,
  ] mutableCopy];

}

- (void)addButtons {
  EWCRoundedCornerButton *button = nil;

  CGRect screen = self.view.bounds;
  CGFloat sWidth = screen.size.width, sHeight = screen.size.height;
  CGFloat fontDim = (sWidth < sHeight) ? sWidth : sHeight;

  button = [self makeDigitButton:NSLocalizedString(@"Zero Button", @"label for the 0 button")
    accessibilityLabel:NSLocalizedString(@"Zero Aria Label", @"voiceover label for the 0 button")
    action:@selector(onZeroButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"One Button", @"label for the 1 button")
    accessibilityLabel:NSLocalizedString(@"One Aria Label", @"voiceover label for the 1 button")
    action:@selector(onOneButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Two Button", @"label for the 2 button")
    accessibilityLabel:NSLocalizedString(@"Two Aria Label", @"voiceover label for the 2 button")
    action:@selector(onTwoButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Three Button", @"label for the 3 button")
    accessibilityLabel:NSLocalizedString(@"Three Aria Label", @"voiceover label for the 3 button")
    action:@selector(onThreeButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Four Button", @"label for the 4 button")
    accessibilityLabel:NSLocalizedString(@"Four Aria Label", @"voiceover label for the 4 button")
    action:@selector(onFourButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Five Button", @"label for the 5 button")
    accessibilityLabel:NSLocalizedString(@"Five Aria Label", @"voiceover label for the 5 button")
    action:@selector(onFiveButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Six Button", @"label for the 6 button")
    accessibilityLabel:NSLocalizedString(@"Six Aria Label", @"voiceover label for the 6 button")
    action:@selector(onSixButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Seven Button", @"label for the 7 button")
    accessibilityLabel:NSLocalizedString(@"Seven Aria Label", @"voiceover label for the 7 button")
    action:@selector(onSevenButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Eight Button", @"label for the 8 button")
    accessibilityLabel:NSLocalizedString(@"Eight Aria Label", @"voiceover label for the 8 button")
    action:@selector(onEightButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Nine Button", @"label for the 9 button")
    accessibilityLabel:NSLocalizedString(@"Nine Aria Label", @"voiceover label for the 9 button")
    action:@selector(onNineButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Clear Button", "label for the button that clears the input")
    accessibilityLabel:NSLocalizedString(@"Clear Aria Label", @"voiceover label for the button that clears the input")
    action:@selector(onClearButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  _clearButton = button;
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Rate Button", "label for the button that switches to tax rate management mode")
    accessibilityLabel:NSLocalizedString(@"Rate Aria Label", @"voiceover label for the button that switches to tax rate management mode")
    action:@selector(onRateButtonPressed:forEvent:) forWidth:fontDim];
  [button setTitleColor:[ViewController shiftedTextColor]
    forState:UIControlStateNormal];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Tax+ Button", "label for the button that adds tax to the current value")
    accessibilityLabel:NSLocalizedString(@"Tax+ Aria Label", @"voiceover label for the button that adds tax to the current value")
    action:@selector(onTaxPlusButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  _taxPlusButton = button;
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Tax- Button", "label for the button that removes tax from the current value")
    accessibilityLabel:NSLocalizedString(@"Tax- Aria Label", @"voiceover label for the button that removes tax from the current value")
    action:@selector(onTaxMinusButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  _taxMinusButton = button;
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory Button", @"label for the button that retrieves and clears the memory")
    accessibilityLabel:NSLocalizedString(@"Memory Aria Label", @"voiceover label for the button that retrieves and clears the memory")
    action:@selector(onMemoryButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory+ Button", @"label for the button that adds to the memory")
    accessibilityLabel:NSLocalizedString(@"Memory+ Aria Label", @"voiceover label for the button that adds to the memory")
    action:@selector(onMemoryPlusButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory- Button", @"label for the button that subtracts from the memory")
    accessibilityLabel:NSLocalizedString(@"Memory- Aria Label", @"voiceover label for the button that subtracts from the memory")
    action:@selector(onMemoryMinusButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Add Button", @"label for the button that performs addition")
    accessibilityLabel:NSLocalizedString(@"Add Aria Label", @"voiceover label for the button that performs addition")
    action:@selector(onAddButtonPressed:forEvent:) forWidth:fontDim];
  [_opButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Subtract Button", @"label for the button that performs subtraction")
    accessibilityLabel:NSLocalizedString(@"Subtract Aria Label", @"voiceover label for the button that performs subtraction")
    action:@selector(onSubtractButtonPressed:forEvent:) forWidth:fontDim];
  [_opButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Multiply Button", @"label for the button that performs multiplication")
    accessibilityLabel:NSLocalizedString(@"Multiply Aria Label", @"voiceover label for the button that performs multiplication")
    action:@selector(onMultiplyButtonPressed:forEvent:) forWidth:fontDim];
  [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
  [_opButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Divide Button", @"label for the button that performs division")
    accessibilityLabel:NSLocalizedString(@"Divide Aria Label", @"voiceover label for the button that performs division")
    action:@selector(onDivideButtonPressed:forEvent:) forWidth:fontDim];
  [_opButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Sign Button", @"label for the button that toggles the sign")
    accessibilityLabel:NSLocalizedString(@"Sign Aria Label", @"voiceover label for the button that toggles the sign")
    action:@selector(onSignButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Decimal Button", @"label for the button that designates the decimal point")
    accessibilityLabel:NSLocalizedString(@"Decimal Aria Label", @"voiceover label for the button that designates the decimal point")
    action:@selector(onDecimalButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Percent Button", @"label for the button that take percents")
    accessibilityLabel:NSLocalizedString(@"Percent Aria Label", @"voiceover label for the button that take percents")
    action:@selector(onPercentButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Sqrt Button", @"label for the button that performs square roots")
    accessibilityLabel:NSLocalizedString(@"Sqrt Aria Label", @"voiceover label for the button that performs square roots")
    action:@selector(onSqrtButtonPressed:forEvent:) forWidth:fontDim];
  [_textButtons addObject:button];
  [_allButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Equal Button", @"label for the button that executes operations")
    accessibilityLabel:NSLocalizedString(@"Equal Aria Label", @"voiceover label for the button that executes operations")
    action:@selector(onEqualButtonPressed:forEvent:) forWidth:fontDim];
  [_digitButtons addObject:button];
  [_allButtons addObject:button];
}

- (void)layoutGrid {

  EWCGridCustomLayoutCallback callback = ^(UIView *view, CGRect frame, CGFloat minWidth, CGFloat minHeight) {
    NSInteger radius = (NSInteger)((minWidth < minHeight) ? minWidth : minHeight) / 2;

    EWCRoundedCornerButton *button = (EWCRoundedCornerButton *)view;
    button.frame = frame;
    button.cornerRadius = radius;
  };

  if (_layout == EWCApplicationRegularTallLayout) {
    // tall

    // configure grid layout
    _grid.rows = @[@1.0, @1.0, @1.0, @1.0, @1.0, @1.0, @1.0, @1.0, @1.0];
    _grid.columns = @[@1.0, @1.0, @1.0];

    // rehome buttons
    [_grid addSubView:_allButtons[EWCCalculatorZeroKey] inRow:8 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorOneKey] inRow:7 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorTwoKey] inRow:7 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorThreeKey] inRow:7 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorFourKey] inRow:6 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorFiveKey] inRow:6 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorSixKey] inRow:6 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorSevenKey] inRow:5 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorEightKey] inRow:5 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorNineKey] inRow:5 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorClearKey] inRow:2 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorRateKey] inRow:0 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorTaxPlusKey] inRow:0 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorTaxMinusKey] inRow:0 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryKey] inRow:1 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryPlusKey] inRow:1 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryMinusKey] inRow:1 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorAddKey] startingInRow:3 column:2 endingInRow:4 column:2 withLayout:callback];
    [_grid addSubView:_allButtons[EWCCalculatorSubtractKey] inRow:4 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorMultiplyKey] inRow:3 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorDivideKey] inRow:3 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorSignKey] inRow:4 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorDecimalKey] inRow:8 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorPercentKey] inRow:2 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorSqrtKey] inRow:2 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorEqualKey] inRow:8 column:2];

  } else {
    // wide

    // configure grid layout
    _grid.rows = @[@1.0, @1.0, @1.0, @1.0, @1.0];
    _grid.columns = @[@1.0, @1.0, @1.0, @1.0, @1.0, @1.0];

    // rehome buttons
    [_grid addSubView:_allButtons[EWCCalculatorZeroKey] inRow:4 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorOneKey] inRow:3 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorTwoKey] inRow:3 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorThreeKey] inRow:3 column:3];
    [_grid addSubView:_allButtons[EWCCalculatorFourKey] inRow:2 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorFiveKey] inRow:2 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorSixKey] inRow:2 column:3];
    [_grid addSubView:_allButtons[EWCCalculatorSevenKey] inRow:1 column:1];
    [_grid addSubView:_allButtons[EWCCalculatorEightKey] inRow:1 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorNineKey] inRow:1 column:3];
    [_grid addSubView:_allButtons[EWCCalculatorClearKey] inRow:1 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorRateKey] inRow:0 column:3];
    [_grid addSubView:_allButtons[EWCCalculatorTaxPlusKey] inRow:0 column:4];
    [_grid addSubView:_allButtons[EWCCalculatorTaxMinusKey] inRow:0 column:5];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryKey] inRow:2 column:5];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryPlusKey] inRow:4 column:5];
    [_grid addSubView:_allButtons[EWCCalculatorMemoryMinusKey] inRow:3 column:5];
    [_grid addSubView:_allButtons[EWCCalculatorAddKey] startingInRow:3 column:4 endingInRow:4 column:4 withLayout:callback];
    [_grid addSubView:_allButtons[EWCCalculatorSubtractKey] inRow:2 column:4];
    [_grid addSubView:_allButtons[EWCCalculatorMultiplyKey] inRow:1 column:4];
    [_grid addSubView:_allButtons[EWCCalculatorDivideKey] inRow:1 column:5];
    [_grid addSubView:_allButtons[EWCCalculatorSignKey] inRow:2 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorDecimalKey] inRow:4 column:2];
    [_grid addSubView:_allButtons[EWCCalculatorPercentKey] inRow:3 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorSqrtKey] inRow:4 column:0];
    [_grid addSubView:_allButtons[EWCCalculatorEqualKey] inRow:4 column:3];
  }
}

- (EWCRoundedCornerButton *)makeMainOperatorButton:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeOperatorButton:label
    accessibilityLabel:accessibilityLabel
    action:selector
    withSize:OP_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeSubOperatorButton:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeOperatorButton:label
    accessibilityLabel:accessibilityLabel
    action:selector
    withSize:TEXT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeOperatorButton:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  withSize:(float)points {

  return [self makeCalculatorButtonWithLabel:label
    accessibilityLabel:accessibilityLabel
    action:selector
    colored:[UIColor whiteColor]
    highlightColor:[UIColor colorWithRed:1.0 green:204.0/255 blue:136.0/255 alpha:1.0]
    backgroundColor:[UIColor orangeColor]
    fontSize:points];
}

- (EWCRoundedCornerButton *)makeDigitButton:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeCalculatorButtonWithLabel:label
    accessibilityLabel:accessibilityLabel
    action:selector
    colored:[UIColor whiteColor]
    highlightColor:[UIColor lightGrayColor]
    backgroundColor:[UIColor darkGrayColor]
    fontSize:DIGIT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeTextButton:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeCalculatorButtonWithLabel:label
    accessibilityLabel:accessibilityLabel
    action:selector
    colored:[ViewController regularTextColor]
    highlightColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]
    backgroundColor:[UIColor lightGrayColor]
    fontSize:TEXT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeCalculatorButtonWithLabel:(NSString *)label
  accessibilityLabel:(NSString *)accessibilityLabel
  action:(SEL)selector
  colored:(UIColor *)color
  highlightColor:(UIColor *)highlight
  backgroundColor:(UIColor *)backgroundColor
  fontSize:(CGFloat)fontSize {

  EWCRoundedCornerButton *button = [EWCRoundedCornerButton buttonLabeled:label
    colored:color
    backgroundColor:backgroundColor];
  button.accessibilityLabel = accessibilityLabel;
  button.highlightedBackgroundColor = highlight;
  button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
  [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

  button.customPointTest = ^BOOL (CGPoint point, UIEvent * _Nullable event, EWCRoundedCornerDefaultPointTest defaultTest) {
    if (UIAccessibilityIsVoiceOverRunning()) {
      return defaultTest(point, event);
    }

    return NO;
  };

  return button;
}

- (void)viewWillLayoutSubviews {
  UIUserInterfaceSizeClass hClass = self.traitCollection.horizontalSizeClass;
//  UIUserInterfaceSizeClass vClass = self.traitCollection.verticalSizeClass;

  switch (hClass) {
    case UIUserInterfaceSizeClassUnspecified:
    case UIUserInterfaceSizeClassRegular:
      [self applyRegularLayout];
      break;

    case UIUserInterfaceSizeClassCompact:
      [self applyRegularLayout];
      break;
  }
}

-(void)viewDidLayoutSubviews {
}

- (float)getTrailingStatusConstant:(CGFloat)width {
  return -20 - width * _grid.minColumnGutter;
}

- (float)getLeadingStatusConstant:(CGFloat)width {
  return 20 + width * _grid.minColumnGutter;
}

- (void)applyRegularLayout {
  UIEdgeInsets insets = self.view.safeAreaInsets;

  CGFloat width = self.view.bounds.size.width - insets.right - insets.left;
  CGFloat height = self.view.bounds.size.height - insets.top - insets.bottom;

  if (width == _layoutWidth && height == _layoutHeight) { return; }

  EWCApplicationLayout oldLayout = _layout;
  float aspectRatio = height / width;
  _layout = (aspectRatio >= TWO_GRID_HEIGHT_WIDTH_RATIO)
    ? EWCApplicationRegularTallLayout
    : EWCApplicationCompactWideLayout;

  if (_layout != oldLayout) {
    [self layoutGrid];
  }

  if (width > height) {
    // use height as minimal dimension

    // make the bottom of the display depend on screen size
    CGFloat fontHeight = height * DISPLAY_FONT_SIZE_AS_PERCENT_OF_WIDE;
    CGFloat displayHeight = fontHeight * DISPLAY_HEIGHT_FROM_FONT;
    [_displayArea setFont:[_displayArea.font fontWithSize:fontHeight]];

    _gridTopConstraint.constant = -height + displayHeight + _gridBottomConstraint.constant;
    _grid.cellStyle = EWCGridLayoutCellFillStyle;

  } else {  // width <= height
    // use width as minimum dimension

    // calculate a height that allows the grid height to equal its width
    CGFloat fontHeight = width * DISPLAY_FONT_SIZE_AS_PERCENT_OF_TALL;
    CGFloat displayHeight = fontHeight * DISPLAY_HEIGHT_FROM_FONT;
    [_displayArea setFont:[_displayArea.font fontWithSize:fontHeight]];

    // allow bottom of display to float
    _gridTopConstraint.constant = -height + displayHeight + _gridBottomConstraint.constant;
    _grid.cellStyle = EWCGridLayoutCellAspectRatioStyle;
    _grid.cellAspectRatio = 1.0;
  }

  _layoutWidth = width;
  _layoutHeight = height;

  // for either case, adjust the button text sizes
  CGFloat fontDim = (width < height) ? width : height;

  CGFloat textSize = fontDim * TEXT_SIZE_AS_PERCENT_OF_WIDTH;
  CGFloat digitSize = fontDim * DIGIT_SIZE_AS_PERCENT_OF_WIDTH;
  CGFloat opSize = fontDim * OP_SIZE_AS_PERCENT_OF_WIDTH;

  [self setTextButtonsFontSize:textSize];
  [self setDigitButtonsFontSize:digitSize];
  [self setOperatorButtonsFontSize:opSize];

  [self setStatusFontSize:fontDim * STATUS_SIZE_AS_PERCENT_OF_WIDTH];
  _statusRightConstraint.constant = [self getTrailingStatusConstant:width];
  _statusLeftConstraint.constant = [self getLeadingStatusConstant:width];
}

- (void)setFontSize:(CGFloat)points forButtons:(NSArray<UIButton *> *)buttons {
  // don't update if the buttons haven't been registered yet
  if (buttons.count == 0) { return; }

  UIFont *font = [buttons[0].titleLabel.font fontWithSize:points];
  for (UIButton *button in buttons) {
    [button.titleLabel setFont:font];
  }
}

- (void)setTextButtonsFontSize:(CGFloat)points {
  [self setFontSize:points forButtons:_textButtons];
}

- (void)setDigitButtonsFontSize:(CGFloat)points {
  [self setFontSize:points forButtons:_digitButtons];
}

- (void)setOperatorButtonsFontSize:(CGFloat)points {
  [self setFontSize:points forButtons:_opButtons];

  UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, points * 0.200, 0);

  for (UIButton *button in _opButtons) {
    [button setTitleEdgeInsets:inset];
  }
}

- (void)setStatusFontSize:(CGFloat)points {
  UIFont *font = [_statusLabels[0].font fontWithSize:points];
  for (UILabel *label in _statusLabels) {
    label.font = font;
  }
}

- (void)onRateButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorRateKey];
}

- (void)onTaxPlusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorTaxPlusKey];
}

- (void)onTaxMinusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorTaxMinusKey];
}

- (void)onClearButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorClearKey];
}

- (void)onSevenButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorSevenKey];
}

- (void)onEightButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorEightKey];
}

- (void)onNineButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorNineKey];
}

- (void)onMultiplyButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorMultiplyKey];
}

- (void)onDivideButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorDivideKey];
}

- (void)onSignButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorSignKey];
}

- (void)onFourButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorFourKey];
}

- (void)onFiveButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorFiveKey];
}

- (void)onSixButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorSixKey];
}

- (void)onSubtractButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorSubtractKey];
}

- (void)onMemoryButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorMemoryKey];
}

- (void)onPercentButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorPercentKey];
}

- (void)onOneButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorOneKey];
}

- (void)onTwoButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorTwoKey];
}

- (void)onThreeButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorThreeKey];
}

- (void)onAddButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorAddKey];
}

- (void)onMemoryMinusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorMemoryMinusKey];
}

- (void)onSqrtButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorSqrtKey];
}

- (void)onZeroButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorZeroKey];
}

- (void)onDecimalButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorDecimalKey];
}

- (void)onEqualButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorEqualKey];
}

- (void)onMemoryPlusButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {
  [_calculator pressKey:EWCCalculatorMemoryPlusKey];
}

- (BOOL)isMemoryVisible {
  return ! _memoryIndicator.hidden;
}

- (void)setMemoryVisible:(BOOL)value {
  _memoryIndicator.hidden = ! value;
}

- (BOOL)isErrorVisible {
  return ! _errorIndicator.hidden;
}

- (void)setErrorVisible:(BOOL)value {
  _errorIndicator.hidden = ! value;
}

- (BOOL)isTaxVisible {
  return ! _taxIndicator.hidden;
}

- (void)setTaxVisible:(BOOL)value {
  _taxIndicator.hidden = ! value;
}

- (BOOL)isTaxPlusVisible {
  return ! _taxPlusIndicator.hidden;
}

- (void)setTaxPlusVisible:(BOOL)value {
  _taxPlusIndicator.hidden = ! value;
}

- (BOOL)isTaxMinusVisible {
  return ! _taxMinusIndicator.hidden;
}

- (void)setTaxMinusVisible:(BOOL)value {
  _taxMinusIndicator.hidden = ! value;
}

- (BOOL)isTaxPercentVisible {
  return ! _taxPercentIndicator.hidden;
}

- (void)setTaxPercentVisible:(BOOL)value {
  _taxPercentIndicator.hidden = ! value;
}

- (void)updateClearLabel {
  NSString *label = (_calculator.isErrorStatusVisible)
    ? NSLocalizedString(@"All Clear Button", @"voiceover label for the clear button when there is an error")
    : NSLocalizedString(@"Clear Button", @"");
  NSString *ariaLabel = (_calculator.isErrorStatusVisible)
    ? NSLocalizedString(@"All Clear Aria Label", @"voiceover label for the clear button when there is an error")
    : NSLocalizedString(@"Clear Aria Label", @"");
  [_clearButton setTitle:label forState:UIControlStateNormal];
  _clearButton.accessibilityLabel = ariaLabel;
}

- (void)updateTaxLabels {
  NSString *label;
  NSString *ariaLabel;

  label = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Store Button", @"label for storing a new tax rate")
    : NSLocalizedString(@"Tax+ Button", @"");
  ariaLabel = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Store Aria Label", @"voiceover label for storing a new tax rate")
    : NSLocalizedString(@"Tax+ Aria Label", @"");
  [_taxPlusButton setTitle:label forState:UIControlStateNormal];
  _taxPlusButton.accessibilityLabel = ariaLabel;

  label = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Recall Button", @"label for reviewing the current tax rate")
    : NSLocalizedString(@"Tax- Button", @"");
  ariaLabel = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Recall Aria Label", @"voiceover label for reviewing the current tax rate")
    : NSLocalizedString(@"Tax- Aria Label", @"");
  [_taxMinusButton setTitle:label forState:UIControlStateNormal];
  _taxMinusButton.accessibilityLabel = ariaLabel;

  UIColor *taxColor = (_calculator.isRateShifted)
    ? [ViewController shiftedTextColor]
    : [ViewController regularTextColor];

  [_taxPlusButton setTitleColor:taxColor forState:UIControlStateNormal];
  [_taxMinusButton setTitleColor:taxColor forState:UIControlStateNormal];
}

- (void)updateDisplayFromCalculator {
  self.memoryVisible = _calculator.isMemoryStatusVisible;
  self.errorVisible = _calculator.isErrorStatusVisible;
  self.taxVisible = _calculator.isTaxStatusVisible;
  self.taxPlusVisible = _calculator.isTaxPlusStatusVisible;
  self.taxMinusVisible = _calculator.isTaxMinusStatusVisible;
  self.taxPercentVisible = _calculator.isTaxPercentStatusVisible;

  [_displayArea setText:_calculator.displayContent];

  [self updateClearLabel];
  [self updateTaxLabels];
}

@end


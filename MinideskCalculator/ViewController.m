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

@implementation ViewController

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
  ] mutableCopy];

}

- (void)addButtons {
  EWCRoundedCornerButton *button = nil;

  CGRect screen = self.view.bounds;
  CGFloat sWidth = screen.size.width, sHeight = screen.size.height;
  CGFloat fontDim = (sWidth < sHeight) ? sWidth : sHeight;

  button = [self makeTextButton:NSLocalizedString(@"Rate Button", "label for the button that switches to tax rate management mode")
    action:@selector(onRateButtonPressed:forEvent:) forWidth:fontDim];
  [button setTitleColor:[ViewController shiftedTextColor]
    forState:UIControlStateNormal];
  [_grid addSubView:button inRow:0 column:3];
  [_textButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Tax+ Button", "label for the button that adds tax to the current value")
    action:@selector(onTaxPlusButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:0 column:4];
  [_textButtons addObject:button];
  _taxPlusButton = button;

  button = [self makeTextButton:NSLocalizedString(@"Tax- Button", "label for the button that removes tax from the current value")
    action:@selector(onTaxMinusButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:0 column:5];
  [_textButtons addObject:button];
  _taxMinusButton = button;

  button = [self makeTextButton:NSLocalizedString(@"Clear Button", "label for the button that clears the input")
    action:@selector(onClearButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:0];
  [_textButtons addObject:button];
  _clearButton = button;

  button = [self makeDigitButton:NSLocalizedString(@"Seven Button", @"label for the 7 button")
    action:@selector(onSevenButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:1];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Eight Button", @"label for the 8 button")
    action:@selector(onEightButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:2];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Nine Button", @"label for the 9 button")
    action:@selector(onNineButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:3];
  [_digitButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Multiply Button", @"label for the button that performs multiplication")
    action:@selector(onMultiplyButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:4];
  [_opButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Divide Button", @"label for the button that performs division")
    action:@selector(onDivideButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:1 column:5];
  [_opButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Sign Button", @"label for the button that toggles the sign")
    action:@selector(onSignButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:0];
  [_textButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Four Button", @"label for the 4 button")
    action:@selector(onFourButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:1];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Five Button", @"label for the 5 button")
    action:@selector(onFiveButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:2];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Six Button", @"label for the 6 button")
    action:@selector(onSixButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:3];
  [_digitButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Subtract Button", @"label for the button that performs subtraction")
    action:@selector(onSubtractButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:4];
  [_opButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory Button", @"label for the button that retrieves and clears the memory")
    action:@selector(onMemoryButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:2 column:5];
  [_textButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Percent Button", @"label for the button that take percents")
    action:@selector(onPercentButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:3 column:0];
  [_textButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"One Button", @"label for the 1 button")
    action:@selector(onOneButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:3 column:1];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Two Button", @"label for the 2 button")
    action:@selector(onTwoButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:3 column:2];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Three Button", @"label for the 3 button")
    action:@selector(onThreeButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:3 column:3];
  [_digitButtons addObject:button];

  button = [self makeMainOperatorButton:NSLocalizedString(@"Add Button", @"label for the button that performs addition")
    action:@selector(onAddButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button startingInRow:3 column:4 endingInRow:4 column:4];
  [_opButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory- Button", @"label for the button that subtracts from the memory")
    action:@selector(onMemoryMinusButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:3 column:5];
  [_textButtons addObject:button];

  button = [self makeSubOperatorButton:NSLocalizedString(@"Sqrt Button", @"label for the button that performs square roots")
    action:@selector(onSqrtButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:4 column:0];
  [_textButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Zero Button", @"label for the 0 button")
    action:@selector(onZeroButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:4 column:1];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Decimal Button", @"label for the button that designates the decimal point")
    action:@selector(onDecimalButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:4 column:2];
  [_digitButtons addObject:button];

  button = [self makeDigitButton:NSLocalizedString(@"Equal Button", @"label for the button that executes operations")
    action:@selector(onEqualButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:4 column:3];
  [_digitButtons addObject:button];

  button = [self makeTextButton:NSLocalizedString(@"Memory+ Button", @"label for the button that adds to the memory")
    action:@selector(onMemoryPlusButtonPressed:forEvent:) forWidth:fontDim];
  [_grid addSubView:button inRow:4 column:5];
  [_textButtons addObject:button];
}

- (EWCRoundedCornerButton *)makeMainOperatorButton:(NSString *)label
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeOperatorButton:label
    action:selector
    withSize:OP_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeSubOperatorButton:(NSString *)label
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeOperatorButton:label
    action:selector
    withSize:TEXT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeOperatorButton:(NSString *)label
  action:(SEL)selector
  withSize:(float)points {

  return [self makeCalculatorButtonWithLabel:label
    action:selector
    colored:[UIColor whiteColor]
    highlightColor:[UIColor colorWithRed:1.0 green:204.0/255 blue:136.0/255 alpha:1.0]
    backgroundColor:[UIColor orangeColor]
    fontSize:points];
}

- (EWCRoundedCornerButton *)makeDigitButton:(NSString *)label
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeCalculatorButtonWithLabel:label
    action:selector
    colored:[UIColor whiteColor]
    highlightColor:[UIColor lightGrayColor]
    backgroundColor:[UIColor darkGrayColor]
    fontSize:DIGIT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeTextButton:(NSString *)label
  action:(SEL)selector
  forWidth:(float)width {

  return [self makeCalculatorButtonWithLabel:label
    action:selector
    colored:[ViewController regularTextColor]
    highlightColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]
    backgroundColor:[UIColor lightGrayColor]
    fontSize:TEXT_SIZE_AS_PERCENT_OF_WIDTH * width];
}

- (EWCRoundedCornerButton *)makeCalculatorButtonWithLabel:(NSString *)label
  action:(SEL)selector
  colored:(UIColor *)color
  highlightColor:(UIColor *)highlight
  backgroundColor:(UIColor *)backgroundColor
  fontSize:(CGFloat)fontSize {

  EWCRoundedCornerButton *button = [EWCRoundedCornerButton buttonLabeled:label
    colored:color
    backgroundColor:backgroundColor];
  button.highlightedBackgroundColor = highlight;
  button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
  button.userInteractionEnabled = NO;
  [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

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
  return -20 - width / 2.0;
}

- (float)getLeadingStatusConstant:(CGFloat)width {
  return 20 + width * _grid.minColumnGutter;
}

- (void)applyRegularLayout {
  CGFloat width = self.view.bounds.size.width;
  CGFloat height = self.view.bounds.size.height;

  if (width == _layoutWidth && height == _layoutHeight) { return; }

  if (width > height) {
    // wide
    _layout = EWCApplicationRegularWideLayout;

    // make the bottom of the display depend on screen size
    CGFloat fontHeight = width * DISPLAY_FONT_SIZE_AS_PERCENT_OF_WIDE;
    CGFloat displayHeight = fontHeight * DISPLAY_HEIGHT_FROM_FONT;
    [_displayArea setFont:[_displayArea.font fontWithSize:fontHeight]];

    _gridTopConstraint.constant = -height + displayHeight + _gridBottomConstraint.constant;
    _grid.cellStyle = EWCGridLayoutCellFillStyle;

  } else {  // width <= height
    // tall
    _layout = EWCApplicationRegularTallLayout;

    // calculate a height that allows the grid height to equal its width
//    CGRect safeArea = self.view.safeAreaLayoutGuide.layoutFrame;
//    CGFloat safeWidth = safeArea.size.width;

    CGFloat fontHeight = width * DISPLAY_FONT_SIZE_AS_PERCENT_OF_TALL;
    CGFloat displayHeight = fontHeight * DISPLAY_HEIGHT_FROM_FONT;
    [_displayArea setFont:[_displayArea.font fontWithSize:fontHeight]];

    // allow bottom of display to float
//    _gridTopConstraint.constant = -safeWidth - _gridBottomConstraint.constant;
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

- (void)applyCompactLayout {
  _layout = EWCApplicationCompactTallLayout;
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
    ? NSLocalizedString(@"All Clear Button", @"label for the clear button when there is an error")
    : NSLocalizedString(@"Clear Button", @"label for the clear button when there is NO error");
  [_clearButton setTitle:label forState:UIControlStateNormal];
}

- (void)updateTaxLabels {
  NSString *label;

  label = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Store Button", @"label for storing a new tax rate")
    : NSLocalizedString(@"Tax+ Button", @"label for adding in tax");
  [_taxPlusButton setTitle:label forState:UIControlStateNormal];

  label = (_calculator.isRateShifted)
    ? NSLocalizedString(@"Recall Button", @"label for reviewing the current tax rate")
    : NSLocalizedString(@"Tax- Button", @"label for subtracting out tax");
  [_taxMinusButton setTitle:label forState:UIControlStateNormal];

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


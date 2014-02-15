# Usage Guide

1. Drag the files into your project and import them into your source file using, #import "JCSlider.h"
2. If you are using IB, remember to set the class type to the slider you intend to use, i.e. JCSlider or JCStopSlider.
3. Control drag from your slider to the source interface to wire up an IBOutlet.
4. Configure the slider using one of the included block methods. Basic examples below.

### JCSlider Configuration
```objc
- (void)configureSlider
{
    ViewController *__weak weakSelf = self;
    
    [self.slider handleValueChanged:^ (int value) {
        
        ViewController *strongSelf = weakSelf;
        
        strongSelf.valueLabel.text = [NSString stringWithFormat:@"%d", value];
    }];
}
```

### JCStopSlider Configuration w/ Stop Components

```objc
- (void)configureStopSlider
{
    self.stopSlider.stopComponents = @[@(0), @(20), @(40), @(60)];
    
     ViewController *__weak weakSelf = self;
    
    [self.stopSlider handleValueChanged:^(int value) {
        
        ViewController *strongSelf = weakSelf;
        
        strongSelf.valueLabel.text = [NSString stringWithFormat:@"%d", value];
    }];
}
```
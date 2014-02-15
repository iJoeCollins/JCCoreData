# Usage Guide

## Setup and Configuration

1. Drag the files into your project.
2. Add @class JCCoreData; to your .h file.
3. Add @property (strong, nonatomic) JCCoreData *coreData;
4. Import into your .m file using, #import "JCCoreData.h"
5. Add the coreData accessor method to use lazy loading.
```objc
- (JCCoreData *)coreData
{
    if (!_coreData) {
        _coreData = [JCCoreData new];
    }
    
    return _coreData;
}
```

6. Set your view controller's managed object context either using its associated reference or a property that you set yourself.
```objc
// Set the top view controllers associated managed object context
    navigationController.topViewController.managedObjectContext = self.coreData.managedObjectContext;
```
7. That's it! Just make sure and add a model file if you haven't already. Either name it "Model" or change this by editing the static variable at the top of the implementation. Future versions will allow you to set this in code.

### App Delegate Example Using JCCoreData's Category on UIViewController
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIViewController *viewController = self.window.rootViewController;
    
    viewController.managedObjectContext = self.coreData.managedObjectContext;

    return YES;
}

- (JCCoreData *)coreData
{
    if (!_coreData) {
        _coreData = [JCCoreData new];
    }
    
    return _coreData;
}
```

#import "DemsyTabBarController.h"

@interface DemsyTabBarController ()

@end

@implementation DemsyTabBarController

- (void)viewDidLoad {
    [self setTabURLs:[NSArray arrayWithObjects:@"tt://menu/1",
                      @"tt://menu/2",
                      @"tt://menu/3",
                      @"tt://menu/4",
                      @"tt://menu/5",
                      nil]];
    
}

@end

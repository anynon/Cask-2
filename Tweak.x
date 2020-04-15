#import <UIKit/UIKit.h>
#import <Cask-Swift.h>

int style;
BOOL animateAlways;
BOOL hasMovedToWindow = NO;
NSTimeInterval duration;
Cask * cas = nil;

%hook UIScrollView

-(BOOL)isDragging {
	hasMovedToWindow = !%orig;
	return %orig;
}

-(void)_scrollViewWillBeginDragging{
	hasMovedToWindow = NO;
	return %orig;
}

%end 

%hook UITableView

- (UITableViewCell *)_createPreparedCellForGlobalRow:(NSInteger)globalRow withIndexPath:(NSIndexPath *)indexPath willDisplay:(BOOL)willDisplay
{
		if (hasMovedToWindow && !animateAlways)
			return %orig;

		UITableViewCell *result = %orig;
		return [cas animatedTable:result style:style duration:duration];
}

%end

// Preferences.
void loadPrefs() {
     @autoreleasepool {

        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.caskprefs.plist"];
        if (prefs) {
            style = [[prefs objectForKey:@"style"] integerValue];
            duration = [[prefs objectForKey:@"duration"] doubleValue];
            animateAlways = [[prefs objectForKey:@"animateAlways"] boolValue];
        }
    }
}

%ctor {
    @autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.caskprefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		//Cask * cas = [[objc_getClass("Cask") alloc] init];
		cas = [[objc_getClass("Cask") alloc] init];
		[cas initPrefs];
		loadPrefs();

		if(![@"SpringBoard" isEqualToString:[NSProcessInfo processInfo].processName])
      	  %init;
    }
}

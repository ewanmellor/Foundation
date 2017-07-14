#import <Foundation/NSOperation.h>
#import <Foundation/NSThread.h>
#import "PMKFoundation.h"

@implementation NSNotificationCenter (PromiseKit)

- (AnyPromise *)observeForName:(NSString *)name {
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        __block id identifier = [self addObserverForName:name object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:identifier name:name object:nil];
            resolve(PMKManifold(note, note.userInfo));
        }];
    }];
}

@end

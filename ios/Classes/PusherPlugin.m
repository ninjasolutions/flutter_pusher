#import "PusherPlugin.h"
#import <flutter_pusher/flutter_pusher-Swift.h>

@implementation PusherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPusherPlugin registerWithRegistrar:registrar];
}
@end

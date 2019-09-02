#import "FlutterPusherPlugin.h"
#import <flutter_pusher/flutter_pusher-Swift.h>

@implementation FlutterPusherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPusherPlugin registerWithRegistrar:registrar];
}
@end

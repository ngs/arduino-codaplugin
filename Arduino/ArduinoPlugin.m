//
//  ArduinoPlugin.m
//  Arduino
//
//  Created by Atsushi Nagase on 5/26/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "ArduinoPlugin.h"
#import "SerialMonitorWindowController.h"
#import "Port.h"

@implementation ArduinoPlugin

@synthesize pluginController = _pluginController
, bundleURL = _bundleURL
, serialMonitorWindowController = _serialMonitorWindowController
, port = _port
;

#pragma mark - CodaPlugin Methods

- (NSString *)name { return @"Arduino"; }

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                  plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle {
  return self = [self initWithPlugInController:aController withBundleURL:plugInBundle.bundleURL];
}

- (id)initWithPlugInController:(CodaPlugInsController *)aController
                        bundle:(NSBundle *)yourBundle {
  return self = [self initWithPlugInController:aController withBundleURL:yourBundle.bundleURL];
}

- (id)initWithPlugInController:(CodaPlugInsController*)aController
                 withBundleURL:(NSURL *)bundleURL {
  if(self=[self init]) {
    self.bundleURL = bundleURL;
    self.pluginController = aController;
    [aController registerActionWithTitle:NSLocalizedString(@"Upload", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(upload:)
                       representedObject:nil
                           keyEquivalent:@"@U"
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Compile", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(comppile:)
                       representedObject:nil
                           keyEquivalent:@"$@B"
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Serial Monotor", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(openSerialMonitor:)
                       representedObject:nil
                           keyEquivalent:@"$@M"
                              pluginName:self.name];
    
    [aController registerActionWithTitle:NSLocalizedString(@"Settings", nil)
                   underSubmenuWithTitle:nil
                                  target:self
                                selector:@selector(openSettings:)
                       representedObject:nil
                           keyEquivalent:@"$@,"
                              pluginName:self.name];
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if(aSelector == @selector(upload:) || aSelector == @selector(comppile:)) {
    NSString *path = [self.pluginController focusedTextView:self].path;
    return [path hasSuffix:@".ino"] || [path hasSuffix:@".pde"];
  }
  return [super respondsToSelector:aSelector];
}

#pragma mark - Actions

- (void)upload:(id)sender {
  
}

- (void)comppile:(id)sender {
  
}

- (void)openSerialMonitor:(id)sender {
  [self.serialMonitorWindowController showWindow:sender];
}

- (void)openSettings:(id)sender {
  
}

#pragma mark - Accessors

- (SerialMonitorWindowController *)serialMonitorWindowController {
  if(nil==_serialMonitorWindowController) {
    _serialMonitorWindowController = [[SerialMonitorWindowController alloc] initWithPlugin:self];
  }
  return _serialMonitorWindowController;
}



@end

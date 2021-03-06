//
//  ArduinoPlugin.m
//  Arduino
//
//  Created by Atsushi Nagase on 5/26/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "ArduinoPlugin.h"
#import "SerialMonitorWindowController.h"
#import "SettingsWindowController.h"
#import "ProgressWindowController.h"
#import "AVRCompiler.h"
#import "P5Preferences.h"


NSString *const ArduinoPluginArduinoLocationKey = @"ArduinoPluginArduinoLocation";
NSString *const ArduinoPluginBoardKey = @"ArduinoPluginBoard";
NSString *const ArduinoPluginProgrammerKey = @"ArduinoPluginProgrammer";
NSString *const ArduinoPluginSerialPortKey = @"ArduinoPluginSerialPort";


@implementation ArduinoPlugin

@synthesize pluginController = _pluginController
, bundleURL = _bundleURL
, serialMonitorWindowController = _serialMonitorWindowController
, settingsMonitorWindowController = _settingsMonitorWindowController
, progressWindowController = _progressWindowController
, progressHandler = _progressHandler
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
                                selector:@selector(compile:)
                       representedObject:nil
                           keyEquivalent:@"^$@B"
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
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      @"/Applications/Arduino.app/Contents/Resources/Java", ArduinoPluginArduinoLocationKey,
      @"uno", ArduinoPluginBoardKey,
      @"avrispmkii", ArduinoPluginProgrammerKey,
      nil]];
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if(aSelector == @selector(upload:) || aSelector == @selector(compile:)) {
    NSString *path = [self.pluginController focusedTextView:self].path;
    return [path hasSuffix:@".ino"] || [path hasSuffix:@".pde"];
  }
  return [super respondsToSelector:aSelector];
}

#pragma mark - Actions

- (void)upload:(id)sender {
  
}

- (void)compile:(id)sender {
  [self.progressWindowController showWindow:self];
  [self.progressWindowController.progresIndicator setMaxValue:1.0];
  [self.progressWindowController.progresIndicator setDoubleValue:0];
  [self.progressWindowController.progresIndicator setIndeterminate:NO];
  NSString *path = [self.pluginController focusedTextView:self].path;
  AVRCompiler *compiler = [[AVRCompiler alloc] initWithPath:path boardPreferences:nil];
  [compiler
   compile:YES
   withProgressHandler:^(double progress) {
     NSArray *messages = [compiler.messages copy];
     [self.progressWindowController.progresIndicator setDoubleValue:progress];
     [self.progressWindowController setOutputText:[messages componentsJoinedByString:@"\n"]];
   }
   completeHandler:^{
     NSArray *messages = [compiler.messages copy];
     [self.progressWindowController.progresIndicator setDoubleValue:1.0];
     [self.progressWindowController setOutputText:[messages componentsJoinedByString:@"\n"]];
   }
   errorHandler:^(NSError *error) {
     NSArray *messages = [compiler.messages copy];
     [self.progressWindowController.progresIndicator setDoubleValue:1.0];
     [self.progressWindowController setOutputText:[messages componentsJoinedByString:@"\n"]];
     NSRange range = [self.progressWindowController.outputText rangeOfString:[error.userInfo valueForKey:@"message"]];
     [self.progressWindowController.outputTextView setTextColor:[NSColor redColor] range:range];
   }];
}

- (void)openSerialMonitor:(id)sender {
  [self.serialMonitorWindowController showWindow:sender];
}

- (void)openSettings:(id)sender {
  [self.settingsMonitorWindowController showWindow:sender];
}

#pragma mark - Accessors

- (SerialMonitorWindowController *)serialMonitorWindowController {
  if(nil==_serialMonitorWindowController) {
    _serialMonitorWindowController = [[SerialMonitorWindowController alloc] initWithPlugin:self];
  }
  return _serialMonitorWindowController;
}

- (ProgressWindowController *)progressWindowController {
  if(nil==_progressWindowController) {
    _progressWindowController = [[ProgressWindowController alloc] init];
  }
  return _progressWindowController;
}


- (SettingsWindowController *)settingsMonitorWindowController {
  if(nil==_settingsMonitorWindowController) {
    _settingsMonitorWindowController = [[SettingsWindowController alloc] initWithPlugin:self];
  }
  return _settingsMonitorWindowController;
}



@end

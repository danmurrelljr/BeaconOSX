//
//  BLCAppDelegate.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//  Copyright (c) 2013 Blended Cocoa. All rights reserved.
//

#import "BLCAppDelegate.h"

#import <IOBluetooth/IOBluetooth.h>

#import "BLCBeaconAdvertisementData.h"

#pragma mark - Estimote presets
static NSString const *kEstimoteUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

#pragma mark - Kontakt presets
static NSString const *kKontaktUUID = @"F7826DA6-4FA2-4E98-8024-BC5B71E0893E";

@interface BLCAppDelegate () <CBPeripheralManagerDelegate, NSTextFieldDelegate>

@property (nonatomic,strong) CBPeripheralManager *manager;

@property (weak) IBOutlet NSButton  *startbutton;
@property (weak) IBOutlet NSTextField *uuidTextField;
@property (weak) IBOutlet NSTextField *majorValueTextField;
@property (weak) IBOutlet NSTextField *minorValueTextField;
@property (weak) IBOutlet NSTextField *measuredPowerTextField;

- (IBAction)startButtonTapped:(NSButton*)advertisingButton;

@end

@implementation BLCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                       queue:nil];
    [self.startbutton setEnabled:NO];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self.startbutton setEnabled:YES];
        [self.uuidTextField setEnabled:YES];
        [self.majorValueTextField setEnabled:YES];
        [self.minorValueTextField setEnabled:YES];
        [self.measuredPowerTextField setEnabled:YES];
        
        [self.startbutton setTarget:self];
        [self.startbutton setAction:@selector(startButtonTapped:)];
        
        self.uuidTextField.delegate = self;
    }
}

- (IBAction)startButtonTapped:(NSButton*)advertisingButton{
    if (_manager.isAdvertising) {
        [_manager stopAdvertising];
        [advertisingButton setTitle:@"startAdvertising"];
        [self.uuidTextField setEnabled:YES];
        [self.majorValueTextField setEnabled:YES];
        [self.minorValueTextField setEnabled:YES];
        [self.measuredPowerTextField setEnabled:YES];
    } else {
        NSString *uuidString = [self.uuidTextField stringValue];
        if ([[uuidString lowercaseString] isEqualToString:@"estimote"]) {
            uuidString = kEstimoteUUID;
        } else if ([[uuidString lowercaseString] isEqualToString:@"kontakt"]) {
            uuidString = kKontaktUUID;
        } else {
            uuidString = [self.uuidTextField stringValue];
        }

        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
        
        BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                                     major:self.majorValueTextField.integerValue
                                                                                                     minor:self.minorValueTextField.integerValue
                                                                                             measuredPower:self.measuredPowerTextField.integerValue];
        
        
        [_manager startAdvertising:beaconData.beaconAdvertisement];
        [self.uuidTextField setEnabled:NO];
        [self.majorValueTextField setEnabled:NO];
        [self.minorValueTextField setEnabled:NO];
        [self.measuredPowerTextField setEnabled:NO];

        [advertisingButton setTitle:@"stop advertising"];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    
    
    return YES;
}

@end

//
//  SRSInitialSetupWindowController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 2/7/14.
//  Copyright (c) 2014 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "SRSInitialSetupWindowController.h"
#import "AnimationFlipWindow.h"
#import "SRSAppDelegate.h"
#import "Site.h"

@interface SRSInitialSetupWindowController ()

@end

@implementation SRSInitialSetupWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setMovable:NO];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)setupForSealsWithClubs:(id)sender {
    AnimationFlipWindow* afw = [[AnimationFlipWindow alloc] init];
    [self performSelector:@selector(lookForSwcApp:) withObject:nil afterDelay:0.5];
    
    [afw flip:self.window toBack:self.sealsWindow];
    [self.sealsWindow setMovable:NO];
}

- (void)lookForSwcApp:(id)sender {
    NSWorkspace *myWorkspace = [NSWorkspace  sharedWorkspace];
    NSArray* applications = [myWorkspace runningApplications];
    
    NSURL* sealsAppUrl = nil;
    
    for (NSRunningApplication* proc in applications) {
        if ([proc.localizedName hasPrefix:@"Seals with Clubs Poker Client"]) {
            sealsAppUrl = [proc executableURL];
            break;
        }
    }
    
    float delay = 0.5;
    
    if (self.sealsDetectedPath.stringValue.length == 0) {
        if (sealsAppUrl == nil) {
            self.sealsDetection.stringValue = @"Seals with Clubs *not* detected";
        } else {
            self.sealsDetection.stringValue = @"Seals with Clubs app detected";
            NSString* pathComponent = [[sealsAppUrl URLByDeletingLastPathComponent] path];
            NSString* hhCandidate = [pathComponent stringByAppendingPathComponent:@"handhistories"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDir;
            if ([fileManager fileExistsAtPath:hhCandidate isDirectory:&isDir]) {
                
                self.sealsDetectedPath.stringValue = hhCandidate;
                [self.sealsDetectedPath.currentEditor setSelectedRange:NSMakeRange(hhCandidate.length, 0)];
                [self.accountName becomeFirstResponder];

            }
        }
    } else {
        delay = 5;
    }
    
    [self performSelector:@selector(lookForSwcApp:) withObject:nil afterDelay:delay];
}

- (void)changeDetectedPath:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setTreatsFilePackagesAsDirectories:YES];
    [openDlg setPrompt:@"Select"];
    
    if ([openDlg runModal] == NSOKButton )
    {
        NSArray* files = [openDlg URLs];
        NSString* handHistory = @"";
        
        for (NSURL *u in files)
        {
            handHistory = [u path];
        }
        
        self.sealsDetectedPath.stringValue = handHistory;
        [self.sealsDetectedPath.currentEditor setSelectedRange:NSMakeRange(handHistory.length, 0)];
        
        [self.accountName becomeFirstResponder];
    }
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if (textField == self.sealsDetectedPath || textField == self.accountName) {
        if (self.sealsDetectedPath.stringValue.length > 0 &&
            self.accountName.stringValue.length > 0 &&
            [fileManager fileExistsAtPath:self.sealsDetectedPath.stringValue
                              isDirectory:&isDir]) {
                [self.addAccount setEnabled:YES];
            } else {
                [self.addAccount setEnabled:NO];
            }
    }
}

- (IBAction)addSealsAccount:(id)sender {
    SRSAppDelegate *d = [NSApplication sharedApplication].delegate;
    NSManagedObjectContext *aMOC = d.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site"
                                              inManagedObjectContext:aMOC];
    
    
    Site* site = [[Site alloc] initWithEntity:entity
               insertIntoManagedObjectContext:aMOC];
    
    
    site.name = @"Seals With Clubs";
    site.account = self.accountName.stringValue;
    site.handHistoryLocation = self.sealsDetectedPath.stringValue;
    
    NSError *error = nil;
    [aMOC save:&error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseEngineInitialized:) name:@"SRSEngineInitialized"
                                               object:nil];
    
    [d initForGeneralUse];
    [self.accountName resignFirstResponder];
    
}

- (void)parseEngineInitialized:(NSNotification*)notification {
    [self.sealsWindow close];
}

@end

#define APPLESCRIPT_MOUNT_SCRIPT(X)   [\
                                         NSString \
                     stringWithFormat:@"tell application \"Finder\" to mount volume \"%@\"",\
                     X\
                                        ]

- (BOOL) mount {
  NSAppleScript *ascript = [[NSAppleScript alloc]
                initWithSource:APPLESCRIPT_MOUNT_SCRIPT(originalPath)];
  NSDictionary *errorInfo = nil;
  
  NSLog(@"Mounting: '%@' to '%@'...",[self remotePath], [self localPath]);
  
  [ascript executeAndReturnError:&errorInfo];
  [ascript release];
  
  if (errorInfo != nil) {
    NSLog(@"Got this in error info: %@", errorInfo);
    [errorInfo release];
    alertUser([NSString stringWithFormat:@"Failed to open path '%@'.", cifsPath]);
    return NO;
  }
  
  return YES;
}

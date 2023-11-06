//
//  watcher.c
//  FileWatcher
//
//  Created by Mike Desaro on 11/3/23.
//

#include "watcher.h"

FileWatcherCallback file_watcher_callback;

void fs_event_callback(
    ConstFSEventStreamRef streamRef,
    void *clientCallBackInfo,
    size_t numEvents,
    void *eventPaths,
    const FSEventStreamEventFlags eventFlags[],
    const FSEventStreamEventId eventIds[])
{
    int i;
    char **paths = eventPaths;
 
    for (i = 0; i < numEvents; i++) {
        if (eventFlags[i] & kFSEventStreamEventFlagItemIsFile) {
            if (eventFlags[i] & kFSEventStreamEventFlagItemModified) {
                file_watcher_callback(paths[i]);
            }
        }
   }
}


void file_watcher_watch_path(const char * path, FileWatcherCallback callback) {
    file_watcher_callback = callback;
    
    CFStringRef mypath = CFStringCreateWithCString(kCFAllocatorDefault, path, kCFStringEncodingUTF8);
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
        
    void *callbackInfo = NULL; // could put stream-specific data here.
    CFAbsoluteTime latency = 1.0; // Latency in seconds, f64
    
    FSEventStreamRef stream = FSEventStreamCreate(NULL,
        &fs_event_callback,
        callbackInfo,
        pathsToWatch,
        kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
        latency,
        kFSEventStreamCreateFlagFileEvents /* Flags explained in reference */
    );
    
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

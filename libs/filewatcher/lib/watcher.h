//
//  watcher.h
//  FileWatcher
//
//  Created by Mike Desaro on 11/3/23.
//

#ifndef watcher_h
#define watcher_h

#include <stdio.h>
#include <CoreServices/CoreServices.h>

typedef void (*FileWatcherCallback)(const char *);

void file_watcher_watch_path(const char * path, FileWatcherCallback callback);

#endif /* watcher_h */

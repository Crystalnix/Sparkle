/*
 *  SULog.m
 *  EyeTV
 *
 *  Created by Uli Kusterer on 12/03/2009.
 *  Copyright 2009 Elgato Systems GmbH. All rights reserved.
 *
 */

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#include "SULog.h"


// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

static NSString *const SULogFilePathTemplate = @"~/Library/Logs/SparkleUpdateLog-%@.log";

// -----------------------------------------------------------------------------
//	Private prototypes:
// -----------------------------------------------------------------------------

NSString *SULogFilePath(void);

// -----------------------------------------------------------------------------
//	SUGetFilePath:
//		Returns a path, unique for the application, in the user's logs dir
// -----------------------------------------------------------------------------

NSString *SULogFilePath(void)
{
    static NSString *filePath = nil;
    if (filePath == nil) {
        filePath = [NSString stringWithFormat:SULogFilePathTemplate,
                    [[NSFileManager defaultManager] displayNameAtPath:[[NSBundle mainBundle] bundlePath]]];
    }
    return filePath;
}

// -----------------------------------------------------------------------------
//	SUClearLog:
//		Erase the log at the start of an update. We don't want to litter the
//		user's hard disk with logging data that's mostly unused, so each app
//		should clear the log before it starts updating, so only the most recent
//		update is kept around.
//
//	TAKES:
//		sender	-	Object that sent this message, typically of type X.
// -----------------------------------------------------------------------------

void SUClearLog(void)
{
    FILE *logfile = fopen([[SULogFilePath() stringByExpandingTildeInPath] fileSystemRepresentation], "w");
    if (logfile) {
        fclose(logfile);
        SULog(@"===== %@ =====", [[NSFileManager defaultManager] displayNameAtPath:[[NSBundle mainBundle] bundlePath]]);
    }
}


// -----------------------------------------------------------------------------
//	SULog:
//		Like NSLog, but logs to one specific log file. Each line is prefixed
//		with the current date and time, to help in regressing issues.
//
//	TAKES:
//		format	-	NSLog/printf-style format string.
//		...		-	More parameters depending on format string's contents.
// -----------------------------------------------------------------------------

void SULog(NSString *format, ...)
{
    static BOOL loggedYet = NO;
    if (!loggedYet) {
        loggedYet = YES;
        SUClearLog();
    }

    va_list ap;
    va_start(ap, format);
    NSString *theStr = [[NSString alloc] initWithFormat:format arguments:ap];
    NSLog(@"Sparkle: %@", theStr);

    FILE *logfile = fopen([[SULogFilePath() stringByExpandingTildeInPath] fileSystemRepresentation], "a");
    if (logfile) {
        theStr = [NSString stringWithFormat:@"%@: %@\n", [NSDate date], theStr];
        NSData *theData = [theStr dataUsingEncoding:NSUTF8StringEncoding];
        fwrite([theData bytes], 1, [theData length], logfile);
        fclose(logfile);
    }
    va_end(ap);
}



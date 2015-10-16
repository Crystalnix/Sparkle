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

static const unsigned long long MaxLogFileSize = 1 * 1024 * 1024;
static const float ContentTrimmingKoefficient = 0.75;

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

void SULogTrace(NSString *format, ...) {
    va_list ap;
    va_start(ap, format);
    NSString *theStr = [[NSString alloc] initWithFormat:format arguments:ap];
    
    SULog(@"%@", theStr);
    
    va_end(ap);
}

// -----------------------------------------------------------------------------
// SUMaybeTrimLogFile:
//      Call this function to reduce log file size if it became bigger than
//      defined MaxLogFileSize constant. Data is reduced up to DesiredLogFileSize
//      and to the first character after its first new line character.
// -----------------------------------------------------------------------------

void SUMaybeTrimLogFile(void)
{
    NSString *logFilePath = [SULogFilePath() stringByExpandingTildeInPath];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        return;
    }
    
    unsigned long long logSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath
                                                                                   error:&error] fileSize];
    
    if (error != nil) {
        NSLog(@"%@", error);
        return;
    }
    
    if (logSize < MaxLogFileSize) {
        return;
    }
    
    // Read contents from the log file
    NSString *contents = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    }
    if (contents.length == 0) {
        return;
    }
    
    NSUInteger cropLength = (NSUInteger)((MaxLogFileSize * ContentTrimmingKoefficient) * contents.length / logSize);
    if (contents.length < cropLength) {
        return;
    }
    
    // Trim to desired size
    NSString *newContents = [contents substringFromIndex:contents.length - cropLength];
    if (newContents.length == 0) {
        return;
    }
    // Trim to the first character after first new-line character, if possible
    NSRange firstNewLineRange = [newContents rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (firstNewLineRange.location != NSNotFound && firstNewLineRange.location + 1 < newContents.length) {
        newContents = [newContents substringFromIndex:firstNewLineRange.location + 1];
    }
    
    // Save results to the file (overwrite)
    [newContents writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"%@", error);
    }
}


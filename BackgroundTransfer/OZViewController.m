//
//  OZViewController.m
//  BackgroundTransfer
//
//  Created by Kiattisak Anoochitarom on 3/18/2557 BE.
//  Copyright (c) 2557 Kiattisak Anoochitarom. All rights reserved.
//

#import <MRProgress.h>
#import "OZViewController.h"
#import "OZAppDelegate.h"

@interface OZViewController () <NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, weak) IBOutlet MRCircularProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation OZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressView.tintColor = [UIColor colorWithRed:0.04 green:0.42 blue:1 alpha:1];
    self.session = [self backgroundSession];
    
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (void)callCompletionHandlerWhenFinished {
    /*
     * Ask the session for its current tasks;
     * if there are none, then the session is complete.
     */
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger taskCount = dataTasks.count + uploadTasks.count + downloadTasks.count;
        
        if (taskCount == 0) {
            OZAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            if (appDelegate.backgroundSessionCompletionHandler) {
                void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
                appDelegate.backgroundSessionCompletionHandler = nil;
                completionHandler();
            }
        }
    }];
}

#pragma mark - Action

- (IBAction)fetchImage:(id)sender {
    if (self.task) {
        return;
    }
    
    NSURL *imageURL = [NSURL URLWithString:@"http://kevinraber.files.wordpress.com/2011/01/cf001795.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    self.task = [self.session downloadTaskWithRequest:request];
    [self.task resume];
    
    self.imageView.hidden = YES;
    self.progressView.hidden = NO;
}

- (IBAction)forceCrash:(id)sender {
    NSString *someString;
    NSArray *someArray = @[someString];
    
    NSLog(@"%ld", (unsigned long)someArray.count);
}



#pragma mark - NSURLSession Instantiation

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.oozou.BackgroundTransfer"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    
    return session;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *filePath = [self filePathWithName:@"image.jpg"];
    [[NSFileManager defaultManager] copyItemAtPath:[location path]
                                            toPath:filePath
                                             error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        self.imageView.image = image;
        self.progressView.hidden = YES;
        self.imageView.hidden = NO;
    });
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    double currentProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = currentProgress;
    });
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    self.task = nil;
    [self callCompletionHandlerWhenFinished];
}

#pragma mark - Document Directory

- (NSString *)documentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                               NSUserDomainMask,
                                               YES) firstObject];
}

- (NSString *)filePathWithName:(NSString *)fileName {
    return [[self documentDirectory] stringByAppendingPathComponent:fileName];
}

@end

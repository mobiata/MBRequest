//
//  MBRYouTubeRequest.h
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBJSONRequest.h"

typedef void (^MBRYouTubeCompletionHandler)(NSArray *videos, NSError *error);

@interface MBRYouTubeRequest : MBJSONRequest

- (void)requestTopRatedVideosFromIndex:(NSInteger)startIndex
                            maxResults:(NSInteger)maxResults
                     completionHandler:(MBRYouTubeCompletionHandler)completionHandler;

@end

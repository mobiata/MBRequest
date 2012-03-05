//
//  MBRequestLog.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/5/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#ifdef MB_DEBUG_REQUESTS
#define MBRequestLog(...) NSLog(__VA_ARGS__)
#else
#define MBRequestLog(...)
#endif

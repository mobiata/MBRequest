//
//  MBRequestLog.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/5/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

/**
 This is a simple macro used for MBRequest debugging. Feel free to define MBRequestLog yourself in
 your Prefix.pch file. Or, just define MB_DEBUG_REQUESTS to alias MBRequestLog to NSLog.
 */
#ifndef MBRequestLog
#ifdef MB_DEBUG_REQUESTS
#define MBRequestLog(...) NSLog(__VA_ARGS__)
#else
#define MBRequestLog(...)
#endif
#endif

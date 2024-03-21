//
// EdyouChat-Bridging-Header.h
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


#ifndef EdyouChat_Bridging_h
#define EdyouChat_Bridging_h

#import "sqlite3.h"

typedef void (*sqlite3_destructor_type)(void*);
#define SQLITE_STATIC      ((sqlite3_destructor_type)0)
#define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)

#endif /* EdyouChat_Bridging_h */

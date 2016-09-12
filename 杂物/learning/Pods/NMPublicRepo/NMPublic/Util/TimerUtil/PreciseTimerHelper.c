//
//  PreciseTimerHelper.c
//  
//
//  Created by 江彦聪 on 16/4/12.
//
//

#include "PreciseTimerHelper.h"

static mach_timebase_info_data_t timebase_info;
uint64_t abs_to_nanos(uint64_t abs) {
    if(timebase_info.denom == 0 && timebase_info.numer == 0){
        mach_timebase_info(&timebase_info);
    }
    return abs * timebase_info.numer  / timebase_info.denom;
}

uint64_t nanos_to_abs(uint64_t nanos) {
    
    if(timebase_info.denom == 0 && timebase_info.numer == 0){
        mach_timebase_info(&timebase_info);
    }
    return nanos * timebase_info.denom / timebase_info.numer;
}

boolean_t is_expire(uint64_t start_time, uint64_t max_second){
    int diff = abs_to_nanos(mach_absolute_time()-start_time) / (1000.0 * NSEC_PER_MSEC);
    return diff >= max_second?1:0;
    
}

void example_mach_wait_until(int argc)
{
    uint64_t time_to_wait = nanos_to_abs(argc * NSEC_PER_SEC);
    uint64_t now = mach_absolute_time();
    mach_wait_until(now + time_to_wait);
}

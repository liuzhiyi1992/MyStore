//
//  PreciseTimerHelper.h
//  
//
//  Created by 江彦聪 on 16/4/12.
//
//

#ifndef PreciseTimerHelper_h
#define PreciseTimerHelper_h

#include <stdio.h>

#include <mach/mach.h>
#include <mach/mach_time.h>

extern uint64_t abs_to_nanos(uint64_t abs);
extern uint64_t nanos_to_abs(uint64_t nanos);
extern boolean_t is_expire(uint64_t start_time, uint64_t max_second);
void example_mach_wait_until(int argc);
#endif /* PreciseTimerHelper_h */

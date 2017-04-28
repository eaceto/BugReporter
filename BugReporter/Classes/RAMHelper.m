//
//  RAMHelper.m
//  Pods
//
//  Created by Kimi on 4/27/17.
//
//

#import "RAMHelper.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation RAMHelper

unsigned long getFreeMemory(void) {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }
    unsigned long mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

unsigned long getUsedMemory(void) {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }
    
    /* Stats in bytes */
    unsigned long mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    return mem_used;
}

+(NSDictionary*)stats {
    double used = ((double)getUsedMemory() / 1024.0 / 1024.0);
    double free = ((double)getFreeMemory() / 1024.0 / 1024.0);
    
    return @{@"used":[NSString stringWithFormat:@"%f MB",used],
             @"free":[NSString stringWithFormat:@"%f MB",free],
             @"total":[NSString stringWithFormat:@"%f MB",(used + free)]};
}

@end

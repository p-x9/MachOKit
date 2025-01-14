//
//  thread_state.h
//  MachOKit
//
//  Created by p-x9 on 2025/01/13
//  
//

#ifndef thread_state_h
#define thread_state_h

#include <stdint.h>

// https://github.com/apple/darwin-xnu/blob/2ff845c2e033bd0ff64b5b6aa6063a1f8f65aa32/osfmk/mach/arm/_structs.h#L84
struct arm_thread_state {
    uint32_t r[13];   /* General purpose register r0-r12 */
    uint32_t sp;      /* Stack pointer r13 */
    uint32_t lr;      /* Link register r14 */
    uint32_t pc;      /* Program counter r15 */
    uint32_t cpsr;    /* Current program status register */
};

// https://github.com/apple/darwin-xnu/blob/2ff845c2e033bd0ff64b5b6aa6063a1f8f65aa32/osfmk/mach/arm/_structs.h#L101
struct arm_thread_state64 {
    uint64_t    x[29];    /* General purpose registers x0-x28 */
    uint64_t    fp;               /* Frame pointer x29 */
    uint64_t    lr;               /* Link register x30 */
    uint64_t    sp;               /* Stack pointer x31 */
    uint64_t    pc;               /* Program counter */
    uint32_t    cpsr;             /* Current program status register */
    uint32_t    flags;    /* Flags describing structure format */
};

// https://github.com/apple/darwin-xnu/blob/2ff845c2e033bd0ff64b5b6aa6063a1f8f65aa32/osfmk/mach/i386/_structs.h#L66
struct i386_thread_state {
    unsigned int    eax;
    unsigned int    ebx;
    unsigned int    ecx;
    unsigned int    edx;
    unsigned int    edi;
    unsigned int    esi;
    unsigned int    ebp;
    unsigned int    esp;
    unsigned int    ss;
    unsigned int    eflags;
    unsigned int    eip;
    unsigned int    cs;
    unsigned int    ds;
    unsigned int    es;
    unsigned int    fs;
    unsigned int    gs;
};

// https://github.com/apple/darwin-xnu/blob/2ff845c2e033bd0ff64b5b6aa6063a1f8f65aa32/osfmk/mach/i386/_structs.h#L738
struct x86_thread_state64 {
    uint64_t    rax;
    uint64_t    rbx;
    uint64_t    rcx;
    uint64_t    rdx;
    uint64_t    rdi;
    uint64_t    rsi;
    uint64_t    rbp;
    uint64_t    rsp;
    uint64_t    r8;
    uint64_t    r9;
    uint64_t    r10;
    uint64_t    r11;
    uint64_t    r12;
    uint64_t    r13;
    uint64_t    r14;
    uint64_t    r15;
    uint64_t    rip;
    uint64_t    rflags;
    uint64_t    cs;
    uint64_t    fs;
    uint64_t    gs;
};

#endif /* thread_state_h */

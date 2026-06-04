#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pasriscv_config.h"
#include "doom_iwad.h"

void *_sbrk(int incr)
{
    extern uint8_t _estack;
    extern uint8_t _end;

    static uint8_t *heap_ptr = &_end;

    if (heap_ptr + incr > &_estack)
    {
        errno = ENOMEM;
        return NULL;
    }

    uint8_t *old_ptr = heap_ptr;
    heap_ptr += incr;

    return old_ptr;
}

int _write(int handle, char *data, int size)
{
    for (int i = 0; i < size; i++)
    {
        *uart_write_addr = data[i];
    }

    return size;
}

int _putc_r(struct _reent *u1, int ch, FILE *u2)
{
    *uart_write_addr = ch;
    return 0;
}

__attribute__((interrupt, aligned(4))) void trap_vector(void)
{
    uint64_t mcause = 0;

    asm volatile("csrr %0, mcause"
                 : "=r"(mcause));

    if ((mcause & (1ULL << 63ULL)) == 0)
    {
        uint64_t mepc;

        asm volatile("csrr %0, mepc"
                     : "=r"(mepc));

        mepc += 4;

        asm volatile("csrw mepc, %0"
                     :
                     : "r"(mepc));
    }
}

__attribute__((section(".text.init"), noreturn)) void _start()
{
    asm volatile(".option push;"
                 ".option norelax;"
                 "la gp, __global_pointer$;"
                 ".option pop;"
                 "csrw mtvec, %0;"
                 "csrw fcsr, 1;"
                 :
                 : "r"((uintptr_t)trap_vector));

    extern uint8_t _sidata;

    extern uint8_t _sdata;
    extern uint8_t _edata;

    extern uint8_t _sbss;
    extern uint8_t _ebss;

    size_t bss_size = &_ebss - &_sbss;
    uint8_t *bss_dst = &_sbss;

    for (int i = 0; i < bss_size; i++)
    {
        bss_dst[i] = 0;
    }

    size_t data_size = &_edata - &_sdata;
    uint8_t *data_src = &_sidata;
    uint8_t *data_dst = &_sdata;

    for (int i = 0; i < data_size; i++)
    {
        data_dst[i] = data_src[i];
    }

    typedef void (*function_t)(void);

    extern function_t __preinit_array_start;
    extern function_t __preinit_array_end;

    for (const function_t *entry = &__preinit_array_start; entry < &__preinit_array_end; ++entry)
    {
        (*entry)();
    }

    extern function_t __init_array_start;
    extern function_t __init_array_end;

    for (const function_t *entry = &__init_array_start; entry < &__init_array_end; ++entry)
    {
        (*entry)();
    }

    extern int main(void);

    int rc = main();
    (void) rc;

    extern function_t __fini_array_start;
    extern function_t __fini_array_end;

    for (const function_t *entry = &__fini_array_start; entry < &__fini_array_end; ++entry)
    {
        (*entry)();
    }

    *syscon_addr = syscon_poweroff;

    while (1)
        ;
}

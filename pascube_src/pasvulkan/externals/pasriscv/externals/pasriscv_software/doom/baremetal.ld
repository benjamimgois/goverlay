OUTPUT_ARCH("riscv")
ENTRY(_start)

_sstack = ORIGIN(RAM) + LENGTH(RAM);
_estack = _sstack - 0xC00000; /*12MiB*/

MEMORY
{
  RAM (rwx)  : ORIGIN = 0x80000000, LENGTH = 256M
}

SECTIONS
{
  .text :
  {
    . = ALIGN(8);
    *(.text.init*)
    *(.text)
    *(.text*)
    . = ALIGN(8);
    _etext = .;
  } >RAM

  .rodata : {
      *(.rdata)
      *(.rodata .rodata.*)
      *(.gnu.linkonce.r.*)
      . = ALIGN(8);
      *(.srodata.cst16)
      *(.srodata.cst8)
      *(.srodata.cst4)
      *(.srodata.cst2)
      *(.srodata .srodata.*)
      *(.eh_frame)
      *(._user_heap_stack)
      *(.riscv.attributes)
      *(.comment)
  } >RAM

  .preinit_array :
  {
    . = ALIGN(8);
    PROVIDE_HIDDEN(__preinit_array_start = .);
    KEEP(*(.preinit_array*))
    PROVIDE_HIDDEN(__preinit_array_end = .);
    . = ALIGN(8);
  } >RAM

  .init_array :
  {
    . = ALIGN(8);
    PROVIDE_HIDDEN(__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    PROVIDE_HIDDEN(__init_array_end = .);
    . = ALIGN(8);
  } >RAM

  .fini_array :
  {
    . = ALIGN(8);
    PROVIDE_HIDDEN(__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array*))
    PROVIDE_HIDDEN(__fini_array_end = .);
    . = ALIGN(8);
  } >RAM

  .bss :
  {
    _sbss = .;
    *(.bss)
    *(.bss*)
    . = ALIGN(8);
    _ebss = .;
  } >RAM

  _sidata = LOADADDR(.data);

  .data :
  {
    . = ALIGN(8);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(8);
    _edata = .;
    PROVIDE(__global_pointer$ = . + 0x800);
    *(.sdata .sdata.* .sdata2.*)
    PROVIDE(_end = .);
  } >RAM
}
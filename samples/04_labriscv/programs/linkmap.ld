/* Define the entry point */
ENTRY(_start)

/* Specify the memory areas */
MEMORY
{ 
/*  ROM (x)  : ORIGIN = 0x00002000, LENGTH = 0x1000 /* 4K */
/*  RAM (rw) : ORIGIN = 0x00004000, LENGTH = 0x1000 /* 4K */

  ROM (x)  : ORIGIN = 0x00000000, LENGTH = 0x2000 /* 8K */
  RAM (rw) : ORIGIN = 0x00002000, LENGTH = 0x1000 /* 2K */

}

/* Define stack size and heap size */
stack_size = 1024;
heap_size  = 256;

/* Define the start and end points of the stack */
_stack_start = ORIGIN(RAM)+LENGTH(RAM);
_stack_end = _stack_start - stack_size;

/* Define the output sections */
SECTIONS {
     .text : 
     { 
       . = ALIGN(4);
       *(.text.startup)   /* .text initialization */
       *(.text)           /* .text sections (code) */
       *(.text*)          /* .text* sections (code) */
       *(.rodata)         /* .rodata sections (constants, strings, etc.) */
       *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
       *(.srodata*)       /* .srodata* sections (constants, strings, etc.) */
       . = ALIGN(4);
       _etext = .;        /* define a global symbol for the end of code */
     } >ROM

     /* used by the startup to initialize data */
     _sidata = .;

     /* Initialized data sections goes into RAM, load LMA copy after code */
     .data : AT ( _sidata )
     {
       . = ALIGN(4);
       _sdata = .;        /* create a global symbol at data start */
       *(.data)           /* .data sections */
       *(.data*)          /* .data* sections */

       . = ALIGN(4);
       _edata = .;        /* define a global symbol at data end */
     } >RAM

     /* Uninitialized data section */
     . = ALIGN(4);
     .bss :
     {
       /*  Used by the startup in order to initialize the .bss secion */
       _sbss = .;         /* define a global symbol at bss start */
       __bss_start__ = _sbss;
       *(.bss)
       *(.bss*)
       *(COMMON)

       . = ALIGN(4);
       _ebss = .;         /* define a global symbol at bss end */
       __bss_end__ = _ebss;
     } >RAM

     . = ALIGN(4);
     .heap :
     {
        _heap_start = .;
        . = . + heap_size;
        _heap_end = .;
     } > RAM
}

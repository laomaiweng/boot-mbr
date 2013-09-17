/** hello.S **/

/* print "Hello World!" by char if defined, by string if not */
#define PRINT_CHAR


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */


.org 0x7c00                             /* MBR code */
MBR:

    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

    SROW =  0x03            /* starting row */
    SCOL =  0x15            /* starting column */

#ifdef PRINT_CHAR

/* Char-by-char method */
    mov     $0x02, %ah      /* set cursor position INT 10 */
    mov     $SROW, %dh      /* row */
    mov     $SCOL, %dl      /* column */
    int     $0x10           /* set cursor position INT 10 */
    xor     %bh, %bh        /* page 0 */
    mov     $0x0c, %bl      /* color: red on black */
    mov     $GREET, %si     /* load up string address */
DISP:
    mov     $0x09, %ah      /* write character INT 10 */
    mov     $0x0001, %cx    /* number of times to print character */
    lodsb                   /* copy next character and increment SI */
    or      %al, %al        /* check if char is \0 */
    jz      HANG            /* if \0, get out of here */
    int     $0x10           /* print character */
    mov     $0x02, %ah      /* set cursor position INT 10 */
    inc     %dl             /* column + 1 */
    int     $0x10           /* set cursor position */
    jmp     DISP            /* here we go again */

#else

/* Whole string method */
    xor     %ax, %ax        /* clear ES */
    mov     %ax, %es
    mov     $0x13, %ah      /* print string INT 10 */
    mov     $0x01, %al      /* update cursor, no per-char attribute */
    xor     %bh, %bh        /* page 0 */
    mov     $0x0c, %bl      /* color: red on black */
    mov     $LEN, %cx       /* string length */
    mov     $SROW, %dh      /* row */
    mov     $SCOL, %dl      /* column */
    mov     $GREET, %bp     /* string address: ES:BP */
    int     $0x10           /* BIOS interrupt */

#endif /* PRINT_CHAR */

HANG:
    jmp     HANG            /* hang loop */

GREET:
    .ascii  "Hello World!"
    LEN =   . - GREET


.org 0x7db8                             /* disk signature */
    .byte  0x12, 0x34, 0x56, 0x78


.org 0x7dbe                             /* partition table: partition 1 */
    .byte 0x80      /* bootable */
    .byte 0x01      /* start CHS */
    .byte 0x01
    .byte 0x00
    .byte 0x83      /* FS type */
    .byte 0xfe
    .byte 0x3f
    .byte 0x00
    .byte 0x3f
    .byte 0x00
    .byte 0x00
    .byte 0x00
    .byte 0x82
    .byte 0x3e
    .byte 0x00
    .byte 0x00


.org 0x7dfe                             /* MBR signature */
    .word   0xAA55


/** EOF **/

/** 3fault.S **/


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */


.org 0x7c00                             /* MBR code */
MBR:

    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

    /* display string */
    xor     %ax, %ax        /* clear ES */
    mov     %ax, %es
    mov     $0x13, %ah      /* print string INT 10 */
    mov     $0x01, %al      /* update cursor, no per-char attribute */
    xor     %bh, %bh        /* page 0 */
    mov     $0x0c, %bl      /* color: red on black */
    mov     $LEN, %cx       /* string length */
    mov     $0x03, %dh      /* row */
    mov     $0x15, %dl      /* column */
    mov     $GREET, %bp     /* string address: ES:BP */
    int     $0x10           /* BIOS interrupt */

    /* triple fault! */
    xor     %ax, %ax        /* set the IDTR to 0 */
    push    %ax
    mov     %sp, %bp
    lidt    (%bp)
    int     $0x10           /* reset! */

HANG:
    jmp     HANG            /* hang loop */

GREET:
    .ascii  "Going down!"
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

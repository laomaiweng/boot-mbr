/** getchar.S **/


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */
STACK = 0x9000


.org 0x7c00                             /* MBR code */
MBR:
    xor     %ax, %ax        /* clear SS, DS, ES */
    mov     %ax, %ss
    mov     %ax, %ds
    mov     %ax, %es
    mov     $STACK, %sp     /* set up the stack pointer */

    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

    SROW =  0x01            /* starting row */
    SCOL =  0x01            /* starting column */
    mov     $SROW, %dh      /* row */
    mov     $SCOL, %dl      /* column */
    xor     %bh, %bh        /* page 0 */
    mov     $0x07, %bl      /* color: light gray on black */

NEWPROMPT:
    /* display prompt */
    mov     $0x13, %ah      /* print string INT 10 */
    mov     $0x01, %al      /* update cursor, no per-char attribute */
    mov     $LEN, %cx       /* string length */
    mov     $PROMPT, %bp    /* string address: ES:BP */
    int     $0x10           /* BIOS interrupt */

    /* get new cursor position */
    mov     $0x03, %ah      /* get cursor INT 10 */
    int     $0x10           /* BIOS interrupt */

    xor     %si, %si        /* reset char counter */

GETCHAR:
    /* get character */
    mov     $0x10, %ah      /* get extended char INT 16 */
    int     $0x16           /* BIOS interrupt */

    /* check newline */
    cmp     $0x0a, %al
    je      NEWLINE
    cmp     $0x0d, %al
    je      NEWLINE

    /* print character */
    mov     $0x0a, %ah      /* print character INT 10 */
    mov     $0x0001, %cx    /* number of time to print */
    int     $0x10           /* BIOS interrupt */
    inc     %si             /* increment char counter */

    /* move cursor */
    mov     $0x02, %ah      /* set cursor INT 10 */
    inc     %dl
    int     $0x10           /* BIOS interrupt */

    jmp     GETCHAR         /* here we go again */

NEWLINE:
    /* go to next line */
    mov     $0x0f, %ah      /* get video mode: returns screen size in AH */
    int     $0x10           /* BIOS interrupt */
    mov     %ah, %cl        /* move screen size to CL */
    lodsw                   /* copy char counter into AX */
    divb    %cl             /* divide char counter by screen size */
    add     %al, %dh        /* add quotient to DH */
    inc     %dh             /* increment DH (quotient is 0 if char counter < screen size) */
    mov     $SCOL, %dl      /* reset column */

    jmp     NEWPROMPT       /* print the new prompt */

PROMPT:
    .ascii  "> "
    LEN =   . - PROMPT


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

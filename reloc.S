/** reloc.S **/


/* relocation destination address */
DEST =  0x0600


/******************************************************************************
 *   Useful trick: JMP-CALL combo                                             *
 *                                                                            *
 * JMP-CALL technique for getting the absolute address of an element in the   *
 * code, when knowing only its relative address                               *
 * JMP performs a relative jump to the CALL located just before the data of   *
 * which we want the address, then CALL returns right after the JMP and       *
 * pushes the actual absolute address of the data on the stack, and finally   *
 * the address is popped off the stack into a register and ready for use      *
 ******************************************************************************/


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */


/******************************************************************************
 *                                  MBR code                                  *
 ******************************************************************************/
.org 0x7c00
/*** initial location from BIOS ***/
RELOC:
    /*** clear segment registers ***/
    xor     %ax, %ax
    mov     %ax, %ds
    mov     %ax, %es

    /*** do MBR code relocation ***/
    mov     $MBR, %si       /* src address for relocation */
    mov     $DEST, %di      /* dst address for relocation */
    mov     $SIZE, %cx      /* number of bytes to relocate */
    repnz                   /* copy from DS:SI to ES:DI until CX is 0 */
    movsb

    /*** replace the non-relocated greeting string by the error string ***/
    mov     $ERROR, %si     /* src address for copy */
    mov     $GREET, %di     /* dst address for copy */
    mov     $LEN_E, %cx     /* size of copy */
    repnz                   /* copy from DS:SI to ES:DI until CX is 0 */
    movsb
    mov     $LEN, %bp       /* replace string length */
    movw    $LEN_E, (%bp)

    /*** far jump to the new MBR location: omitting this will output the error message ***/
    jmp     $0x0000, $DEST

/*** actual MBR code ***/
MBR:
    /*** clear screen ***/
    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

    /*** display greeting string ***/
    mov     $0x13, %ah      /* print string INT 10 */
    mov     $0x01, %al      /* update cursor, no per-char attribute */
    xor     %bh, %bh        /* page 0 */
    mov     $0x0c, %bl      /* color: red on black */
    jmp     PRELEN          /* JMP-CALL getting of string length */
RETLEN:
    pop     %bp
    mov     (%bp), %cx      /* string length into CX */
    mov     $0x03, %dh      /* row */
    mov     $0x15, %dl      /* column */
    jmp     PREGREET        /* JMP-CALL getting of string address */
RETGREET:
    pop     %bp             /* pop address of string into BP */
    int     $0x10           /* print string */

HANG:
    jmp     HANG            /* hang loop */

/*** string data ***/
PRELEN:
    call    RETLEN
LEN:
    .word   LEN_G
PREGREET:
    call    RETGREET
GREET:
    .ascii  "MBR relocated!"
    LEN_G = . - GREET

ERROR:
    .ascii  "Relocation error!"
    LEN_E = . - ERROR


/******************************************************************************
 *                               disk signature                               *
 ******************************************************************************/
.org 0x7db8
    .byte  0x12, 0x34, 0x56, 0x78


/******************************************************************************
 *                              partition table                               *
 ******************************************************************************/
.org 0x7dbe
/*** partition 1 ***/
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
/*** end partition 1 ***/


/******************************************************************************
 *                               MBR signature                                *
 ******************************************************************************/
.org 0x7dfe
    .word   0xAA55
END:
    SIZE =  . - MBR


/** EOF **/

/** disk.S **/


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */


/******************************************************************************
 *                                  MBR code                                  *
 ******************************************************************************/
.org 0x7c00
MBR:
    /*** clear segment registers ***/
    xor     %ax, %ax
    mov     %ax, %ss
    mov     %ax, %ds
    mov     %ax, %es

    /*** clear screen ***/
    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* BIOS interrupt */

    SROW =  0x03
    SCOL =  0x05
    /*** default print settings ***/
    mov     $SROW, %dh
    mov     $SCOL, %dl
    push    %dx

    /*** display greeting string ***/
    mov     $LEN, %cx       /* copy string length into CX */
    mov     $GREET, %bp     /* copy string address into BP */
    pop     %dx
    mov     $0x15, %dl
    call    PRINT
    inc     %dh
    mov     $SCOL, %dl
    push    %dx

    /*** check disk status ***/
    mov     $0x01, %ah      /* check drive INT 13 */
    mov     $0x80, %dl      /* HDD 1 */
    int     $0x13           /* BIOS interrupt */
    jc      CHECK_EH        /* error if CF set */

HANG:
    jmp     HANG            /* hang loop */

/*** error handlers ***/
CHECK_EH:
    mov     $CHECK_EL, %cx
    mov     $CHECK_ES, %bp
    pop     %dx
    call    PRINT
    hlt

/*** display string routine ***/
PRINT:
    mov     $0x13, %ah      /* print string INT 10 */
    mov     $0x01, %al      /* update cursor, no per-char attribute */
    xor     %bh, %bh        /* page 0 */
    mov     $0x0c, %bl      /* color: red on black */
    int     $0x10           /* BIOS interrupt */
    inc     %dh
    ret

/*** string data ***/
GREET:
    .ascii  "Up and running..."
    LEN =   . - GREET
CHECK_ES:
    .ascii  "Drive error!"
    CHECK_EL = . - CHECK_ES


/******************************************************************************
 *                               disk signature                               *
 ******************************************************************************/
.org 0x7db8
    .byte  0x12, 0x34, 0x56, 0x78


/******************************************************************************
 *                              partition table                               *
 ******************************************************************************/
/*** disk size: 1 head, 520 cylinders, 63 sectors/track ***/
.org 0x7dbe
/*** partition 1: 519 cylinders exactly ***/
    .byte 0x80      /* bootable flag */
    .byte 0x00      /* start CHS:           head     cyl  sector   cylinder   */
    .byte 0x01      /*   field bits:    | 76543210 | 98 | 543210 | 76543210 | */
    .byte 0x01      /*   MBR bytes:     |  byte 1  |    byte 2   |  byte 3  | */
    .byte 0x83      /* FS type: Linux */
    .byte 0x00      /* end CHS:             head     cyl  sector   cylinder   */
    .byte 0xbf      /*   field bits:    | 76543210 | 98 | 543210 | 76543210 | */
    .byte 0x07      /*   MBR bytes:     |  byte 1  |    byte 2   |  byte 3  | */
    .long 0x0000003f    /* LBA address */
    .long 0x00007fb9    /* number of sectors in the partition */
/*** end partition 1 ***/


/******************************************************************************
 *                               MBR signature                                *
 ******************************************************************************/
.org 0x7dfe
    .word   0xAA55
END:
    SIZE =  . - MBR


/** EOF **/

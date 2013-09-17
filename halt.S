/** halt.S **/


#.arch i386     /* i386 code: no directive, this must be the default */
.code16         /* 16-bit code */

.text           /* text section */


.org 0x7c00                             /* MBR code */
MBR:
    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

    hlt                     /* stop right here */

.org 0x7dfe
    .word 0xAA55        /* add boot signature at the end of bootloader */


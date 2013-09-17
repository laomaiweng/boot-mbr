/** hang.S **/

.arch i8086
.code16                 /* tell the assembler that its a 16 bit code */

.text                   /* text section */


.org 0x7c00             /* origin, tell the assembler where the code will live */
MBR:

    mov     $0x00, %ah      /* set video mode INT 10 */
    mov     $0x02, %al      /* mode 80x25(text) */
    int     $0x10           /* clear screen */

HANG:
    jmp HANG            /* infinite loop */

.org 0x7dfe
    .word 0xAA55        /* add boot signature at the end of bootloader */


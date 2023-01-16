.include "m32def.inc"
.org 0x00

ldi xl, 0x60
ldi xh, 0x00
ldi yl, 0x82
ldi yh, 0x00
ldi r16, 0x00
out ddra, r16	; ddr = data direction /0 input / 1 output
ldi r16, 0xFF	; FF = 11111111
out ddrd, r16
cbi ddrb, 0		; clear bit in io register 
sbi ddrb, 1		; set bit in io register
cbi portb, 1

ldi r17, 0x69 ; last addr kernel
call GET_DATA        ;get kernel 9 data 8 bit

ldi r17, 0x82 ; last addr img
call GET_DATA        ;get img 25 data 8 bit

clr r10              ;img out buffer

clr r20              ;assume as i
clr r21              ;assume as j
clr r22              ;assume as m
clr r23              ;assume as n

OUT_LOOP:
         cpi r20, 0x03 ; compare with immediate
         brlo pc+0x02
         rjmp OUT_LOOP_END
         clr r21
         IN_LOOP:
                 cpi r21, 0x03
                 brlo pc+0x02
                 rjmp IN_LOOP_END
                      clr r22
                      IN_LOOP2:
                               cpi r22, 0x03
                               brlo pc+0x02
                               rjmp IN_LOOP2_END
                               clr r23
                               IN_LOOP3:
                                        cpi r23, 0x03
                                        brlo pc+0x02
                                        rjmp IN_LOOP3_END

                                        mov xl, r22
                                        lsl xl		; logical shift left ; 2m
                                        add xl, r22 ; x=2m + m =3m
                                        add xl, r23	; x=3m +n
                                        ldi r18, 0x60
                                        add xl, r18   ; x= 3m+n + 0x60
                                        ld r16, x       ;r16 is kernel element

                                        mov xl, r20 ; x=i
                                        add xl, r22 ; x=i+m
                                        lsl xl		; x= 2(i+m)
                                        lsl xl		; x= 4(i+m)
                                        add xl, r20 ; x= 4(i+m) + i
                                        add xl, r22	; x= 4(i+m) + i + m = 5(i+m)
                                        add xl, r21	; x=5(i+m) + j
                                        add xl, r23 ; x=5(i+m) + j + n
                                        ldi r18, 0x69
                                        add xl, r18		; x=5(i+m) + j + n + 0x69
                                        ld r17, x       ;r17 is img element

                                        muls r16, r17 ; {r1,r0}=r16*r17
                                        add r10, r0     ;multiply result save in r10

                                        inc r23 ; increament n++
                                        rjmp IN_LOOP3
                               IN_LOOP3_END:
                               inc r22 ; m++
                               rjmp IN_LOOP2
                      IN_LOOP2_END:
                 st y+, r10
                 clr r10
                 inc r21 ; j++
                 rjmp IN_LOOP
         IN_LOOP_END:
         inc r20 ; i++
         rjmp OUT_LOOP
OUT_LOOP_END:

call SHOW_OUT ; show 9 output data which is 82

HERE:
rjmp HERE


GET_DATA:
           WAIT1:
           sbis pinb, 0 ; skip next inst, if bit io register is set
           rjmp WAIT1
           in r16, pina
           st x+, r16	; after storing data to 0x60 ; x=x+1 = 61
           sbi portb, 1 ; we received data sucessfully
           WAIT0:
           sbic pinb, 0
           rjmp WAIT0
           cbi portb, 1 ; 
           cp xl, r17 ; cp = compare
           breq END_INPUT ; branch if xl == r17 == 0x69
           rjmp WAIT1
           END_INPUT:
           ret

SHOW_OUT:
         ldi yl, 0x82
         ldi r16, (1<<CS10) | (1<<CS11) | (1<<WGM12)
         out tccr1b, r16
         ldi r16, 0x3D
         out ocr1ah, r16
         ldi r16, 0x09
         out ocr1al, r16
         SEND:
         ldi r16, 0x00
         out tcnt1h, r16
         out tcnt1l, r16

         ld r16, y+  ; load r16 with y addr and y++
         out portd, r16

         in r16, tifr
         sbrs r16, 4 ; skip next inst. if register r16 bit 4 is set
         rjmp pc-2
         ldi r16, (1<<OCF1A)
         out tifr, r16

         cpi yl, 0x8B
         breq END_OUT
         rjmp SEND
         END_OUT:
         ret


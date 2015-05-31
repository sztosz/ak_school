section .text
  global _start

_start:
  pop eax         ; getting argc (argument count)
  pop ebx         ; getting argv[0] (program name)
  pop edx         ; getting first opperand
  mov edi, edx    ; move first operand string to edi
  call str_len    ; getting lenght of string
  call print_digit_from_ecx
  ; pop edx         ; getting second operand

; mul_loop:       ; loop lable
;   add ebx, ebx    ; adding first operand to itself (basicly multiplying by 2)
;   loop mul_loop   ; starting loop, we have counter (second operand) in ecx already

;   mov ecx, ebx    ; moving result to ecx, because we will be printing it on screen
;   mov edx,1       ; setting lenght of printed string
;   mov eax,4       ; system call for write (sys_write)
;   mov ebx,1       ; name of file (1 is for standard output)
;   int 80h         ; calling kernel

  mov eax, 1       ; system call for exit (sys_exit)
  mov ebx, 0       ; return code 0 (no error)
  int 80h          ; calling kernel

; write function to covenert string to int
; get length of string
; then compare each char to digit and add that digit to result

str_len:
        sub ecx, ecx      ; setting ecx to 0
        not ecx           ; setting ecx to highest possible value
        sub al, al        ; setting al to 0
                          ; assume that start of sting is in edi
        cld               ; clearing direction flag
  repne scasb             ; finding start of string
                          ; ecx now is equal to -strlen - 2
        neg ecx           ; negate ecx to get strlen + 2
        dec ecx
        dec ecx           ; now we got in ecx strlen
        ret               ; return from subprocedure

print_digit_from_ecx:
        add ecx, 48            ; adding 48 to get ascii value of digit
        mov dword [msg], ecx   ; moving value to memory location at msg
        mov dword [msg+1], 0xa ; adding line terminatior to msg
        mov ecx, msg           ; geting memory adress of msg to ecx
        mov edx, 2             ; setting lenght of printed string (one digit + one line terminator)
        mov eax, 4             ; system call for write (sys_write)
        mov ebx, 1             ; name of file (1 is for standard output)
        int 80h                ; calling kernel
        ret

section .bss
  msg: resd 2


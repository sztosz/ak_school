section .text
  global _start

_start:
  pop eax                   ; getting argc (argument count)
  pop ebx                   ; getting argv[0] (program name)
  pop edi                   ; getting first opperand string
  mov ebx, edi
  call str_len              ; getting lenght of string
  mov edi, ebx
  xor eax, eax              ; zeroing eax
  call convert_string_to_int; converting, eax has now int we want
  pop edi                   ; getting second opperand string
  mov ebx, edi
  push eax                  ; storing first operand int to stack
  call str_len              ; getting lenght of string
  mov edi, ebx
  xor eax, eax              ; zeroing eax
  call convert_string_to_int; converting, eax has now int we want
  pop edx                   ; get multiplier we stored into edx
  mov ecx, eax              ; move multiplicand to ecx (loop counter)
  xor eax, eax              ; zeroing eax
  call mul_loop             ; doing actual multiplication
  call print_int_as_str     ; print value of eax

  mov eax, 1       ; system call for exit (sys_exit)
  mov ebx, 0       ; return code 0 (no error)
  int 80h          ; calling kernel


  ; add ecx, 48     ; adding 48 to get ascii value of digit  
  ; print_loop:
  ;   mov dword [counter], ecx  ; store lenght in counter (could use stack!)
  ;   mov ecx, [edx]            ; get first char to ecx
  ;   inc edx                   ; get next char adress into edx
  ;   push edx                  ; push edx to stack
  ;   call print_value_of_ecx   ; print ecx value
  ;   pop edx                   ; pop from stack to edx
  ;   mov dword ecx, [counter]  ; restore counter value (could use stack!)
  ;   loop print_loop

  ; mov edx, 1             ; setting lenght of printed string (one digit + one line terminator)
  ; mov eax, 4             ; system call for write (sys_write)
  ; mov ebx, 1             ; name of file (1 is for standard output)
  ; int 80h

  
  ; pop edx         ; getting second operand

;   mov ecx, ebx    ; moving result to ecx, because we will be printing it on screen
;   mov edx,1       ; setting lenght of printed string
;   mov eax,4       ; system call for write (sys_write)
;   mov ebx,1       ; name of file (1 is for standard output)
;   int 80h         ; calling kernel


; write function to covenert string to int
; get length of string
; then compare each char to digit and add that digit to result

; print_value_of_ecx:            ; prints exact value of ecx as ascii
;         mov dword [msg], ecx   ; moving value to memory location at msg
;         mov dword [msg+1], 0xa ; adding line terminatior to msg
;         mov ecx, msg           ; geting memory adress of msg to ecx
;         mov edx, 2             ; setting lenght of printed string (one digit + one line terminator)
;         mov eax, 4             ; system call for write (sys_write)
;         mov ebx, 1             ; name of file (1 is for standard output)
;         int 80h                ; calling kernel
;         ret

str_len:
        xor ecx, ecx      ; setting ecx to 0
        not ecx           ; setting ecx to highest possible value
        xor al, al        ; setting al to 0
                          ; assume that start of string is in edi
        cld               ; clearing direction flag
  repne scasb             ; finding start of string
                          ; ecx now is equal to -strlen - 2
        neg ecx           ; negate ecx to get strlen + 2
        dec ecx
        dec ecx           ; now we got in ecx strlen
        ret               ; return from subprocedure


mul_loop:         ; loop lable counter (multiplier) is in ecx, multiplicand in edx
  add eax, edx    ; adding first operand to itself (basicly multiplying by 2)
  loop mul_loop   ; starting loop, we have counter (second operand) in ecx already
  ret             ; return from subprocedure

  ; xor eax, eax              ; zeroing eax
  ; call str_len              ; getting lenght to ecx
convert_string_to_int:      ; string start in edi, eax should be set to 0, and ecx should have string lenght!!!
  push ecx                  ; storing ecx (counter loop) at stack
  mov ecx, 10               ; preapering counter (multiplier) for mul_loop
  mov edx, eax              ; move multiplicand to edx
  call mul_loop             ; multiplying edx by ecx and storing result in eax
  movzx edx, byte [edi]     ; get char from string to edx and convert it to proper type (zero extend)
  sub edx, 48               ; converting ascii to int
  add eax, edx              ; adding value of edx int to result we keep in eax 
  pop ecx                   ; get ecx value from stack
  inc edi                   ; increment edi to get next char ready for processing
  inc edi
  loop convert_string_to_int; loop to get other next digit in string
  ret

print_int_as_str:           ; eax shoudl have int we want to print
  push eax                  ; pushing eax to stack
  push edx                  ; pushing edx to stack
  xor edx, edx              ; zeroing edx
  div dword [const10]       ; dividing eax by const10 value wchis is 10. eax gets quotient, and edx remainder
  test eax, eax             ; testing if quotient is equal to 0  
  je print_digit            ; if quotient is equal to 0 jump to print
  print_digit:
    ; mov ecx, [edx+'0']      ; moving edx (the remainder of division) to ecx to print it
    mov ecx, edx      ; moving edx (the remainder of division) to ecx to print it
    mov edx, 2              ; setting lenght of printed string (two digit + one line terminator)
    mov eax, 4              ; system call for write (sys_write)
    mov ebx, 1              ; name of file (1 is for standard output)
    int 80h                 ; calling kernel
    pop edx                 ; restoring edx value from stack
    pop eax                 ; restoring eax value from stack
    ret                     ; return from subprocedure

section .bss
  msg: resd 2     ; 2 dword's for message to print
  counter resd 1  ; 1 dword to store how many digits we have for loop use
  ; 1_op resb 10    ; 10 bytes to store first operand
  ; 2_op resb 10    ; 10 bytes to store second operand

section .data
  const10 dd 10     ; integer 10 stored in dword

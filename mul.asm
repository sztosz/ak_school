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

  mov dword [msg], 0xA      ; moving value to memory location at msg
  mov ecx, msg              ; geting memory adress of msg to ecx
  mov edx, 1                ; setting lenght of printed string (two digit + one line terminator)
  mov eax, 4                ; system call for write (sys_write)
  mov ebx, 1                ; name of file (1 is for standard output)
  int 80h                   ; calling kernel

  mov eax, 1                ; system call for exit (sys_exit)
  mov ebx, 0                ; return code 0 (no error)
  int 80h                   ; calling kernel

str_len:
  xor ecx, ecx              ; setting ecx to 0
  not ecx                   ; setting ecx to highest possible value
  xor al, al                ; setting al to 0
                            ; assume that start of string is in edi
  cld                       ; clearing direction flag
  repne scasb               ; finding start of string
                            ; REPNE (REPeat while Not Equal)
                            ; SCAS+B (SCan A String)+(scan byte string)
                            ; ecx now is equal to -strlen - 2
  neg ecx                   ; negate ecx to get strlen + 2
  dec ecx
  dec ecx                   ; now we got in ecx strlen
  ret                       ; return from subprocedure


mul_loop:                   ; loop lable counter (multiplier) is in ecx, multiplicand in edx
  add eax, edx              ; adding first operand to itself (basicly multiplying by 2)
  loop mul_loop             ; starting loop, we have counter (second operand) in ecx already
  ret                       ; return from subprocedure

  ; xor eax, eax            ; zeroing eax
  ; call str_len            ; getting lenght to ecx
convert_string_to_int:      ; string start in edi, eax should be set to 0, and ecx should have string lenght!!!
  push ecx                  ; storing ecx (counter loop) at stack
  mov ecx, 9                ; preapering counter (multiplier) for mul_loop (we need to loop 9 times x * 10 = x + 9 * x, we have already x * 1 in registry)
  mov edx, eax              ; move multiplicand to edx
  call mul_loop             ; multiplying edx by ecx and storing result in eax
  movzx edx, byte [edi]     ; get char from string to edx and convert it to proper type (zero extend)
  sub edx, 48               ; converting ascii to int
  add eax, edx              ; adding value of edx int to result we keep in eax 
  pop ecx                   ; get ecx value from stack
  inc edi                   ; increment edi to get next char ready for processing
  loop convert_string_to_int; loop to get other next digit in string
  ret

print_int_as_str:           ; eax shoudl have int we want to print
  push eax                  ; pushing eax to stack
  push edx                  ; pushing edx to stack
  xor edx, edx              ; zeroing edx
  div dword [const10]       ; dividing eax by const10 value wchis is 10. eax gets quotient, and edx remainder
  test eax, eax             ; testing if quotient is equal to 0  
  je print_digit            ; if quotient is equal to 0 jump to print
  call print_int_as_str     ; else get back to dividing untill we get 0 in above step
  print_digit:
    add edx, 48             ; add 48 to get ascii value
    mov dword [msg], edx    ; moving value to memory location at msg
    mov ecx, msg            ; geting memory adress of msg to ecx
    mov edx, 1              ; setting lenght of printed string (two digit + one line terminator)
    mov eax, 4              ; system call for write (sys_write)
    mov ebx, 1              ; name of file (1 is for standard output)
    int 80h                 ; calling kernel
    pop edx                 ; restoring edx value from stack
    pop eax                 ; restoring eax value from stack
    ret                     ; return from subprocedure

section .bss
  msg: resd 1               ; 2 dword's for message to print
  counter resd 1            ; 1 dword to store how many digits we have for loop use

section .data
  const10 dd 10             ; integer 10 stored in dword

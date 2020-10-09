format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVecElemOut  db '[%d] = %d', 10, 0
        strNewVector   db 'Vector B:',10,0
        strZeroNewVector   db 'Vector B is empty',0

        vec_size     dd 0
        new_vec_size dd 0
        max_vec_size dd 100
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        min          dd 0
        vec          rd 100
        new_vec      rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) get vector mi
        call VectorMin
; 3) get vector mi
        call VectorBGenerator
; 4) test vector out
       push strNewVector
       call[printf]
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax,[max_vec_size]
        jg failSize
        cmp eax, 0
        jg  getVector
; fail size
failSize:
        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorMin:

        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov ebp, vec            ; min
minVecLoop:
        ;mov [tmp], ebx
        cmp ecx, [vec_size]
        je endMinVector      ; to end of loop
        cmp ebp,[ebx]
        jle nextMinVecLoop  ; element not min skippimg
        mov ebp,[ebx]      ; save new min element
        mov [min], ebp
nextMinVecLoop:
        inc ecx
        add ebx, 4
        jmp minVecLoop
endMinVector:
        ret
;--------------------------------------------------------------------------
VectorBGenerator:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec
        mov edx,new_vec; ebx = &vec
newVecLoop:
        cmp ecx, [vec_size]
        je endNewSumVector      ; to end of loop
        mov eax,[min]
        cmp eax,[ebx]
        je nextNewVecLoop  ; skipping elemets equal to min
        inc [new_vec_size]
        mov ebp, [ebx]
        mov [edx], ebp
        add edx,4
nextNewVecLoop:
        inc ecx
        ;mov ebx, [tmp]
        add ebx, 4
        jmp newVecLoop
endNewSumVector:
        mov esp, [tmpStack]
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, new_vec        ; ebx = &new_vec

        cmp [new_vec_size],0
        je zeroElements
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [new_vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
zeroElements:
        push strZeroNewVector
        call [printf]
endOutputVector:
        mov esp, [tmpStack]
        ret

;--------------------------------------------------------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'

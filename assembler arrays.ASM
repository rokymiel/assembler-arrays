format PE console
entry start

include 'win32a.inc'

; Êóçíåöîâ Ìèõàèë Àëåêñíäðîâè÷ ÁÏÈ199
; 13 âàðèàíò
; Ìàññèâ èç ýëåìåíòîâ íå ðàâíûõ ìèíèìóìó
;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Enter size of vector A: ', 0
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
; 1) Ââîä ìàññèâà À
        call VectorInput
; 2) Ïîèñê ìèíèìàëüíîãî ýëåìåíòà
        call VectorMin
; 3) Çàïîëíåíèå ìàññèâà B
        call VectorBGenerator
; 4) Âûâîä íîâîãî ìàññèâà
        push strNewVector
        call[printf]
        call VectorOut
finish:                         ; Çàâåðøåíèåðàáîòû ïðîãðàììû
        call [getch]
        push 0
        call [ExitProcess]

;-------------------------------Ââîä ìàññèâà è åãî äëèíû-------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt         ; ñ÷èòûâàíèå äëèíû ìàññèâà À
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax,[max_vec_size]  ; ïðîâåðêà, ÷òî ââåäåííàÿ äëèíà áîëüøå 0 è ìåíüøå èëè ðàâíà 100
        jg failSize
        cmp eax, 0
        jg  getVector
; fail size
failSize:                       ; Âûâîä ñîîáùåíèÿ î íåêîððåêòíîé äëèíå
        push [vec_size]
        push strIncorSize
        call [printf]
        jmp finish
; else continue...
getVector:                      ; Ââîä ýëåìåíòîâ ìàññèâà
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector      ; to end of loop

        mov [i], ecx
        push ecx
        push strVecElemI        ; Îòîáðàæåíèå ñîîáùåíèÿ
        call [printf]
        add esp, 8

        push ebx
        push strScanInt         ; Ñ÷èòûâàíèå ââåäåííîãî ýëåìåíòà
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;------------------------------ Ïîèñê ìèíèìàëüíîãî ýëåìåíòà------------------
VectorMin:

        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov ebp, vec            ; min
minVecLoop:
        cmp ecx, [vec_size]
        je endMinVector      ; to end of loop

        cmp ebp,[ebx]
        jle nextMinVecLoop      ; Åñëè ýëåìåíò íå ìåíüøå ìèíèìóìà òî ïåðåõîäèì
        mov ebp,[ebx]           ; ñîõðàíåíèå íîâîãî ìèíèìàëüíîãî ýëåìåíòà
        mov [min], ebp

nextMinVecLoop:
        inc ecx
        add ebx, 4
        jmp minVecLoop
endMinVector:
        ret
;------------------------------Ñîçäàíèå íîâîãî ìàññèâ-----------------------
VectorBGenerator:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec            ; ebx = &vec
        mov edx,new_vec         ; edx = &new_vec
newVecLoop:
        cmp ecx, [vec_size]
        je endNewSumVector      ; to end of loop
        mov eax,[min]
        cmp eax,[ebx]
        je nextNewVecLoop       ; Ïðîïóñê ýëåìåíòîâ ðàâíûõ ìèíèìàëüíîìó

        inc [new_vec_size]
        mov ebp, [ebx]          ; Äîáàâëåíèå ýëåìåíòà â íîâûé ìàññèâ
        mov [edx], ebp
        add edx,4

nextNewVecLoop:
        inc ecx
        add ebx, 4
        jmp newVecLoop
endNewSumVector:
        mov esp, [tmpStack]
        ret
;------------------------------Âûâîä íîâîãî ìàññèâà---------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, new_vec        ; ebx = &new_vec

        cmp [new_vec_size],0    ; Ïðîâåðêà äëèíû íîâîãî ìàññèâà
        je zeroElements         ; Åñëè äëèíà ðàâíà 0 çíà÷èò â ìàññèâå íåò ýëåìåíòîâ è îòîáðàæàåòñÿ ñîîòâåòñòâóþùåå ñîîáùåíèå
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [new_vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx


        push dword [ebx]
        push ecx                ; output element
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
zeroElements:                   ; Îòîáðàæåíèå ñîîáùåíèÿ î ïóñòîì ìàññèâå Â
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

; Author : 222001816 MP RAGOPHALA
; Practical : P05

; Set up the environment
.386                           ; Use 80386 instruction set
.MODEL FLAT                    ; Flat memory model
.STACK 4096                    ; Set stack size to 4096 bytes

; Include functions for I/O (you need to have io.inc with input/output routines)
INCLUDE io.inc

; Prototype for the exit function
ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

.DATA
; Data section to store static variables and strings
strAgePrompt              BYTE "Please enter your age: ", 0
strHRFPrompt              BYTE "Please enter your HRF: ", 0
strArrayPrompt1           BYTE "Please enter the level for index ", 0
strArrayPrompt2           BYTE "Please enter the duration for index ", 0
strScoresPrompt           BYTE "The health scores are: ", 0
strLoopPrompt             BYTE "Do you wish to process another round (0 - No, 1 - Yes)? ", 0

; Variables for user input
age                       DWORD ?        ; Variable to store user's age
hrf                       DWORD ?        ; Variable to store user's HRF

; Arrays for level, duration, and score
levelArray                DWORD 5 DUP (?)  ; Array to store 5 levels
durationArray             DWORD 5 DUP (?)  ; Array to store 5 durations
scoreArray                DWORD 5 DUP (?)  ; Array to store 5 scores

.CODE
;=============================Input function==================================
input PROC NEAR32
    push    ebp                      ; Save base pointer
    mov     ebp, esp                 ; Set base pointer to current stack pointer
    push    ebx                      ; Save registers
    push    ecx
    push    edx

    mov     ecx, 0                   ; Initialize loop counter
    mov     ebx, [ebp+8]             ; Get the address of the array into ebx

inputLoop:
    lea     eax, strArrayPrompt1     ; Load the prompt string into eax
    push    eax
    call    OutputStr                ; Print the prompt
    push    ecx                      ; Push index (ecx) to the stack for output
    call    OutputInt                ; Print the index
    call    InputInt                 ; Get the integer input from the user
    mov     [ebx], eax               ; Store the input value in the array
    add     ebx, 4                   ; Move to the next element in the array
    inc     ecx                      ; Increment loop counter
    cmp     ecx, [ebp+12]            ; Compare counter with array length
    jl      inputLoop                ; If less, loop again

    pop     edx                      ; Restore registers
    pop     ecx
    pop     ebx
    mov     esp, ebp                 ; Restore stack pointer
    pop     ebp                      ; Restore base pointer
    ret     8                        ; Return from the function, clean up stack
input ENDP

;=============================Display function==================================
display PROC NEAR32
    push    ebp                      ; Save base pointer
    mov     ebp, esp                 ; Set base pointer to current stack pointer
    push    ebx                      ; Save registers
    push    ecx

    mov     ecx, 0                   ; Initialize loop counter
    mov     ebx, [ebp+8]             ; Get the address of the array into ebx

displayLoop:
    mov     eax, [ebx]               ; Load the current array element into eax
    push    eax
    call    OutputInt                ; Print the value
    add     ebx, 4                   ; Move to the next element in the array
    inc     ecx                      ; Increment loop counter
    cmp     ecx, [ebp+12]            ; Compare counter with array length
    jl      displayLoop              ; If less, loop again

    pop     ecx                      ; Restore registers
    pop     ebx
    mov     esp, ebp                 ; Restore stack pointer
    pop     ebp                      ; Restore base pointer
    ret     8                        ; Return from the function, clean up stack
display ENDP

;=============================HealthScore function===============================
healthScore PROC NEAR32
    push    ebp                      ; Save base pointer
    mov     ebp, esp                 ; Set base pointer to current stack pointer
    push    eax                      ; Save registers
    push    edx

    ; Calculate the health score using the formula
    ; HealthScore = (level * duration * HRF) / (age / 10 + 5)

    mov     eax, [ebp+12]            ; Load 'level' into eax
    imul    eax, [ebp+16]            ; Multiply level by duration
    imul    eax, [ebp+20]            ; Multiply result by HRF
    mov     edx, [ebp+8]             ; Load 'age' into edx
    mov     ecx, 10                  ; Set divisor as 10
    cdq                              ; Sign-extend eax into edx:eax
    idiv    ecx                      ; Divide age by 10
    add     eax, 5                   ; Add 5 to the result
    cdq                              ; Sign-extend eax into edx:eax
    idiv    eax                      ; Divide (level * duration * HRF) by (age/10 + 5)

    pop     edx                      ; Restore registers
    pop     eax
    mov     esp, ebp                 ; Restore stack pointer
    pop     ebp                      ; Restore base pointer
    ret     16                       ; Return from the function, clean up stack
healthScore ENDP

;=============================FinalScore function==================================
finalScore PROC NEAR32
    push    ebp                      ; Save base pointer
    mov     ebp, esp                 ; Set base pointer to current stack pointer
    push    eax                      ; Save registers
    push    ebx
    push    ecx

    mov     ecx, 0                   ; Initialize loop counter
    mov     ebx, [ebp+8]             ; Load 'age' into ebx
    mov     edx, [ebp+12]            ; Load 'levels array' base address into edx
    mov     esi, [ebp+16]            ; Load 'durations array' base address into esi
    mov     edi, [ebp+20]            ; Load 'scores array' base address into edi

finalScoreLoop:
    push    [esi]                    ; Push duration value onto the stack
    push    [edx]                    ; Push level value onto the stack
    push    [ebp+24]                 ; Push HRF value onto the stack
    push    ebx                      ; Push age value onto the stack
    call    healthScore              ; Call the healthScore function
    mov     [edi], eax               ; Store the result in the scores array
    add     edx, 4                   ; Move to the next element in levels array
    add     esi, 4                   ; Move to the next element in durations array
    add     edi, 4                   ; Move to the next element in scores array
    inc     ecx                      ; Increment loop counter
    cmp     ecx, 5                   ; Check if we've processed all elements
    jl      finalScoreLoop           ; If not, loop again

    pop     ecx                      ; Restore registers
    pop     ebx
    pop     eax
    mov     esp, ebp                 ; Restore stack pointer
    pop     ebp                      ; Restore base pointer
    ret     20                       ; Return from the function, clean up stack
finalScore ENDP

;=============================The main program that calls the various functions================================
_start:
    push    ebp                      ; Save base pointer
    mov     ebp, esp                 ; Set base pointer to current stack pointer

mainProg:
    ; Step 1: Ask the user for age and HRF
    lea     eax, strAgePrompt        ; Load age prompt string into eax
    push    eax
    call    OutputStr                ; Print the age prompt
    call    InputInt                 ; Get the age from user input
    mov     [age], eax               ; Store the age in memory

    lea     eax, strHRFPrompt        ; Load HRF prompt string into eax
    push    eax
    call    OutputStr                ; Print the HRF prompt
    call    InputInt                 ; Get the HRF from user input
    mov     [hrf], eax               ; Store the HRF in memory

    ; Step 2: Input for levels and durations arrays
    lea     eax, levelArray          ; Load the base address of levelArray into eax
    push    eax
    mov     eax, 5                   ; Load array length (5) into eax
    push    eax
    call    input                    ; Call input function to fill levelArray

    lea     eax, durationArray       ; Load the base address of durationArray into eax
    push    eax
    mov     eax, 5                   ; Load array length (5) into eax
    push    eax
    call    input                    ; Call input function to fill durationArray

    ; Step 3: Display age and HRF
    mov     eax, [age]               ; Load age from memory into eax
    push    eax
    call    OutputInt                ; Display the age

    mov     eax, [hrf]               ; Load HRF from memory into eax
    push    eax
    call    OutputInt                ; Display the HRF

    ; Step 4: Display levels and durations arrays
    lea     eax, levelArray          ; Load the base address of levelArray into eax
    push    eax
    mov     eax, 5                   ; Load array length (5) into eax
    push    eax
    call    display                  ; Call display function to print levelArray

    lea     eax, durationArray       ; Load the base address of durationArray into eax
    push    eax
    mov     eax, 5                   ; Load array length (5) into eax
    push    eax
    call    display                  ; Call display function to print durationArray

    ; Step 5: Calculate scores
    lea     eax, scoreArray          ; Load the base address of scoreArray into eax
    push    eax
    lea     eax, durationArray       ; Load the base address of durationArray into eax
    push    eax
    lea     eax, levelArray          ; Load the base address of levelArray into eax
    push    eax
    mov     eax, [age]               ; Push age onto the stack
    push    eax
    mov     eax, [hrf]               ; Push HRF onto the stack
    push    eax
    call    finalScore               ; Call finalScore to calculate all health scores

    ; Step 6: Display scores
    lea     eax, scoreArray          ; Load the base address of scoreArray into eax
    push    eax
    mov     eax, 5                   ; Load array length (5) into eax
    push    eax
    call    display                  ; Call display function to print scoreArray

    ; Step 7: Ask if the user wants to repeat
loopUser:
    lea     eax, strLoopPrompt       ; Load loop prompt string into eax
    push    eax
    call    OutputStr                ; Print the loop prompt
    call    InputInt                 ; Get user input (0 or 1)
    cmp     eax, 0                   ; Check if the user entered 0
    je      quit                     ; If yes, exit the program
    cmp     eax, 1                   ; Check if the user entered 1
    je      mainProg                 ; If yes, restart the main program
    jmp     loopUser                 ; Otherwise, ask again

quit:
    mov     esp, ebp                 ; Restore stack pointer
    pop     ebp                      ; Restore base pointer
    INVOKE ExitProcess, 0            ; Exit the program

Public _start
END
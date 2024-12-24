.data
    v: .space 1024
    poz_add: .long 0
    nr_operatii: .space 4
    nr_fisiere: .space 4
    file_descriptor: .space 4
    file_dimensiune: .space 4
    operatie: .space 4
    fisiere_totale: .long 0
    capatS: .space 4
    capatD: .space 4
    citire: .asciz "%d"
    advertisment: .asciz "nu exista suficient spatiu in memorie pentru %d\n"
    format_add: .asciz "%d: (%d, %d)\n"
    format_get: .asciz "(%d, %d)\n"

.text
ADD1:
    push %ebp
    push %ebx
    mov %esp, %ebp

    push $nr_fisiere
    push $citire
    call scanf
    add $8, %esp
    
    movl nr_fisiere, %ebx

    movl $0, poz_add
    xor %ebx, %ebx

    ADD1_for1:
        cmp %ebx, nr_fisiere
        je ADD1_exit

        push $file_descriptor
        push $citire 
        call scanf
        add $8, %esp

        push $file_dimensiune
        push $citire 
        call scanf
        add $8, %esp

        movl file_dimensiune, %eax
        xor %edx, %edx
        mov $8, %ecx
        div %ecx
        
        ADD1_if:
            cmp $0, %edx
            jne ADD1_nedivizibil
            jmp ADD1_divizibil

        ADD1_nedivizibil:
            addl $1, %eax
            movl %eax, file_dimensiune
            inc %ebx
            jmp capete

        ADD1_divizibil:
            movl %eax, file_dimensiune
            inc %ebx

        capete:
            cmp $1, file_dimensiune
            je eroare

            movl $-1, capatS
            movl $-1, capatD

        ADD1_while1:
            movl capatD, %esi
            subl capatS, %esi
            addl $1, %esi

            cmp file_dimensiune, %esi
            jae PRE

            cmp $1024, file_dimensiune
            ja eroare

            cmp $1024, poz_add
            jae eroare

            push %edx
            push %eax
            push %ecx
            push $0
            call TEST1
            add $4, %esp
            pop %ecx
            pop %eax
            pop %edx
            
            cmp $-1, capatS
            je eroare

            addl $1, poz_add
            jmp ADD1_while1

        PRE:
            movl capatS, %esi
            movl %esi, capatD
            addl %eax, capatD
            subl $1, capatD
        ADD1_for2:
            cmp %esi, capatD
            jb ADD1_afis

            movb file_descriptor, %cl 
            movb %cl, (%edi, %esi, 1)

            inc %esi
            jmp ADD1_for2

        ADD1_afis:

            push capatD
            push capatS
            push file_descriptor
            push $format_add
            call printf
            addl $16, %esp

            movl capatS, %esi
            addl file_dimensiune, %esi
            movl $0, poz_add
            addl $1, fisiere_totale

            jmp ADD1_for1

        eroare:
            movl $0, capatD
            movl $0, capatS
            push capatD
            push capatS
            push file_descriptor
            push $format_add
            call printf
            addl $16, %esp

            movl capatS, %esi
            addl file_dimensiune, %esi
            movl $0, poz_add

            jmp ADD1_for1

    ADD1_exit:

        pop %ebx
        pop %ebp
        ret


TEST1:
    push %ebp
    mov %esp, %ebp

    movl poz_add, %ecx
    movl $-1, capatD
    movl $-1, capatS

    TEST1_while1:
        cmp $1024, %ecx
        jae TEST1_exit
        movb (%edi, %ecx, 1), %al
        cmp 8(%ebp), %al
        je St
        inc %ecx
        jmp TEST1_while1

    St:
        movl %ecx, capatS

    TEST1_while2:
        cmp $1024, %ecx
        jae TEST1_exit
        movb (%edi, %ecx, 1), %al
        cmp 8(%ebp), %al
        jne TEST1_exit
        inc %ecx
        jmp TEST1_while2

TEST1_exit:
    movl %ecx, capatD
    subl $1, capatD

    pop %ebp
    ret

GET1:
    push %ebp
    mov %esp, %ebp

    xor %ecx, %ecx
    movl $0, capatD
    movl $0, capatS
    
    GET1_for1:
        cmp $1024, %ecx
        jae GET1_exit
        xor %eax, %eax
        movb (%edi, %ecx, 1), %al
        cmp %eax, 8(%ebp)
        je gasitS
        inc %ecx
        jmp GET1_for1

    gasitS:
        movl %ecx, capatS

    GET1_for2:
        cmp $1024, %ecx
        jae gasitD
        xor %eax, %eax
        movb (%edi, %ecx, 1), %al
        cmp %eax, 8(%ebp)
        jne gasitD
        inc %ecx
        jmp GET1_for2

    gasitD:
        subl $1, %ecx
        movl %ecx, capatD

GET1_exit:
    push capatD
    push capatS
    push $format_get
    call printf
    add $12, %esp

    pop %ebp
    ret

DEL1:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %edi

    push $file_descriptor
    push $citire
    call scanf
    addl $8, %esp
    
            push %edx
            push %eax
            push %ecx
            push file_descriptor
            call TEST1
            add $4, %esp
            pop %ecx
            pop %eax
            pop %edx
            
            movl capatS, %eax
            cmp $-1, %eax
            je DEL1_exit

    movb $0, %al
    xor %ebx, %ebx
    xor %eax, %eax

    DEL1_for1:
        cmp $1024, %ebx
        je DEL1_adev

        movb (%edi, %ebx, 1), %ah
        cmp file_descriptor, %ah
        je DEL1_stergere
        jmp DEL1_incrementare

        DEL1_stergere:
            movb %al, (%edi, %ebx, 1)
        
        DEL1_incrementare:
            inc %ebx
            jmp DEL1_for1

    DEL1_adev:
        subl $1, fisiere_totale
    
DEL1_exit:

    push %eax
    push %ecx
    push %edx
    call AFISARE1
    pop %edx
    pop %ecx
    pop %eax

    pop %edi
    pop %ebx
    pop %ebp
    ret

DEFRAG1:
    push %ebp
    push %ebx
    mov %esp, %ebp
    
    xor %ebx, %ebx
    xor %ecx, %ecx
    xor %edx, %edx
    xor %esi, %esi
    movl $0, poz_add

    DEFRAG1_for1:
        cmp $1024, %ebx
        je DEFRAG1_for2

        DEFRAG1_if:
            movb (%edi, %ebx, 1), %al
            cmp $0, %al
            je DEFRAG1_caz1
            jmp DEFRAG1_caz2

        DEFRAG1_caz1:
            inc %ecx
            inc %ebx
            jmp DEFRAG1_for1

        DEFRAG1_caz2:
            inc %edx
            movl %ebx, %esi
            subl %ecx, %esi
            movb (%edi, %ebx, 1), %al   
            movb %al, (%edi, %esi, 1)
            inc %ebx
            movl %ebx, poz_add
            jmp DEFRAG1_for1

    DEFRAG1_for2:
        inc %esi
        movl $0, %eax
        movb %al, (%edi, %esi, 1)
        cmp %esi, poz_add
        jbe DEFRAG1_exit
        jmp DEFRAG1_for2

DEFRAG1_exit:
    movl %edx, poz_add

    push %eax
    push %ecx
    push %edx
    call AFISARE1
    pop %edx
    pop %ecx
    pop %eax

    pop %ebx
    pop %ebp
    ret

AFISARE1:
    push %ebp
    push %ebx
    mov %esp, %ebp

    xor %edx, %edx
    xor %eax, %eax
    xor %ebx, %ebx
    xor %ecx, %ecx
    movl $0, poz_add

    AFISARE1_for1:
        cmp fisiere_totale, %edx
        jae AFISARE1_exit
        movb (%edi, %ebx, 1), %al 
        cmp $0, %al
        je AFISARE1_incrementare

        push %edx
        push %ecx
        push %eax
        call TEST1
        pop %eax
        pop %ecx
        pop %edx

        push %edx
        push capatD
        push capatS
        push %eax
        push $format_add
        call printf
        addl $16, %esp
        pop %edx

        movl capatD, %ebx
        inc %ebx
        inc %edx
        jmp AFISARE1_for1

        AFISARE1_incrementare:
            cmp $0, %al 
            jne AFISARE1_for1
            inc %ebx
            movb (%edi, %ebx, 1), %al 
            jmp AFISARE1_incrementare

AFISARE1_exit:
    pop %ebx
    pop %ebp
    ret

.global main

main:
    push $nr_operatii
    push $citire
    call scanf
    addl $8, %esp
    
    lea v, %edi
    xor %ebx, %ebx

    main_for:
        cmp %ebx, nr_operatii
        je exit

        push $operatie
        push $citire
        call scanf
        addl $8, %esp
        mov operatie, %ecx

        cmp $1, %ecx
        je ADD1_redir

        cmp $2, %ecx
        je GET1_redir

        cmp $3, %ecx
        je DEL1_redir
        
        cmp $4, %ecx
        je DEFRAG1_redir

        cmp $5, %ecx
        je AFISARE1_redir

        cmp $6, %ecx
        je TEST1_redir

        ADD1_redir:
            call ADD1
            jmp main_for_incrementare

        GET1_redir:
        
            push $file_descriptor
            push $citire
            call scanf
            add $8, %esp

            push file_descriptor
            call GET1
            add $4, %esp
            jmp main_for_incrementare

        DEL1_redir:
            push %eax
            call DEL1
            pop %eax
            jmp main_for_incrementare

        DEFRAG1_redir:
            push %eax
            push %ecx
            call DEFRAG1
            pop %ecx
            pop %eax
            jmp main_for_incrementare

        AFISARE1_redir:
            push %eax
            push %ecx
            push %edx
            call AFISARE1
            pop %edx
            pop %ecx
            pop %eax
            jmp main_for_incrementare

        TEST1_redir:
            push %eax
            push %ecx
            push %edx
            push $0
            call TEST1
            add $4, %esp
            pop %edx
            pop %ecx
            pop %eax
            jmp main_for_incrementare

        main_for_incrementare:
            inc %ebx
            jmp main_for

exit:
    pushl $0
    call fflush
    popl %eax
    
    mov $1, %eax
    mov $0, %ebx
    int $0x80
.data
    m: .space 1048576
    linie: .long 0
    coloana: .long 0
    nr_fisiere: .space 4
    nr_operatii: .space 4
    fisiere_totale: .long 0
    operatie: .space 4
    capatS: .space 4
    capatD: .space 4
    poz_add: .long 0
    conditie: .long 0
    file_descriptor: .space 4
    file_dimensiune: .space 4
    citire: .asciz "%d"
    afisare_test: .asciz "%d "
    format_get: .asciz "((%d, %d), (%d, %d))\n"
    format_add: .asciz "%d: ((%d, %d), (%d, %d))\n"
    newline: .asciz "\n"
.text 

ADD2:
    push %ebp
    push %ebx
    mov %esp, %ebp

    push $nr_fisiere
    push $citire
    call scanf
    add $8, %esp
    
    movl $0, poz_add
    xor %ebx, %ebx

    ADD2_for1:
        cmp %ebx, nr_fisiere
        je ADD2_exit

        push $file_descriptor
        push $citire 
        call scanf
        add $8, %esp

        push $file_dimensiune
        push $citire 
        call scanf
        add $8, %esp

        movl $0, poz_add
        movl $0, %esi

        movl file_dimensiune, %eax
        xor %edx, %edx
        mov $8, %ecx
        div %ecx
        
        xor %ecx, %ecx

        ADD1_if:
            cmp $0, %edx
            jne ADD1_nedivizibil
            jmp ADD1_divizibil

        ADD1_nedivizibil:
            addl $1, %eax
            movl %eax, file_dimensiune
            inc %ebx
            jmp ADD2_for2

        ADD1_divizibil:
            movl %eax, file_dimensiune
            inc %ebx

        ADD2_for2:

            push %esi
            push %eax
            push %ecx
            push %edx
            push $0
            call TEST2
            addl $4, %esp
            pop %edx
            pop %ecx
            pop %eax
            pop %esi

            movl capatS, %ecx
            cmp $-1, %ecx
            je ADD2_eroare

            movl capatS, %ecx
            movl %ecx, capatD

            movl file_dimensiune, %ecx
            addl %ecx, capatD

            subl $1, capatD
            movl capatS, %ecx

        ADD2_adaugare:
            cmp capatD, %ecx
            ja ADD2_afisare

            xor %eax, %eax
            movb file_descriptor, %al
            movb %al, (%edi, %ecx, 1)

            inc %ecx
            jmp ADD2_adaugare
        
        ADD2_afisare:
            movl capatD, %eax
            xor %edx, %edx
            movl $1024, %ecx
            divl %ecx

            push %edx
            movl %eax, linie
            push linie

            movl capatS, %eax
            xor %edx, %edx
            movl $1024, %ecx
            divl %ecx

            push %edx
            push %eax
            push file_descriptor
            push $format_add
            call printf
            addl $24, %esp
            
            addl $1, fisiere_totale
            jmp ADD2_for1

        ADD2_eroare:
            push $0
            push $0
            push $0
            push $0
            push file_descriptor
            push $format_add
            call printf
            addl $24, %esp

            jmp ADD2_for1

ADD2_exit:
    pop %ebx
    pop %ebp
    ret

TEST2:
    push %ebp
    mov %esp, %ebp
    push %ebx
    
    xor %ecx, %ecx
    xor %eax, %eax
    xor %edx, %edx
    xor %ebx, %ebx
    xor %esi, %esi

    TEST2_index:
        addl $1024, %esi

    TEST2_start:
        movl $-1, capatS
        movl $-1, capatD
        cmp $1048576, %esi
        je TEST2_exit

    TEST2_while1:
        cmp %esi, %ecx
        je TEST2_index

        xor %ebx, %ebx
        movb (%edi, %ecx, 1), %bl
        cmp %ebx, 8(%ebp)
        je TEST2_gasitS
        
        inc %ecx
        jmp TEST2_while1
    
    TEST2_gasitS:
        movl %ecx, capatS
    
    TEST2_while2:
        cmp %esi, %ecx
        je TEST2_gasitD

        xor %ebx, %ebx
        movb (%edi, %ecx, 1), %bl
        cmp %ebx, 8(%ebp)
        jne TEST2_gasitD
        
        inc %ecx
        jmp TEST2_while2

    TEST2_gasitD:
        movl %ecx, capatD
        subl $1, capatD
    
    TEST2_verif1:
        movl capatD, %eax
        subl capatS, %eax
        inc %eax
        cmp file_dimensiune, %eax
        jl TEST2_start

TEST2_exit:
    pop %ebx
    pop %ebp
    ret

DEL2:
    push %ebp
    mov %esp, %ebp
    push %ebx

    movl $0, file_dimensiune

    push $file_descriptor
    push $citire
    call scanf
    addl $8, %esp

    push %esi
    push %eax
    push %ecx
    push %edx
    push file_descriptor
    call TEST2
    addl $4, %esp
    pop %edx
    pop %ecx
    pop %eax
    pop %esi
    
    movl capatD, %eax
    movl capatS, %ecx
    cmp $-1, %ecx
    je DEL2_exit

    DEL2_for1:
        cmp %eax, %ecx
        ja DEL2_afisare

        movb $0, (%edi, %ecx, 1)

        inc %ecx
        jmp DEL2_for1
    
    DEL2_afisare:
        subl $1, fisiere_totale

DEL2_exit:

    push %esi
    push %eax
    push %ecx
    push %edx
    call AFISARE1
    pop %edx
    pop %ecx
    pop %eax
    pop %esi

    pop %ebx
    pop %ebp
    ret

DEFRAG2:
    push %ebp
    mov %esp, %ebp
    push %ebx
    
    xor %ebx, %ebx
    xor %ecx, %ecx
    xor %esi, %esi

    subl $24, %esp
    movl $0, -24(%ebp)

    DEFRAG2_start:

        movl $0, -4(%ebp)
        movl $0, -8(%ebp)

        movl %esi, %ecx
        addl $1024, %esi

        cmp $1048576, %esi
        jae DEFRAG2_exit

    DEFRAG2_for1:
        cmp %esi, %ecx
        je DEFRAG2_adaugare_zero1

        xor %eax, %eax
        movb (%edi, %ecx, 1), %al

        cmp $0, %eax
        je DEFRAG2_caz1
        jmp DEFRAG2_caz2

        DEFRAG2_caz1:
            addl $1, -4(%ebp)
            inc %ecx
            jmp DEFRAG2_for1
        
        DEFRAG2_caz2:
            movl %ecx, %ebx
            subl -4(%ebp), %ebx

            movb (%edi, %ecx, 1), %al
            movb %al, (%edi, %ebx, 1)
            
            inc %ecx
            jmp DEFRAG2_for1

        DEFRAG2_adaugare_zero1:
            movl %ecx, %eax
            subl -4(%ebp), %eax
            addl $1024, %eax

            cmp %ecx, %eax
            je DEFRAG2_eliminare_linie
            addl $1, %ebx

        DEFRAG2_for_zero1:
            cmp %ebx, %ecx
            je DEFRAG2_linia

            movb $0, (%edi, %ebx, 1)

            inc %ebx
            jmp DEFRAG2_for_zero1

        DEFRAG2_eliminare_linie:
            movl %ecx, %ebx
            subl $1024, %ebx
            movl %ecx, %edx
            addl $1, -24(%ebp)

        DEFRAG2_eliminare_linie_for:
            cmp $1024, -24(%ebp)
            jae DEFRAG2_exit

            cmp $1047552, %ebx
            jae DEFRAG2_resetare_contor

            xor %eax, %eax
            movb (%edi, %edx, 1), %al
            movb %al, (%edi, %ebx, 1)
            inc %ebx
            inc %edx
            jmp DEFRAG2_eliminare_linie_for
        
        DEFRAG2_resetare_contor:
            cmp $1024, %ecx
            ja DEFRAG2_resetare_1
            jmp DEFRAG2_resetare_2

        DEFRAG2_resetare_1:
            subl $2048, %esi
            jmp DEFRAG2_start

        DEFRAG2_resetare_2:
            subl $1024, %esi
            jmp DEFRAG2_start

        DEFRAG2_linia:
            movl %ecx, %ebx
            movl %ecx, %edx
            addl $1024, %ecx   
            subl -4(%ebp), %edx

            DEFRAG2_while1:
            
                cmp %ebx, %ecx
                je DEFRAG2_start
                
                xor %eax, %eax
                movb (%edi, %ebx, 1), %al
                
                cmp $0, %eax
                je DEFRAG2_while_zero

                movl $0, file_dimensiune

                push %esi
                push %edx
                push %ecx
                push %eax
                call TEST2
                pop %eax
                pop %ecx
                pop %edx
                pop %esi

                movl capatD, %eax
                subl capatS, %eax
                addl $1, %eax
                movl %eax, -12(%ebp)

                cmp %eax, -4(%ebp)
                jb DEFRAG2_start

                movl %ebx, -16(%ebp)
                movl %ecx, -20(%ebp)
                movl %ebx, %ecx
                addl -12(%ebp), %ecx

                DEFRAG2_interschimbare:
                    cmp %ebx, %ecx
                    je DEFRAG2_interschimbare_over
                    
                    xor %eax, %eax
                    movb (%edi, %ebx, 1), %al
                    movb $0, (%edi, %ebx, 1)

                    movb %al, (%edi, %edx, 1)

                    inc %edx
                    inc %ebx
                    jmp DEFRAG2_interschimbare

                DEFRAG2_interschimbare_over:

                    movl -12(%ebp), %ebx
                    subl %ebx, -4(%ebp)
                    addl %ebx, -8(%ebp)
                    movl -20(%ebp), %ecx
                    movl -16(%ebp), %ebx
                    inc %ebx

                    jmp DEFRAG2_while1

                DEFRAG2_while_zero:
                    
                    addl $1, -8(%ebp)
                    inc %ebx
                    jmp DEFRAG2_while1
                
DEFRAG2_exit:
    addl $24, %esp

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
    xor %esi, %esi

    AFISARE1_for1:
        cmp fisiere_totale, %esi
        jae AFISARE1_exit
        movb (%edi, %ebx, 1), %al 
        cmp $0, %al
        je AFISARE1_incrementare
        
        push %esi
        push %edx
        push %ecx
        push %eax
        call TEST2
        pop %eax
        pop %ecx
        pop %edx
        pop %esi

        movl %eax, file_descriptor

        movl capatD, %eax
        movl $1024, %ecx
        xor %edx, %edx
        divl %ecx

        push %edx
        push %eax

        movl capatS, %eax
        movl $1024, %ecx
        xor %edx, %edx
        divl %ecx

        push %edx
        push %eax

        push file_descriptor
        push $format_add
        call printf
        addl $24, %esp

        movl capatD, %ebx
        inc %ebx
        inc %esi
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
    lea m, %edi 

    push $nr_operatii
    push $citire
    call scanf
    add $8, %esp

    xor %ebx, %ebx

    main_for:
        cmp nr_operatii, %ebx
        je exit

        push $operatie
        push $citire
        call scanf
        addl $8, %esp

        movl operatie, %ecx

        cmp $1, %ecx
        je ADD2_redir

        cmp $2, %ecx
        je GET2_redir

        cmp $3, %ecx
        je DEL2_redir

        cmp $4, %ecx
        je DEFRAG2_redir

        cmp $5, %ecx
        je AFI2_redir

        ADD2_redir:

            push %esi
            push %eax
            push %ecx
            push %edx
            call ADD2
            pop %edx
            pop %ecx
            pop %eax
            pop %esi

            jmp main_for_incrementare

        GET2_redir:
            
            movl $0, file_dimensiune

            push $file_descriptor
            push $citire
            call scanf
            add $8, %esp

            push %esi
            push %eax
            push %ecx
            push %edx

            push file_descriptor
            call TEST2
            add $4, %esp

            pop %edx
            pop %ecx
            pop %eax
            pop %esi

            movl capatS, %eax
            cmp $-1, %eax
            je GET2_redir_eroare

            movl capatD, %eax
            xor %edx, %edx
            movl $1024, %ecx
            divl %ecx

            push %edx
            movl %eax, linie
            push linie

            movl capatS, %eax
            xor %edx, %edx
            movl $1024, %ecx
            divl %ecx

            push %edx
            push %eax
            push $format_get
            call printf
            addl $20, %esp
            
            jmp main_for_incrementare

            GET2_redir_eroare:
                push $0
                push $0
                push $0
                push $0
                push $format_get
                call printf
                addl $20, %esp

            jmp main_for_incrementare

        DEL2_redir:

            push %esi
            push %eax
            push %ecx
            push %edx
            call DEL2
            pop %edx
            pop %ecx
            pop %eax
            pop %esi
            
            jmp main_for_incrementare
        
        DEFRAG2_redir:

            push %ebx
            push %esi
            push %eax
            push %ecx
            push %edx
            call DEFRAG2
            pop %edx
            pop %ecx
            pop %eax
            pop %esi
            pop %ebx

            push %esi
            push %eax
            push %ecx
            push %edx
            call AFISARE1
            pop %edx
            pop %ecx
            pop %eax
            pop %esi

            jmp main_for_incrementare

        AFI2_redir:
            
            push %esi
            push %eax
            push %ecx
            push %edx
            call AFISARE1
            pop %edx
            pop %ecx
            pop %eax
            pop %esi

        main_for_incrementare:
            inc %ebx
            jmp main_for

exit:
    pushl $0
    call fflush
    popl %eax

    movl $1, %eax
    movl $0, %ebx
    int $0x80

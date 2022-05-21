; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descricao: Exemplifica o acesso a um teclado.
; *            Le uma linha do teclado, verificando se ha alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos periferico de 8 bits
; *       atraves da instrucao MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENCAO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto nao altera o valor de 16 bits e permite distinguir numeros de identificadores
DISPLAYS     EQU 0A000H  ; endereco dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN      EQU 0C000H  ; endereco das linhas do teclado (periferico POUT-2)
TEC_COL      EQU 0E000H  ; endereco das colunas do teclado (periferico PIN)
LINHA        EQU 8       ; linha a testar (4a linha, 1000b) em variavel para fazer os shifts
MASCARA      EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
CONTADOR_L   EQU 4       ; conta a linha que está a ser verificada, começa na 4 e vai para baixo
CONTADOR_C   EQU 0       ; conta os SHR precisos para a coluna passar a ser 0 (para converter para o valor certo)

; **********************************************************************
; * Atribuições
; **********************************************************************
; R0  --> output do teclado              (colunas)
; R1  --> input do teclado               (linhas)
; R2  --> endereço input teclado
; R3  --> endereço output teclado
; R4  --> endereço display
; R5  --> mascara                        (isolar os 4 bits da direita)
; R6  --> contador do input do teclado
; R7  --> contador do output do teclado
; R9  --> valor da tecla primida
; R10 --> posição em linha da tecla
; R11 --> posição em coluna da tecla

; **********************************************************************
; * Codigo
; **********************************************************************
PLACE      0
inicio:		
; inicializacoes
    MOV  R2, TEC_LIN      ; endereco do periferico das linhas
    MOV  R3, TEC_COL      ; endereco do periferico das colunas
    MOV  R4, DISPLAYS     ; endereco do periferico dos displays
    MOV  R5, MASCARA      ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa
ciclo:
    MOV  R1, 7
    MOVB [R4], R1      ; escreve linha e coluna a zero nos displays

espera_tecla:          ; Encontra coluna/linha
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R6, CONTADOR_L; linha a ser verificada em decimal
espera_linha:
    CMP  R1, 0         ; já viu todas as linhas?
    JZ   espera_tecla  ; se linha é 0; repete
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    SHR  R1, 1         ; faz shift right do "ID" da linha para a linha seguinte
    SUB  R6, 1         ; atualiza o contador das linhas
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    CMP  R0, 0         ; ha tecla premida?
    JZ   espera_linha  ; se nenhuma tecla premida, repete

                       ; Converter 1248 -> 0123
    MOV  R10, R6       ; guarda a linha (convertida) no R10
    MOV  R11, R0       ; guarda a coluna no R11
    MOV  R8,  R0       ; guarda a coluna no R11
    MOV  R7, CONTADOR_C; inicia o contador de SHR da coluna
conta_colunas:
    ADD  R7, 1         ; conta um shift
    SHR  R11, 1        ; faz shift
    CMP  R11, 0        ; chegou a 0?
    JNZ  conta_colunas ; repete o shift até o "ID" da coluna passar a ser 0
    SUB  R7, 1         ; corrige o acrescimo inicial do contador
    MOV  R11, R7       ; guarda a coluna (convertida) em R11

                       ; Converte coluna/linha --> tecla
    SHL  R10, 2        ; multiplica linha por 4
    ADD  R10, R11      ; adiciona a coluna
    MOV  R9, R10       ; guarda o valor da tecla no R9
    MOVB [R4], R9      ; escreve a tecla no display


;    SHL  R1, 4         ; coloca linha no nibble high
;    OR   R1, R0        ; junta coluna (nibble low)
;    MOVB [R4], R1      ; escreve linha e coluna nos displays
    


ha_tecla:              ; neste ciclo espera-se ate NENHUMA tecla estar premida
    SHR  R1, 1         ; corrigir o shift da linha
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    CMP  R0, R8        ; ha tecla premida?
    JZ  ha_tecla      ; se ainda houver uma tecla premida, espera ate nao haver
    JMP  espera_tecla  ; repete ciclo


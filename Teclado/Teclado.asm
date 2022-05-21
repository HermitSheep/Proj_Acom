; *********************************************************************
; * IST-1103557 Mateus Correia
; * Modulo:    Teclado.asm
; * Descricao: Feito com base no modulo lab3.asm.
; *            Permite ler teclas precionadas no teclado.
; *            Incrementa o display quando se clica em A e decrementa quando se clica em B.
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENCAO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto nao altera o valor de 16 bits e permite distinguir numeros de identificadores
DISPLAYS     EQU 0A000H  ; endereco dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN      EQU 0C000H  ; endereco das linhas do teclado (periferico POUT-2)
TEC_COL      EQU 0E000H  ; endereco das colunas do teclado (periferico PIN)
LINHA        EQU 16      ; linha a testar (5a linha, 10000b), sendo que a sua primeira operação é SHR
MASCARA      EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
LETRA_A      EQU 0       ; letra A
LETRA_B      EQU 1       ; letra B
CONTADOR_L   EQU 4       ; conta a linha que está a ser verificada, começa na 4 e vai para baixo
CONTADOR_C   EQU 0       ; conta os SHR precisos para a coluna passar a ser 0 (para converter para o valor certo)

; **********************************************************************
; * Atribuições
; **********************************************************************
; R0  --> output do teclado                    (colunas)
; R1  --> input do teclado                     (linhas)
; R2  --> endereço input teclado
; R3  --> endereço output teclado
; R4  --> endereço display
; R5  --> mascara                              (isolar os 4 bits da direita)
; R6  --> contador do input/output do teclado  (como os dois são inicialisados não há problema)
; R7  --> contador do display
; R8  --> posição em coluna da tecla           (em formato 1248)
; R9  --> valor da tecla primida
; R10 --> posição em linha da tecla            (em formato 0123)
; R11 --> posição em coluna da tecla           (em formato 0123)

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
    MOV  R9, 7            ; inicialização do valor da tecla

; corpo principal do programa
    MOV  R7, 0         ; inicia o contador a zero
    MOVB [R4], R7      ; inicia o display com o valor do contador

espera_tecla:          ; Encontra coluna/linha
    MOV  R1, LINHA     ; testar a linha 4 
    MOV  R6, CONTADOR_L; linha a ser verificada em decimal
espera_linha:
    SHR  R1, 1         ; faz shift right do "ID" da linha para a linha seguinte
    CMP  R1, 0         ; já viu todas as linhas?
    JZ   espera_tecla  ; se linha é 0; repete
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    SUB  R6, 1         ; atualiza o contador das linhas
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    CMP  R0, 0         ; ha tecla premida?
    JZ   espera_linha  ; se nenhuma tecla premida, repete

                       ; Converter 1248 -> 0123
    MOV  R10, R6       ; guarda a linha (convertida) no R10
    MOV  R11, R0       ; guarda a coluna no R11
    MOV  R8,  R0       ; guarda a coluna no R8
    MOV  R6, CONTADOR_C; inicia o contador de SHR da coluna
conta_colunas:
    ADD  R6, 1         ; conta um shift
    SHR  R11, 1        ; faz shift
    CMP  R11, 0        ; chegou a 0?
    JNZ  conta_colunas ; repete o shift até o "ID" da coluna passar a ser 0
    SUB  R6, 1         ; corrige o acrescimo inicial do contador
    MOV  R11, R6       ; guarda a coluna (convertida) em R11

                       ; Converte coluna/linha --> tecla
    SHL  R10, 2        ; multiplica linha por 4
    ADD  R10, R11      ; adiciona a coluna
    MOV  R9, R10       ; guarda o valor da tecla no R9

                       ; Incrementa o display se for A e decrementa se for B
    CMP  R9, LETRA_A   ; A foi primida?
    JZ  incrementa     ; vai para o incrementa
    CMP  R9, LETRA_B   ; B foi primida?
    JZ  decrementa     ; vai para o decrementa
                       ; se não for nenhuma das duas volta à procura da tecla

ha_tecla:              ; Espera até que a mesma tecla não esteja a ser primida
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    MOV  R6, 0
    CMP  R0, R8        ; a mesma tecla está premida?
    JZ  ha_tecla       ; se sim salta vola a verificar
    JMP  espera_tecla  ; se sim repete o ciclo


incrementa:
    ADD R7, 1          ; incrementa o contador
    MOVB [R4], R7      ; atualiza o display
    JMP ha_tecla       ; continua o ciclo

decrementa:
    SUB R7, 1          ; decrementa o contador
    MOVB [R4], R7      ; atualiza o display
    JMP ha_tecla       ; continua o ciclo

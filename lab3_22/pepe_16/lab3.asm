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
DISPLAYS   EQU 0A000H  ; endereco dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN    EQU 0C000H  ; endereco das linhas do teclado (periferico POUT-2)
TEC_COL    EQU 0E000H  ; endereco das colunas do teclado (periferico PIN)
LINHA      EQU 8       ; linha a testar (4a linha, 1000b) em variavel para fazer os shifts
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * Variaveis
; **********************************************************************
;LINHA WORD 8  ;  linha a testar (começa pela quarta, mas deve andar por shifts até à 1 e voltar)
              ;  (NÂO TER DEFINIDA AO MESMO TEMPO QUE A CONSTANTE)


; **********************************************************************
; * Codigo
; **********************************************************************
PLACE      0
inicio:		
; inicializacoes
    MOV  R2, TEC_LIN   ; endereco do periferico das linhas
    MOV  R3, TEC_COL   ; endereco do periferico das colunas
    MOV  R4, DISPLAYS  ; endereco do periferico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa
ciclo:
    MOV  R1, 7
    MOVB [R4], R1      ; escreve linha e coluna a zero nos displays

espera_tecla:          ; neste ciclo espera-se ate uma tecla ser premida
    MOV  R1, LINHA     ; testar a linha 4 
espera_linha:
    CMP  R1, 0         ; já viu todas as linhas?
    JZ   espera_tecla  ; se linha é 0; repete
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    SHR  R1, 1         ; faz shift left do ID da linha para a linha seguinte
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    CMP  R0, 0         ; ha tecla premida?
    JZ   espera_linha  ; se nenhuma tecla premida, repete
                       ; vai mostrar a linha e a coluna da tecla
    SHL  R1, 4         ; coloca linha no nibble high
    MOV R10, R1        ; guarda a linha no R10
    MOV R11, R0        ; guarda a coluna no R11
    OR   R1, R0        ; junta coluna (nibble low)
    MOVB [R4], R1      ; escreve linha e coluna nos displays
    
ha_tecla:              ; neste ciclo espera-se ate NENHUMA tecla estar premida
    MOV  R1, LINHA     ; testar a linha 4  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]      ; ler do periferico de entrada (colunas)
    AND  R0, R5        ; elimina bits para alem dos bits 0-3
    CMP  R0, 0         ; ha tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera ate nao haver
    JMP  ciclo         ; repete ciclo


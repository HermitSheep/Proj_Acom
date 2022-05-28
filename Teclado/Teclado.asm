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
; Gerais
DISPLAYS  		EQU 0A000H	; endereco dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN   		EQU 0C000H	; endereco das linhas do teclado (periferico POUT-2)
TEC_COL   		EQU 0E000H	; endereco das colunas do teclado (periferico PIN)
MASCARA   		EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63		; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	400H	; atraso para limitar a velocidade de movimento

; Le tecla
LINHA_LEITURA	EQU 16		; linha a testar (5a linha, 10000b), sendo que a sua primeira operação é SHR
CONTADOR_L  	EQU 4		; conta a linha que está a ser verificada, começa na 4 e vai para baixo
CONTADOR_C   	EQU 0		; conta os SHR precisos para a coluna passar a ser 0 (para converter para o valor certo)

; Incrementa / decrementa
LETRA_A      	EQU 0FH		; incrementa
LETRA_B      	EQU 0EH		; decrementa

; Rovers e Asteroides
LARGURA			EQU	5		; largura do boneco
COR_PIXEL		EQU	0FF00H	; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)


; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
DEF_BONECO:				; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		; # # #   as cores podem ser diferentes
     

; **********************************************************************
; * Atribuições
; **********************************************************************
; R2  --> endereço input teclado
; R3  --> endereço output teclado
; R4  --> endereço display
; R5  --> mascara                              (isolar os 4 bits da direita)
; R7  --> contador do display
; R9  --> valor da tecla primida


; **********************************************************************
; * Inicializações
; **********************************************************************
    MOV  R2, TEC_LIN      ; endereco do periferico das linhas
    MOV  R3, TEC_COL      ; endereco do periferico das colunas
    MOV  R4, DISPLAYS     ; endereco do periferico dos displays
    MOV  R5, MASCARA      ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado


; **********************************************************************
; * Codigo
; **********************************************************************
PLACE      0

	MOV  SP, SP_inicial					; inicializa SP para a palavra a seguirà última da pilha
    MOV  R7, 0          ; inicia o contador a zero
    MOVB [R4], R7       ; inicia o display com o valor do contador

inicio:
	CALL le_tecla		; lê uma tecla para o R9
	CALL ha_tecla		; espera até a tecla não estar precionada
						; (TEM DE CORRER IMEDIATAMENTE ASSEGUIR A LE_TECLA)
	JMP inicio			; repete infinitamente



; **********************************************************************
; LE_TECLA - Lê uma tecla do teclado.
;				Incrementa ou decrementa o display se a ultima tecla
;				precionada for A ou B.
; Argumentos:   R0  --> output do teclado                    (colunas)
; 				R1  --> input do teclado                     (linhas)
; 				R6  --> contador do input/output do teclado  (como os dois são inicialisados não há problema)
;					--> guarda as letras A / B
; 				R8  --> posição em coluna da tecla           (em formato 1248)
;				R9  --> valor da tecla primida
; 				R10 --> posição em linha da tecla            (em formato 0123)
; 				R11 --> posição em coluna da tecla           (em formato 0123)
;
; **********************************************************************
le_tecla:
	PUSH	R0			; Guardar os registos que vão ser usados por segurança
	PUSH	R1
	PUSH	R6
	PUSH	R8			; Não se faz push do R9 porque é o output
	PUSH	R10
	PUSH	R11

; Lê uma tecla do teclado
espera_tecla:           	; Encontra coluna/linha
    MOV  R1, LINHA_LEITURA	; testar a linha 4 
    MOV  R6, CONTADOR_L 	; linha a ser verificada em decimal
espera_linha:
    SHR  R1, 1          	; faz shift right do "ID" da linha para a linha seguinte
    CMP  R1, 0          	; já viu todas as linhas?
    JZ   espera_tecla   	; se linha é 0; repete
    MOVB [R2], R1       	; escrever no periferico de saida (linhas)
    MOVB R0, [R3]       	; ler do periferico de entrada (colunas)
    SUB  R6, 1          	; atualiza o contador das linhas
    AND  R0, R5         	; elimina bits para alem dos bits 0-3
    CMP  R0, 0          	; ha tecla premida?
    JZ   espera_linha   	; se nenhuma tecla premida, repete

                        	; Converter 1248 -> 0123
    MOV  R10, R6        	; guarda a linha (convertida) no R10
    MOV  R11, R0        	; guarda a coluna no R11
    MOV  R8,  R0        	; guarda a coluna no R8
    MOV  R6, CONTADOR_C 	; inicia o contador de SHR da coluna
conta_colunas:
    ADD  R6,  1          	; conta um shift
    SHR  R11, 1         	; faz shift
    CMP  R11, 0         	; chegou a 0?
    JNZ  conta_colunas  	; repete o shift até o "ID" da coluna passar a ser 0
    SUB  R6,  1          	; corrige o acrescimo inicial do contador
    MOV  R11, R6        	; guarda a coluna (convertida) em R11

                        	; Converte coluna/linha --> tecla
    SHL  R10, 2         	; multiplica linha por 4
    ADD  R10, R11       	; adiciona a coluna
    MOV  R9, R10        	; guarda o valor da tecla no R9

; Incrementa o display se for A e decrementa se for B
	MOV R6, LETRA_A		; guarda a tecla A (para o CMP funcionar)
    CMP R9, R6			; A foi primida?
    JZ  incrementa		; vai para o incrementa
    MOV R6, LETRA_B		; guarda a tecla B (para o CMP funcionar)
    CMP R9, R6 			; B foi primida?
    JZ  decrementa		; vai para o decrementa
						; se não for nenhuma das duas volta à procura da tecla
incrementa:
    ADD R7, 1           ; incrementa o contador
    MOVB [R4], R7       ; atualiza o display

decrementa:
    SUB R7, 1           ; decrementa o contador
    MOVB [R4], R7       ; atualiza o display


	POP		R0			; Recuperar os registos guardados
	POP		R1
	POP		R6
	POP		R8
	POP		R10
	POP		R11
	RET	;return


; **********************************************************************
; HA_TECLA - Lê se a mesma tecla está a ser precionada
;				TEM DE TER OS MESMOS REGISTOS QUE LE_TECLA (R0, R1 e R8)
; Argumentos:   R0  --> output do teclado                    (colunas)
; 				R1  --> input do teclado                     (linhas)
; 				R8  --> posição em coluna da tecla           (em formato 1248)
;
; **********************************************************************
ha_tecla:
	PUSH	R0			; Guardar os registos que vão ser usados por segurança
	PUSH	R1
	PUSH	R8

    MOVB [R2], R1       ; escrever no periferico de saida (linhas)
    MOVB R0, [R3]       ; ler do periferico de entrada (colunas)
    AND  R0, R5         ; elimina bits para alem dos bits 0-3
    MOV  R6, 0
    CMP  R0, R8         ; a mesma tecla está premida?
    JZ  ha_tecla        ; se sim salta vola a verificar
    JMP  espera_tecla   ; se sim repete o ciclo

	POP		R0
	POP		R1
	POP		R8
	RET

; *********************************************************************************
; * IST-UL
; * Modulo:    lab6-barra-interrupcao.asm
; * Descrição: Este programa anima uma barra (8 pixels) que desce verticalmente no ecrã.
; *			A temporização do movimento é feita por interrupção com um relógio de tempo real. 
; *
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA		EQU 600AH		; endereço do comando para definir a linha
DEFINE_COLUNA		EQU 600CH		; endereço do comando para definir a coluna
ESCREVE_8_PIXELS	EQU 601CH		; endereço do comando para escrever 8 pixels
APAGA_ECRÃ	 	EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
APAGA_AVISO		EQU 6040H		; endereço do comando para apagar o aviso de nenhum cenário selecionado

N_LINHAS			EQU  32		; número de linhas do écrã
BARRA			EQU  0FFH		; valor do byte usado para representar a barra

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
                              
; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0

linha_barra:
	WORD 0				; linha em que a barra está
                              
; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0				; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha
                            
	MOV  BTE, tab			; inicializa BTE (registo de Base da Tabela de Exceções)

	MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
     
	EI0					; permite interrupções 0
	EI					; permite interrupções (geral)

fim:
	JMP fim				; fica à espera

; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz a barra descer uma linha. A animação da barra é causada pela
;			invocação periódica desta rotina
; **********************************************************************
rot_int_0:
	CALL anima_barra		; faz a barra descer de uma linha. Se chegar ao fundo, passa ao topo
	RFE					; Return From Exception (diferente do RET)

; **********************************************************************
; ANIMA_BARRA - Desenha e faz descer uma barra de 8 pixels no ecrã.
;			 Se chegar ao fundo, passa ao topo.
;			 A linha em que o byte é escrito é guardada na variável linha_barra
; Argumentos: Nenhum
; **********************************************************************
anima_barra:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	MOV  R3, 0			; coluna a partir da qual a barra é desenhada
	MOV  R2, [linha_barra]	; linha em que a barra está
	MOV  R1, 0			; para apagar a barra
	CALL escreve_byte		; apaga a barra do ecrã
	ADD  R2, 1			; passa à linha abaixo
	MOV  R4, N_LINHAS
	CMP  R2, R4			; já estava na linha do fundo?
	JLT  escreve
	MOV  R2, 0			; volta ao topo do ecrã
escreve:
	MOV  [linha_barra], R2	; atualiza na variável a linha em que a barra está
	MOV  R1, BARRA			; valor da barra
	CALL escreve_byte		; escreve a barra na nova linha
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET

; **********************************************************************
; ESCREVE_BYTE - Escreve um byte no ecrã, com a cor da caneta
; Argumentos:	R1 - Valor do byte a escrever
;			R2 - Linha onde escrever o byte (entre 0 e N_LINHAS - 1)
;			R3 - Coluna a partir da qual a barra deve ser desenhada 
; **********************************************************************
escreve_byte:
	MOV  [DEFINE_LINHA], R2		; seleciona a linha
	MOV  [DEFINE_COLUNA], R3		; seleciona a coluna
	MOV  [ESCREVE_8_PIXELS], R1	; escreve os 8 pixels correspondentes ao byte
	RET


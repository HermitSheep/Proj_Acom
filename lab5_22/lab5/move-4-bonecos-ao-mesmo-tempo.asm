; *********************************************************************************
; * IST-UL
; * Modulo:    lab6-move-quatro-bonecos.asm
; * Descrição: Este programa ilustra o movimento de quatro bonecos no ecrã, com um 
; *			animado por uma interrupção diferente, para diferentes velocidades de movimentação.
; *
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

LINHA_BONECO_0		EQU  4		; linha do boneco 0
LINHA_BONECO_1		EQU  12		; linha do boneco 1
LINHA_BONECO_2		EQU  20		; linha do boneco 2
LINHA_BONECO_3		EQU  28		; linha do boneco 3
COLUNA			EQU  30		; coluna do boneco (a meio do ecrã)

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar

LARGURA		EQU	5			; largura do boneco
COR_PIXEL		EQU	0FF00H		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

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
	WORD rot_int_1			; rotina de atendimento da interrupção 1
	WORD rot_int_2			; rotina de atendimento da interrupção 2
	WORD rot_int_3			; rotina de atendimento da interrupção 3

DEF_BONECO:				; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL		; # # #   as cores podem ser diferentes
     
linha_boneco:				; linha em que cada boneco está (inicializada com a linha inicial)
	WORD LINHA_BONECO_0
	WORD LINHA_BONECO_1
	WORD LINHA_BONECO_2
	WORD LINHA_BONECO_3
                              
coluna_boneco:				; coluna em que cada boneco está (inicializada com a coluna inicial)
	WORD COLUNA
	WORD COLUNA
	WORD COLUNA
	WORD COLUNA
                              
sentido_movimento:			; sentido movimento de cada boneco (+1 para a direita, -1 para a esquerda)
	WORD 1
	WORD -1
	WORD 1
	WORD -1
                              

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha
                            
	MOV  BTE, tab			; inicializa BTE (registo de Base da Tabela de Exceções)

     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar
     
	EI0					; permite interrupções 0
	EI1					; permite interrupções 1
	EI2					; permite interrupções 2
	EI3					; permite interrupções 3
	EI					; permite interrupções (geral)

fim:
	JMP fim				; fica à espera


; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz o boneco 0 mover-se
; **********************************************************************
rot_int_0:
	PUSH	R3
	MOV	R3, 0
	CALL	anima_boneco		; movimenta o boneco 0
	POP	R3
	RFE

; **********************************************************************
; ROT_INT_1 - 	Rotina de atendimento da interrupção 1
;			Faz o boneco 1 mover-se
; **********************************************************************
rot_int_1:
	PUSH	R3
	MOV	R3, 1
	CALL	anima_boneco		; movimenta o boneco 1
	POP	R3
	RFE

; **********************************************************************
; ROT_INT_2 - 	Rotina de atendimento da interrupção 2
;			Faz o boneco 2 mover-se
; **********************************************************************
rot_int_2:
	PUSH	R3
	MOV	R3, 2
	CALL	anima_boneco		; movimenta o boneco 2
	POP	R3
	RFE

; **********************************************************************
; ROT_INT_3 - 	Rotina de atendimento da interrupção 3
;			Faz o boneco 3 mover-se
; **********************************************************************
rot_int_3:
	PUSH	R3
	MOV	R3, 3
	CALL	anima_boneco		; movimenta o boneco 3
	POP	R3
	RFE

; **********************************************************************
; ANIMA_BONECO - Executa as acções necessárias para implementar o movimento de um boneco.
;
; Argumentos: R3 - Nº do boneco (0 a 3)
; **********************************************************************
anima_boneco:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7
	
	MOV  R5, linha_boneco
	SHL  R3, 1			; multiplica o nº do boneco por 2 (porque a linha_boneco é uma tabela de words)
	MOV  R1, [R5+R3]		; linha em que o boneco está
	MOV  R5, coluna_boneco
	MOV  R2, [R5+R3]		; coluna em que o boneco está
	MOV  R5, sentido_movimento
	MOV  R7, [R5+R3]		; sentido de movimento do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco

	CALL	move_boneco		; move o boneco

	MOV  R5, coluna_boneco
	MOV  [R5+R3], R2		; atualiza (nas variáveis) a coluna em que o boneco está
	MOV  R5, sentido_movimento
	MOV  [R5+R3], R7		; atualiza (nas variáveis) o sentido de movimento do boneco

	POP  R7
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET

; **********************************************************************
; MOVE_BONECO - Desenha um boneco na linha e coluna indicadas
;			 com a forma e cor definidas na tabela indicada.
; Argumentos:	R1 - linha
;			R2 - coluna
;			R4 - tabela que define o boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna:	R2 - novo valor da coluna, após o movimento
;			R7 - novo sentido de movimento (pode ser o mesmo)
; **********************************************************************
move_boneco:
	PUSH	R3
	PUSH	R4
	PUSH	R5

	CALL	apaga_boneco		; apaga o boneco na sua posição corrente
	
	MOV	R6, [R4]			; obtém a largura do boneco
	CALL	testa_limites		; vê se chegou aos limites do ecrã e nesse caso inverte o sentido

coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)

	CALL	desenha_boneco		; desenha o boneco a partir da tabela

	POP	R5
	POP	R4
	POP	R3
	RET


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET

; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R2, 1               ; próxima coluna
     SUB  R5, 1			; menos uma coluna para tratar
     JNZ  apaga_pixels      ; continua até percorrer toda a largura do objeto
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   inverte o sentido de movimento
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - novo sentido de movimento (pode ser o mesmo)	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JLE	inverte_para_direita
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JGT	inverte_para_esquerda
	JMP	sai_testa_limites	; entre limites. Mantém o valor do R7

inverte_para_direita:
	MOV	R7, 1			; passa a deslocar-se para a direita
	JMP	sai_testa_limites
inverte_para_esquerda:
	MOV	R7, -1			; passa a deslocar-se para a esquerda
sai_testa_limites:	
	POP	R6
	POP	R5
	RET


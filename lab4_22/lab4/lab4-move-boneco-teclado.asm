; *********************************************************************************
; * IST-UL
; * Modulo:    lab4-move-boneco-teclado.asm
; * Descrição: Este programa ilustra o movimento de um boneco do ecrã, sob controlo
; *			do teclado.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
TEC_LIN					EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO			EQU 8		; linha a testar (4ª linha, 1000b)
MASCARA					EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 1		; tecla na primeira coluna do teclado (tecla C)
TECLA_DIREITA			EQU 2		; tecla na segunda coluna do teclado (tecla D)


DEFINE_LINHA    		EQU 600AH   ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H   ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA		 		EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo

MIN_COLUNA				EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA				EQU  63     ; número da coluna mais à direita que o objeto pode ocupar
ATRASO					EQU	400H	; atraso para limitar a velocidade de movimento do boneco


; Paleta de cores
ENC		EQU	0FF00H	; cor pixel: vermelho (encarnado)
AMA		EQU 0FFF0H	; cor pixel: amarelo
VER1	EQU 0F0F0H	; cor pixel: verde claro
VER2	EQU 0F8C0H	; cor pixel: verde escuro
AZU1	EQU 0F0FFH	; cor pixel: azul claro
AZU2	EQU 0F00FH	; cor pixel: azul escuro
ROX		EQU 0FF0FH	; cor pixel: roxo
CIN		EQU 0FAAAH	; cor pixel: cinzento claro
WHI		EQU 0FFFFH	; cor pixel: branco (white)
TRA		EQU 00000H	; cor pixel: transparente

; Rover
LINHA_R        	EQU 27  ; linha de começo do rover (a meio do ecrã))
COLUNA_R		EQU 30  ; coluna de começo do rover (a meio do ecrã)
ALTURA_R		EQU 5	; altura do rover
LARGURA_R		EQU 5	; largura do rover

; Asteroide mao
LINHA_AM		EQU 15  ; linha de começo do cover (a meio do ecrã))
COLUNA_AM		EQU 30  ; coluna de começo do rover (a meio do ecrã)
ALTURA_AM		EQU 5	; altura do rover
LARGURA_AM		EQU 5	; largura do rover

; Asteroide bom
LINHA_AB		EQU 15  ; linha de começo do cover (a meio do ecrã))
COLUNA_AB		EQU 30  ; coluna de começo do rover (a meio do ecrã)
ALTURA_AB		EQU 5	; altura do rover
LARGURA_AB		EQU 5	; largura do rover


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
							
     
DEF_ROVER:												; lista que define o rover (tamanho e pixeis)
	WORD		LINHA_R, COLUNA_R, ALTURA_R, LARGURA_R	; para ler a informação seguinte é priciso incrementar
														; ou decrementar o endereço de 2 em 2
	WORD		TRA,  TRA,  AZU2, TRA,  TRA				; # # #   as cores podem ser diferentes
	WORD		TRA,  AZU2, AMA,  AZU2, TRA
	WORD		AZU2, AMA,  AMA,  AMA,  AZU2
	WORD		TRA,  TRA,  AMA,  TRA,  TRA
	WORD		TRA,  AMA,  AZU1, AMA,  TRA

DEF_ASTEROIDE_BOM:
	WORD		LINHA_AB, COLUNA_AB, ALTURA_AB, LARGURA_AB

	WORD		TRA , VER1, VER1, VER1, TRA
	WORD		VER1, VER1, VER1, VER1, VER1
	WORD		VER1, VER1, VER1, VER1, VER1
	WORD		VER1, VER1, VER1, VER1, VER1
	WORD		TRA , VER1, VER1, VER1, TRA

DEF_ASTEROIDE_MAO:
	WORD		LINHA_AM, COLUNA_AM, ALTURA_AM, LARGURA_AM

	WORD		ENC, WHI, ENC, ENC, ENC  ; (Suastica, se quizerem mudar já sabem como)
	WORD		ENC, WHI, ENC, WHI, WHI  ; (a ideia é destruir os asteroides nazis)
	WORD		ENC, ENC, ENC, ENC, ENC  ; (ou os hindus e budistas, porque os nazis foram os primeiros
	WORD		WHI, WHI, ENC, WHI, ENC  ; apropriadores culturais)
	WORD		ENC, ENC, ENC, WHI, ENC  ; (peço desculpa...)

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                       		; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial					; inicializa SP para a palavra a seguir
										; à última da pilha
                            
    MOV [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV [APAGA_ECRA], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0							; cenário de fundo número 0
    MOV	[SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1							; valor a somar à coluna do boneco, para o movimentar
     
posição_boneco:
	MOV	R4, DEF_ROVER					; endereço da tabela que define o boneco
    MOV R1, [R4]						; linha do boneco
	ADD R4, 2							; passa para a palavra seguinte (coluna)
    MOV R2, [R4]						; coluna do boneco
	ADD R4, 2							; passa para a palavra seguinte (altura)

mostra_boneco:
	CALL	desenha_boneco				; desenha o boneco a partir da tabela

espera_tecla:							; neste ciclo espera-se até uma tecla ser premida
	MOV R6, LINHA_TECLADO				; linha a testar no teclado
	CALL	teclado						; leitura às teclas
	CMP	R0, 0
	JZ	espera_tecla					; espera, enquanto não houver tecla
	CMP	R0, TECLA_ESQUERDA
	JNZ	testa_direita
	MOV	R7, -1							; vai deslocar para a esquerda
	JMP	ve_limites
testa_direita:
	CMP	R0, TECLA_DIREITA
	JNZ	espera_tecla					; tecla que não interessa
	MOV	R7, +1							; vai deslocar para a direita
	
ve_limites:
	MOV	R6, [R4]						; obtém a largura do boneco
	CALL	testa_limites				; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla					; se não é para movimentar o objeto, vai ler o teclado de novo

move_boneco:
	CALL	apaga_boneco				; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD	R2, R7							; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP	mostra_boneco					; vai desenhar o boneco de novo


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o rover
;				R5 - contador de colunas
;				R6 - contador de linhas
;				R7 - guarda n colunas
;
; **********************************************************************
desenha_boneco:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH    R6
	PUSH	R7
	
	MOV	R6, [R4]			; obtém a altura do boneco (n linhas)
	ADD	R4, 2				; endereço da largura
	MOV R5, [R4]			; obtém a largura do boneco (n colunas)
	MOV	R7, R5				; guardar o n colunas para poder dar reset em cada linha
	ADD R4, 2				; obtém a cor do primeiro pixel
desenha_colunas:       		; desenha os pixels desta coluna do rover
desenha_linhas:				; desenha os pixels desta linha do rover
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
	ADD	R4, 2				; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD R2, 1				; próxima coluna
    SUB R5, 1				; menos uma coluna para tratar
    JNZ	desenha_linhas		; continua até percorrer toda a largura do objetoD R5, 5
	ADD R1, 1				; próxima linha
	MOV R5, R7				; puxar o contador para o inicio da linha
	SUB R2, R7				; coltar para o inicio da linha
	SUB R6, 1				; menos uma linha para tratar
	JNZ	desenha_colunas

	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
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
	PUSH 	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH 	R6
	PUSH	R7

	MOV	R6, [R4]			; obtém a altura do boneco (n linhas)
	ADD	R4, 2				; endereço da largura
	MOV R5, [R4]			; obtém a largura do boneco (n colunas)
	MOV	R7, R5				; guardar o n colunas para poder dar reset em cada linha
apaga_colunas:       		; apaga os pixels desta coluna do rover
apaga_linhas:				; apaga os pixels desta linha do rover
	MOV	R3, 0				; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
    ADD R2, 1				; próxima coluna
    SUB R5, 1				; menos uma coluna para tratar
    JNZ	apaga_linhas		; continua até percorrer toda a largura do objetoD R5, 5
	ADD R1, 1				; próxima linha
	MOV R5, R7				; puxar o contador para o inicio da linha
	SUB R2, R7				; coltar para o inicio da linha
	SUB R6, 1				; menos uma linha para tratar
	JNZ	apaga_colunas

	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
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
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2				; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0				; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
	RET

; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	MOV R2, TEC_LIN		; endereço do periférico das linhas
	MOV R3, TEC_COL  	; endereço do periférico das colunas
	MOV R5, MASCARA  	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6     	; escrever no periférico de saída (linhas)
	MOVB R0, [R3]     	; ler do periférico de entrada (colunas)
	AND R0, R5       	; elimina bits para além dos bits 0-3
	POP	R5
	POP	R3
	POP	R2
	RET



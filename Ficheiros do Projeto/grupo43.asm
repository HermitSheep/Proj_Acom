; *********************************************************************
; * Mateus Correia 1103557
; * José Gallego 1102726
; * Henrique Santos 103629
; *
; * Titulo: Cuva de Asteroides.asm
; *********************************************************************
;
; **********************************************************************
; * Notas Para o Programador
; **********************************************************************
;	Utilizar tabs em vez de espaços sempre que possivel.
;	Manter os comentários e variaveis de cada bloco nivelados.
;	Não guardar registos globais.
;
; **********************************************************************
; * Constantes
; **********************************************************************
; Gerais
DISPLAYS  		EQU 0A000H	; endereco dos displays de 7 segmentos (periferico POUT-1)
TEC_LIN   		EQU 0C000H	; endereco das linhas do teclado (periferico POUT-2)
TEC_COL   		EQU 0E000H	; endereco das colunas do teclado (periferico PIN)
MASCARA   		EQU 0FH		; para esconder os primeiros 4 bits
MIN_COLUNA		EQU 0		; primeira coluna
MAX_COLUNA		EQU 63		; ultima coluna
ATRASO			EQU	0900H	; atraso para limitar a velocidade do rover

; Teclado
LINHA_LEITURA	EQU 16		; linha a testar (5a linha, para se chegar à linha 0 voltar logo para a 1)
CONTADOR_L  	EQU 4		; conta a linha em que está, começa na 4 e vai para baixo
CONTADOR_C   	EQU 0		; ajuda a converter as colunas de 1-2-4-8 para 0-1-2-3

; Funcões teclas  (PARA ADICIONAR NOVAS FUNÇOÕES, INSTRUÇÕES ESTÃO NA FUNÇÃO TECLADO)
DIREITA      	EQU 0FH		; tecla para mexer o rover para a direita
ESQUERDA      	EQU 0EH		; tecla para mexer o rover para a esquerda
INCREMENTA_D    EQU 1H	    ; incrementa display
DECREMENTA_D    EQU 0H		; decrementa display
DISPARA			EQU 0AH		; dispara um tiro

; Comandos media-center
SELECIONA_ECRA			EQU	6004H	; seleciona ecrã em que escrever
DEFINE_LINHA    		EQU 600AH	; define a linha em que escrever
DEFINE_COLUNA   		EQU 600CH	; define a coluna em que escrever
DEFINE_PIXEL    		EQU 6012H	; define a cor do pixel a escrever
APAGA_AVISO     		EQU 6040H	; apaga o aviso de nenhum cenário selecionado
APAGA_ECRA		 		EQU 6000H	; apaga o ecrã selecionado
APAGA_TODOS_ECRANS		EQU 6002H	; apaga todos os ecrãs
SELECIONA_CENARIO_FUNDO EQU 6042H	; seleciona uma imagem de fundo
INICIA_MUSICA			EQU	605AH	; começa uma musica, mas não em loop
TOCA_MUSICA_LOOP		EQU	605CH	; toca musica em loop até ser parado
PAUSA_MUSICA			EQU 605EH	; pausa o som selecionado
CONTINUA_MUSICA			EQU 6060H	; continua musica selecionada de onde tinha sido pausada
TERMINA_MUSICA			EQU 6066h	; termina a musica selecionada

; Paleta de cores
ENC		EQU	0FF00H	; vermelho (encarnado)
AMA		EQU 0FFF0H	; amarelo
VER1	EQU 0F0F0H	; verde claro
VER2	EQU 0F8C0H	; verde escuro
AZU1	EQU 0F0FFH	; azul claro
AZU2	EQU 0F00FH	; azul escuro
ROX		EQU 0FF0FH	; roxo
CIN1	EQU 07777H	; cinzento longe
CIN2	EQU 0FAAAH	; cinzento normal
WHI		EQU 0FFFFH	; branco (white)
TRA		EQU 00000H	; transparente

; Rover
LINHA_R        	EQU 27	; linha de começo do rover (a meio do ecrã)
COLUNA_R		EQU 30	; coluna de começo (a meio do ecrã)
ALTURA_R		EQU 5	; altura do rover
LARGURA_R		EQU 5	; largura

; Asteroides
CONT_FAZE	EQU 0	; conta quantos movimentos fez desde que entrou na faze
LINHA_A		EQU 0
COLUNA_A	EQU 30


; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 

SP_inicial:				; primeira posição da stack
tab:
	WORD	int_0		; rotinas de atendimento da interrupção 0 - 3
	WORD	int_1
	WORD	int_2
	WORD	int_3
							
DEF_ROVER:												; lista que define o rover (posição, tamanho e desenho):
	WORD		LINHA_R, COLUNA_R, ALTURA_R, LARGURA_R	; para ler a informação seguinte é priciso incrementar
														; ou decrementar o endereço de 2 em 2.
	WORD		TRA,  TRA,  AZU2, TRA,  TRA				; as cores podem ser diferentes
	WORD		TRA,  AZU2, AMA,  AZU2, TRA
	WORD		AZU2, AMA,  AMA,  AMA,  AZU2
	WORD		TRA,  TRA,  AMA,  TRA,  TRA
	WORD		TRA,  AMA,  AZU1, AMA,  TRA

ASTEROIDE_1:
	WORD		LINHA_A, COLUNA_A, SEQUENCIA_AST_MAU, CONT_FAZE	; posição do asteroide, sequencia desenho, contador

ASTEROIDE_2:
	WORD		LINHA_R, COLUNA_R, SEQUENCIA_AST_MAU, CONT_FAZE	; de movimento desd'a ultima faze

ASTEROIDE_3:
	WORD		LINHA_R, COLUNA_R, SEQUENCIA_AST_MAU, CONT_FAZE

ASTEROIDE_4:
	WORD		LINHA_R, COLUNA_R, SEQUENCIA_AST_MAU, CONT_FAZE


AST_FAZE_1:								; tabela de desenhos dos asteroides
	WORD		1, 1					; altura, comprimento do desenho

	WORD		CIN1					; desenho do boneco

AST_FAZE_2:
	WORD		2, 2

	WORD		CIN2, CIN2
	WORD		CIN2, CIN2

AST_FAZE_3_BOM:
	WORD		3, 3

	WORD		TRA,  VER1, TRA
	WORD		VER2, VER1, VER1
	WORD		TRA,  VER1, TRA

AST_FAZE_3_MAU:
	WORD		3, 3

	WORD		ENC, AZU1, ENC
	WORD		TRA, ENC,  TRA
	WORD		ENC, AMA,  ENC

AST_FAZE_4_BOM:
	WORD		4, 4

	WORD		TRA,  VER2, VER1, TRA
	WORD		VER1, VER1, VER1, VER1
	WORD		VER1, VER1, VER2, VER1
	WORD		TRA,  VER1, VER1, TRA

AST_FAZE_4_MAU:
	WORD		4, 4

	WORD		ENC, AZU1, AZU1, ENC
	WORD		ENC, ENC,  ENC,  ENC
	WORD		TRA, AMA,  AMA,  TRA
	WORD		ENC, TRA,  TRA,  ENC

AST_FAZE_5_BOM:
	WORD		5, 5

	WORD		TRA,  VER1, VER1, VER1, TRA
	WORD		VER1, VER2, VER1, VER1, VER1
	WORD		VER1, VER1, VER1, VER2, VER1
	WORD		VER1, VER1, VER1, VER1, VER1
	WORD		TRA,  VER2, VER1, VER1, TRA

AST_FAZE_5_MAU:
	WORD		5, 5

	WORD		ENC, TRA, TRA,  TRA, ENC
	WORD		TRA, ENC, AZU1, ENC, TRA
	WORD		ENC, ENC, ENC,  ENC, ENC
	WORD		ENC, AMA, ENC,  AMA, ENC
	WORD		ENC, TRA, TRA,  TRA, ENC

MISSIL:
	WORD		34, 64, 1, 1		; linha, coluna, altura, largura

	WORD		ROX

SEQUENCIA_AST_BOM:
	WORD		AST_FAZE_1, AST_FAZE_2, AST_FAZE_3_BOM, AST_FAZE_4_BOM, AST_FAZE_5_BOM

SEQUENCIA_AST_MAU:
	WORD		AST_FAZE_1, AST_FAZE_2, AST_FAZE_3_MAU, AST_FAZE_4_MAU, AST_FAZE_5_MAU

CONTADOR_DISPLAY:
	WORD		0			;Numero que entra no display


; **********************************************************************
; * Codigo
; **********************************************************************
	PLACE	0

; Inicializações

	MOV  SP, SP_inicial	 	; inicializa SP para a palavra a seguir à última da pilha
	MOV  BTE, tab			; inicializa BTE

; Inicio programa
    MOV  R7, 0       		; inicia o contador a zero
    MOV [DISPLAYS], R7     	; inicia o display com o valor do contador

inicio:
    MOV [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado
    MOV [APAGA_TODOS_ECRANS], R1		; apaga todos os pixels já desenhados
	MOV	R1, 0							; escolhe o cenário de fundo (prédefinida no media center)
    MOV	[SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV R1, 1							; escolhe a musica de fundo
	MOV [TOCA_MUSICA_LOOP], R1			; toca musica de fundo

	MOV R4, ASTEROIDE_1
	CALL	carrega_asteroide
	MOV R4, ASTEROIDE_2
	CALL	carrega_asteroide
	MOV R4, ASTEROIDE_3
	CALL	carrega_asteroide
	MOV R4, ASTEROIDE_4
	CALL	carrega_asteroide			; carrega os asteroides

	EI0						; permite interrupções 0 - 3
	EI1
	;EI2					; (isto tem de estar depois de os asteroides serem carregados)
	;EI3
	EI						; permite interrupções (geral)

comeco:
	CALL	user_input					; faz tudo o que tem a haver com input de utilizador
	;CALL	atraso						; previne lag se o computador for UMA FUCKING MERDA
	JMP	comeco							; repete

int_2:
int_3:

; **********************************************************************
; MISSIL - Controla automáticamente os misseis.
;
; **********************************************************************
int_1:
	DI
	PUSH	R1
	PUSH	R3
	PUSH	R4

	MOV R4, MISSIL
	MOV R3, 34
	MOV R4, [R4]
	CMP R3, R4
	JZ fim_int_1			; se não houver missil sai da interrupção

	MOV R1, 2
	MOV [APAGA_ECRA], R1	; apaga o missil
	MOV R4, MISSIL
	CALL	mexe_missil		; mexe o missil

fim_int_1:
	POP	R4
	POP	R3
	POP	R1
	EI
	RFE

; **********************************************************************
; MEXE_MISSIL - Desenha o missil na próxima posição.
;
; Argumentos: R4 - Missil
;
; **********************************************************************
mexe_missil:
	PUSH	R1
	PUSH	R3
	PUSH	R4

	MOV R1, [R4]
	SUB R1, 1
	MOV [R4], R1			; mexe o missil para a linha seguinte
	MOV R3, 15				; linha até onde o missil vai
	CMP R1, R3
	JZ reset_missil			; se o missil estiver na ultima linha dar reset
	CALL	desenha_missil
	JMP fim_mexe_missil

reset_missil:
	MOV R1, 2
	MOV [APAGA_ECRA], R1	; Apaga o missil
	MOV R1, 34
	MOV [R4], R1

fim_mexe_missil:
	POP R4
	POP	R3
	POP R1
	RET

; **********************************************************************
; CARREGA_MISSIL - Desenha o missil no sitio certo.
;
; Argumentos: R4 - Missil
;
; **********************************************************************
carrega_missil:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4

	MOV R3, R4
	MOV R4, DEF_ROVER
	MOV R1, [R4]
	ADD R4, 2
	MOV R2, [R4]
	SUB R1, 1			; 1 pixel acima do rover
	ADD R2, 2			; na ponta do rover
	MOV R4, R3
	MOV [R4], R1
	ADD R4, 2
	MOV [R4], R2		; guarda posição
	SUB R4, 2

	CALL	desenha_missil	; para se quisermos mais misseis diferentes

	POP	R4
	POP	R3
	POP	R2
	POP	R1
	RET

; **********************************************************************
; DESENHA_MISSIL - Desenha o missil no sitio certo.
;
; Argumentos: R4 - Missil
;
; **********************************************************************
desenha_missil:
	PUSH	R1
	PUSH	R2
	PUSH	R4
	PUSH	R10

	MOV R1, [R4]				; --> linha
	ADD R4, 2
	MOV R2, [R4]				; --> coluna
	ADD R4, 2
	MOV R10, 2					; escolhe o 3º ecrã
	MOV [SELECIONA_ECRA], R10
	CALL	desenha_boneco

	POP	R10
	POP	R4
	POP	R2
	POP	R1
	RET

; **********************************************************************
; ASTEROIDES - Controla automáticamente os asteroides.
;
; **********************************************************************
int_0:
	DI
	PUSH	R1
	PUSH	R4

	MOV R1, 1
	MOV [APAGA_ECRA], R1	; Apaga os asteroides
	MOV R4, ASTEROIDE_1
	CALL	mexe_asteroide
	MOV R4, ASTEROIDE_2
	CALL	mexe_asteroide
	MOV R4, ASTEROIDE_3
	CALL	mexe_asteroide
	MOV R4, ASTEROIDE_4
	CALL	mexe_asteroide

	POP	R4
	POP	R1
	EI
	RFE


; **********************************************************************
; CARREGA_ASTEROIDE - Carrega o asteroide numa posição aleatória.
;
; Argumentos: R4 - Asteroide a ser carregado
;
; **********************************************************************
carrega_asteroide:
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH	R10
	PUSH	R11

	MOV R5, LINHA_A
	MOV [R4], R5					; reset linha
roll_the_dice:
	CALL	dice_roll				; escolhe possivel coluna e tipo
	MOV R5, ASTEROIDE_1
	ADD R5, 2
	MOV R6, [R5]
	CMP R6, R10
	JZ roll_the_dice				; se a coluna já estiver ocupada escolhe outra
	MOV R5, ASTEROIDE_2
	ADD R5, 2
	MOV R6, [R5]
	CMP R6, R10
	JZ roll_the_dice
	MOV R5, ASTEROIDE_3				; tem de verificar para todos os asteroides
	ADD R5, 2
	MOV R6, [R5]
	CMP R6, R10
	JZ roll_the_dice
	MOV R5, ASTEROIDE_4
	ADD R5, 2
	MOV R6, [R5]
	CMP R6, R10
	JZ roll_the_dice

	ADD R4, 2
	MOV [R4], R10					; reset coluna
	ADD R4, 2
	CMP R11, 1
	JZ sequencia_bom				; reset tipo/sequensia de desenhos
	MOV R5, SEQUENCIA_AST_MAU
	MOV [R4], R5
	JMP reset_contador

sequencia_bom:
	MOV R5, SEQUENCIA_AST_BOM
	MOV [R4], R5

reset_contador:
	ADD R4, 2
	MOV R6, 0
	MOV [R4], R6						; reset contador

	SUB R4, 6
	CALL	desenha_asteroide			; desenha o asteroide no inicio

	POP	R11
	POP	R10
	POP	R6
	POP	R5
	POP	R4
	RET

; **********************************************************************
; MEXE_ASTEROIDE - Desenha o asteroide especificado na próxima posição.
;					É aconsenhavel apagar o ecrã 1 antes de fazer esta função.
;
; Argumentos: R4 - Asteroide a ser mexido
;
; **********************************************************************
mexe_asteroide:
	PUSH	R4
	PUSH	R3
	PUSH	R2

	MOV R3, [R4]				; --> linhas
	MOV R2, 15
	CMP R3, R2
	JGE desenha_astro			; se já estiver na faze final apenas mexe para baixo
	MOV R2, 33
	CMP R3, R2
	JZ re_carrega_astro			; se estiver já fora do ecrã recarrega o asteroide
	ADD R4, 6
	MOV R3, [R4]				; --> contador de faze
	SUB R4, 6
	CMP R3, 3					; mudar aqui para mudar a altura em que eles mudam de faze
	JNZ desenha_astro			; mexe o asteroide se ainda não tiver de mudar de faze
; próxima faze
	ADD R4, 6
	MOV R3, 0
	MOV [R4], R3				; contador --> 0
	SUB R4, 2
	MOV R3, [R4]
	ADD R3, 2
	MOV [R4], R3				; próximo desenho
	SUB R4, 4					; --> linhas
	JMP desenha_astro

re_carrega_astro:
	CALL	carrega_asteroide
	JMP fim_mexe_asteroides		; carrega o asteroide no inicio e sai da função

desenha_astro:
	MOV R3, [R4]
	ADD R3, 1
	MOV [R4], R3				; próxima linha
	MOV R2, 32
	CMP R3, R2
	JZ re_carrega_astro			; se estiver já fora do ecrã recarrega o asteroide
	ADD R4, 6
	MOV R3, [R4]
	ADD R3, 1
	MOV [R4], R3				; incrementa o contador
	SUB R4, 6
	CALL	desenha_asteroide
	
fim_mexe_asteroides:
	POP R2
	POP	R3
	POP	R4
	RET

; **********************************************************************
; DESENHA_ASTEROIDE - Desenha o asteroide dado na sua posição atual.
;
; Argumentos: R4 - Asteroide a ser desenhado
;
; **********************************************************************
desenha_asteroide:
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R10

posição_asteroide:
    MOV R1, [R4]						; linha do asteroide
	ADD R4, 2
    MOV R2, [R4]						; coluna do asteroide
	ADD R4, 2							; passa para a palavra seguinte (sequencia)
	MOV R4, [R4]
	MOV R4, [R4]						; desenho do asteroide

mostra_asteroide:
	MOV R10, 1							; escolhe o 2º ecrã
	MOV [SELECIONA_ECRA], R10			; seleciona o ecrã em que vai escrever
	CALL	desenha_boneco				; desenha o boneco a partir da tabela

	POP R10
	POP R4
	POP R2
	POP R1
	RET

; **********************************************************************
; DICE_ROLL - Escolhe aleatóriamente o tipo de asteroide e a sua coluna.
;
; Retorna:	R10 --> numero da coluna correspondete
;			R11 --> 1 - é bom, 0 - é mau
;
; **********************************************************************
dice_roll:
	PUSH R1
	PUSH R2
	PUSH R3

    MOV	R2, TEC_LIN   		; endereco do teclado (para perguntar a uma linha se tem tecla)
    MOV	R3, TEC_COL   		; endereco do teclado (para receber resposta)
    MOVB [R2], R1			; pergunta à linha se tem tecla primida
    MOVB R10, [R3]       	; recebe resposta
	SHR R10, 5				; isola os 3 bits da direita
	MOV R11, 0
	CMP R10, 5
	JZ e_bom
	CMP R10, 3
	JZ e_bom
	JMP fim_dice_roll

e_bom:
	MOV R11, 1				; se sair 6 ou 4 o asteroide é bom, se não é mau

fim_dice_roll:
	SHL R10, 3				; converte num multiplo de 8 (coluna correspondente)

	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; USER_INPUT - Trata de tudo o que envolva user input.
;			   Principalmente trata do movimento do rover, mas a função
;				teclado trata por natureza do resto dos inputs.
;
; **********************************************************************
user_input:
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R7
	PUSH R8
	PUSH R10

posição_boneco:
	MOV	R4, DEF_ROVER
    MOV R1, [R4]						; --> linha do boneco
	ADD R4, 2
    MOV R2, [R4]						; --> coluna do boneco
	ADD R4, 2							; passa para a palavra seguinte (altura)

mostra_boneco:
	MOV R10, 0							; escolhe o 1º ecrã
	MOV [SELECIONA_ECRA], R10			; seleciona o ecrã em que vai escrever
	DI
	CALL	desenha_boneco
	EI

espera_input:							; neste ciclo espera-se um input
	MOV	R7, 0							; se nenhuma tecla for clicada, diz para não mexer
	CALL	teclado						; altera R7 para -1 Direita ou 1 Esquerda
	
ve_limites:
	CALL	testa_limites				; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ sai_user_input					; é suposto mexer o rover? se não sai da função
	MOV R8, 0							; seleciona o som para o movimento do rover
	MOV [INICIA_MUSICA], R8				; toca o som uma vez

atrasa_rover:
	CALL	atraso						; Se o rover estiver demasiado rápido alterem nas Constantes

move_boneco:
	MOV [APAGA_ECRA], R10				; apaga o 1º ecrã
	ADD	R2, R7							; atualisa a coluna do rover de acordo com R7
	MOV	R4, DEF_ROVER
	ADD R4, 2							; volta a ir buscar a posição do rover (coluna)
	MOV [R4], R2						; atualiza a posição do rover


sai_user_input:
	POP R10
	POP R8
	POP R7
	POP R4
	POP R2
	POP R1
	RET

; **********************************************************************
; TECLADO - Lê uma tecla do teclado.
;			Incrementa ou decrementa o display se a ultima tecla
;				precionada for A ou B.
; NOTAS - Deixei o ha_tecla e direita esquerda dentro do teclado porque
;			não são usados em mais lado nenhum, e como partilham registos com
;			o espera tecla não vale a pena criar funções novas.
;		  Para atribuir novas funçoes a teclas, é preciso:
;				1-Criar uma constante na area "Funcões teclas" para a tecla pretendida
;				2-Dentro do funções_teclas: guardar a constante em R6 e comparar com R9
;				3-Criar u salto para onde fará a função da tecla
;				4-Se for para movimento continuo, saltar para fim_teclado:, se for
;					para fazer a ação uma só vez, saltar para ha_tecla
;
; Argumento:	R7  --> 1 se for para ir para a direita, -1 se para a esquerda
;
; **********************************************************************
teclado:
	PUSH	R0
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH    R4
	PUSH	R6
	PUSH	R8
	PUSH	R9
	PUSH	R10
	PUSH	R11

; inicializações
    MOV	R2, TEC_LIN   		; endereco do teclado (para perguntar a uma linha se tem tecla)
    MOV	R3, TEC_COL   		; endereco do teclado (para receber resposta)
	MOV	R5, MASCARA			; para esconder os 4 bits da esquerda


; Lê uma tecla do teclado
espera_tecla:           	; Encontra coluna/linha
    MOV  R1, LINHA_LEITURA	; guarda a primeira linha a testar (5 - 0)
    MOV  R6, CONTADOR_L 	; inicia o contador de linhas (4 - 0)
espera_linha:
    SHR  R1, 1          	; passa para a linha anterior
    CMP  R1, 0
    JZ   espera_tecla   	; se já viu todas as linhas repete
    MOVB [R2], R1			; pergunta à linha se tem tecla primida
    MOVB R0, [R3]       	; recebe resposta
    SUB  R6, 1          	; decrementa o contador das linhas
    AND  R0, R5         	; isola os bits de output do teclado
    CMP  R0, 0
    JZ   espera_linha   	; se nenhuma tecla premida, repete

                        	; Converter 1248 -> 0123 (resposta/coluna)
    MOV  R10, R6        	; guarda a linha (convertida) no R10
    MOV  R11, R0        	; guarda a coluna no R11
    MOV  R8,  R0        	; guarda a coluna no R8
    MOV  R6, CONTADOR_C 	; inicia o contador de SHR da coluna
conta_colunas:
    ADD  R6,  1          	; converte as colunas de 8-4-2-1 para 3-2-1-0:
    SHR  R11, 1
    CMP  R11, 0
    JNZ  conta_colunas  	; conta o numero de SHR até passar a 0
    SUB  R6,  1          	; corrige o acrescimo inicial do contador

                        	; Converte coluna/linha --> tecla
    SHL  R10, 2         	; multiplica linha por 4 e adiciona a coluna
    ADD  R10, R6

; Funções teclas
funcoes_teclas:
	MOV R6, DIREITA
    CMP R10, R6
    JZ  direita				; se DIREITA foi primida vai para Direita

    MOV R6, ESQUERDA
    CMP R10, R6
    JZ  esquerda

	MOV R6, INCREMENTA_D
    CMP R10, R6
    JZ  incrementa_d

	MOV R6, DECREMENTA_D
    CMP R10, R6
    JZ  decrementa_d

	MOV R6, DISPARA
    CMP R10, R6
    JZ  dispara_tiro

	JMP fim_teclado			; se não for nenhuma das duas acaba a função

direita:
    MOV R7, +1       		; Output: mexe para a direita
	JMP fim_teclado			; sai da função

esquerda:
    MOV R7, -1      		; Output: mexe para a esquerda
	JMP fim_teclado

incrementa_d:
	MOV R4, [CONTADOR_DISPLAY]
	ADD R4, +1
	MOV [DISPLAYS], R4
	MOV [CONTADOR_DISPLAY], R4
	JMP ha_tecla

decrementa_d:
	MOV R4, [CONTADOR_DISPLAY]
	ADD R4, -1
	MOV [DISPLAYS], R4
	MOV [CONTADOR_DISPLAY], R4
	JMP ha_tecla

dispara_tiro:
	MOV R4, MISSIL
	MOV R4, [R4]
	MOV R3, 32
	CMP R4, R3
	JLE fim_teclado			; se já houver um missil ele sai da função
	MOV R4, MISSIL
	CALL	carrega_missil
	JMP ha_tecla

ha_tecla:
    MOVB [R2], R1    		; mesmo que em espera linha
    MOVB R0, [R3]
    AND  R0, R5
    CMP  R0, R8
    JZ  ha_tecla	  		; sai quando a tecla já não estiver primida

fim_teclado:
	POP		R11
	POP		R10
	POP		R9
	POP		R8
	POP		R6
	POP     R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
;
; **********************************************************************
atraso:

	MOV R11, ATRASO		; quantos ciclos tem o atraso
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso

	RET


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco (especificar com R4) na linha e
;			    coluna indicadas com a forma e cor definidas na tabela indicada.
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
	
	MOV	R6, [R4]			; --> altura/nº linhas
	ADD	R4, 2
	MOV R5, [R4]			; --> largura/nº colunas
	MOV	R7, R5				; guardar para poder dar reset em cada linha
	ADD R4, 2				; proxima palavra (cor do primeiro pixel)
desenha_colunas:
	MOV R3, 32
	CMP R1, R3
	JZ fim_desenha_boneco	; se a linha a desenhar estiver fora do ecrã acaba a função
desenha_linhas:
	MOV	R3, [R4]			; --> cor pixel
	CALL	escreve_pixel	; pinta o pixel
	ADD	R4, 2				; próxima cor
    ADD R2, 1				; próxima coluna
    SUB R5, 1				; decrementa contador
    JNZ	desenha_linhas		; repete até acabar a linha
	ADD R1, 1				; próxima linha
	MOV R5, R7				; reinicia o contador
	SUB R2, R7				; volta para o inicio da linha
	SUB R6, 1				; decrementa contador
	JNZ	desenha_colunas		; repete até acabar o desenho

fim_desenha_boneco:
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
;
; **********************************************************************
escreve_pixel:

	MOV  [DEFINE_LINHA],  R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL],  R3	; altera a cor do pixel na linha e coluna já selecionadas

	RET


; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumento:	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
; **********************************************************************
testa_limites:
	PUSH	R2
	PUSH 	R4
	PUSH	R5
	PUSH	R6

	MOV	R4, DEF_ROVER		; endereço da tabela que define o boneco
    MOV R1, [R4]			; R1 - linha do boneco
	ADD R4, 2				; passa para a palavra seguinte (coluna)
    MOV R2, [R4]			; R2 - coluna do boneco
	ADD R4, 2				; passa para a palavra seguinte (altura)
	ADD R4, 2				; passa para a palavra seguinte (largura)
	MOV	R6, [R4]			; obtém a largura do boneco

testa_limite_esquerdo:
	MOV	R5, MIN_COLUNA		; guarda o limite minimo do ecrã
	CMP	R2, R5
	JGT	testa_limite_direito; se não estiver na parede esquerda, testa a direita
	CMP	R7, 0				; se for mexer para a direita sai da função
	JGE	sai_testa_limites
	JMP	impede_movimento	; se estiver a tentar passar do limite esquerdo para o movimento
testa_limite_direito:
	ADD	R6, R2				; guarda a posição mais à direita do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites
	CMP	R7, 0
	JGT	impede_movimento
	JMP	sai_testa_limites	; o mesmo para o limite da direita
impede_movimento:
	MOV	R7, 0				; impede o movimento forçando R7 a 0

sai_testa_limites:	
	POP	R6
	POP	R5
	POP	R4
	POP R2
	RET

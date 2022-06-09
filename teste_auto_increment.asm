; *********************************************************************
; * IST-1103557 Mateus Correia, José Gallego, Henrique Santos
; * Modulo:    Space_Invaders.asm
; * Descricao: Feito com base nos modulos de laboratório.
; *
; * Programador: Utilizar tabs em vez de espaços sempre que possivel.
; *  			 Comentar todas as linhas que não sejam repetidas e ainda
; *				 não tenham sido comentadas.
; *				 Manter os comentários e variaveis de cada bloco nivelados.
; *********************************************************************
;
;
; **********************************************************************
; * Notas Para o Programador
; **********************************************************************
;	Utilizar tabs em vez de espaços sempre que possivel.
;	Comentar todas as linhas que não sejam repetidas e ainda não tenham sido comentadas.
;	Manter os comentários e variaveis de cada bloco nivelados.
;	Tratamento de Registos:	Só guardar ao nivel global em registos enderessos de periféricos.
;							Como o push e pop não protegem funções interiores de alterações
;						feitas aos registos pelas que as chamaram, todas as funções devem declarar
;						denovo os registos glubais que usam (se tiverem uma ideia melhor, por favor
;						digam ou deixem num comentário).
;	Se uma função pode ser partida em duas em 10 minutos, chamém o moisés dentro de todos nós, e que deus esteja com vosco. (fassam-no pls)
;	Para debugging usem break points, ajuda as funções estarem mais repartidas porque fica mais
;		fácil de usar os breakpoints, mas como o código está a ficar grande, não tentem passo a passo.
;
;
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
MIN_COLUNA		EQU 0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU 63		; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	0FFFFH	; atraso para limitar a velocidade de movimento

; Teclado
LINHA_LEITURA	EQU 16		; linha a testar (5a linha, 10000b), sendo que a sua primeira operação é SHR
CONTADOR_L  	EQU 4		; conta a linha que está a ser verificada, começa na 4 e vai para baixo
CONTADOR_C   	EQU 0		; conta os SHR precisos para a coluna passar a ser 0 (para converter para o valor certo)

; Funcões teclas  (PARA ADICIONAR NOVAS FUNÇOÕES, INSTRUÇÕES ESTÃO NA FUNÇÃO TECLADO)
DIREITA      	EQU 0FH		; tecla para mexer o rover para a direita
ESQUERDA      	EQU 0EH		; tecla para mexer o rover para a esquerda
INCREMENTA_D    EQU 01H	    ; incrementa display
DECREMENTA_D    EQU 00H     ; decrementa display

; Comandos media-center
DEFINE_LINHA    		EQU 600AH	; endereço do comando para definir a linha em que escrever
DEFINE_COLUNA   		EQU 600CH	; endereço do comando para definir a coluna em que escrever
DEFINE_PIXEL    		EQU 6012H	; endereço do comando para definir a cor do pixel a escrever
APAGA_AVISO     		EQU 6040H	; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA		 		EQU 6002H	; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H	; endereço do comando para selecionar uma imagem de fundo
INICIA_MUSICA			EQU	605AH	; endereço do comando começa uma musica, mas não em loop
TOCA_MUSICA_LOOP		EQU	605CH	; endereço do comando toca musica em loop até ser parado
PAUSA_MUSICA			EQU 605EH	; endereço do comando pausa o som selecionado
CONTINUA_MUSICA			EQU 6060H	; endereço do comando continua musica selecionada de onde tinha sido pausada
TERMINA_MUSICA			EQU 6066h	; endereço do comando termina a musica selecionada

AUTO_INCREMENT			EQU	6010

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
LINHA_R        	EQU 27	; linha de começo do rover (a meio do ecrã))
COLUNA_R		EQU 30	; coluna de começo do rover (a meio do ecrã)
ALTURA_R		EQU 5	; altura do rover
LARGURA_R		EQU 5	; largura do rover

; Asteroide bom
LINHA_AB		EQU 0	; linha de começo do cover (a meio do ecrã))
COLUNA_AB		EQU 30  ; coluna de começo do rover (a meio do ecrã)
ALTURA_AB		EQU 5	; altura do rover
LARGURA_AB		EQU 5	; largura do rover

; Asteroide mau
LINHA_AM		EQU 15	; linha de começo do cover (a meio do ecrã))
COLUNA_AM		EQU 30	; coluna de começo do rover (a meio do ecrã)
ALTURA_AM		EQU 5	; altura do rover
LARGURA_AM		EQU 5	; largura do rover

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
	WORD		VER1, VER2, VER1, VER1, VER1
	WORD		VER1, VER1, VER1, VER2, VER1
	WORD		VER1, VER1, VER1, VER1, VER1
	WORD		TRA , VER2, VER1, VER1, TRA

DEF_ASTEROIDE_MAU:
	WORD		LINHA_AM, COLUNA_AM, ALTURA_AM, LARGURA_AM

	WORD		ENC, TRA, TRA,  TRA, ENC
	WORD		TRA, ENC, AZU1, ENC, TRA
	WORD		ENC, ENC, ENC,  ENC, ENC
	WORD		ENC, AMA, ENC,  AMA, ENC
	WORD		ENC, TRA, TRA,  TRA, ENC

CONTADOR_DISPLAY:
	WORD		0
     

; **********************************************************************
; * Atribuições
; **********************************************************************
; R2  --> endereço input teclado
; R3  --> endereço output teclado
; R4  --> endereço display
; R5  --> mascara						(isolar os 4 bits da direita)


; **********************************************************************
; * Codigo
; **********************************************************************
	PLACE	0

; Inicializações
    MOV  R2, TEC_LIN   		; endereco do periferico das linhas
    MOV  R3, TEC_COL   		; endereco do periferico das colunas
    MOV  R4, DISPLAYS  		; endereco do periferico dos displays
    MOV  R5, MASCARA    	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  SP, SP_inicial	 	; inicializa SP para a palavra a seguirà última da pilha

; Inicio programa
    MOV  R7, 0       		; inicia o contador a zero
    MOV [R4], R7     		; inicia o display com o valor do contador

inicio:
    MOV [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV [APAGA_ECRA], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 1							; cenário de fundo número 0
    MOV	[SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV R1, 1							; seleciona a musica de fundo
	MOV [TOCA_MUSICA_LOOP], R1			; toca musica de fundo

     
comeco:
	CALL	mexe_asteroide				; mexe o asteroide dado
	CALL	user_input					; faz tudo o que tem a haver com input de utilizador
	CALL	atraso						; previne o computador
	JMP	comeco							; vai desenhar o boneco de novo



; **********************************************************************
; MEXE_ASTEROIDE - Responsavel pelo movimento dos asteroides.
;					?! EM CONSTRUÇÂO!?
; Argumentos:   R4 - endereço dos asteroides
;
; **********************************************************************
mexe_asteroide:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R6
	PUSH R7

posição_asteroide_mau:
	MOV	R4, DEF_ASTEROIDE_BOM			; endereço da tabela que define o boneco
    MOV R1, [R4]						; linha do boneco
	ADD R4, 2							; passa para a palavra seguinte (coluna)
    MOV R2, [R4]						; coluna do boneco
	ADD R4, 2							; passa para a palavra seguinte (altura)

mostra_asteroide_mau:
	CALL	desenha_boneco				; desenha o boneco a partir da tabela

sai_mexe_asteroide:
	POP R7
	POP R6
	POP R5
	POP R3
	POP R2
	POP R1
	POP R0
	RET


; **********************************************************************
; USER_INPUT - Trata de tudo o que envolva user input.
;			   Principalmente trata do movimento do rover, mas a função
;				teclado trata por natureza do resto dos inputs.
; Argumentos:	R1  --> posição (linha) do rover
;				R2  --> posição (coluna) do rover
;				R4  --> endereço Def_Rover
;				R6  --> largura do rover
;				R7  --> 1 -> move para a direita, -1 -> move para a esquerda, 0 -> não move
;
; **********************************************************************
user_input:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
mexe_rover:								; mexe o rover de acordo com o input
posição_boneco:
	MOV	R4, DEF_ROVER					; endereço da tabela que define o boneco
    MOV R1, [R4]						; linha do boneco
	ADD R4, 2							; passa para a palavra seguinte (coluna)
    MOV R2, [R4]						; coluna do boneco
	ADD R4, 2							; passa para a palavra seguinte (altura)

mostra_boneco:
	CALL	desenha_boneco				; desenha o boneco a partir da tabela

espera_input:							; neste ciclo espera-se até uma tecla ser premida
	MOV	R7, 0							; se nenhuma tecla for clicada, diz para não mexer
	CALL	teclado						; e alterasse o valor de R7 se Direita ou Esquerda forem clicadas
	
ve_limites:
	CALL	testa_limites				; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0							; é para mexer o rover?
	JZ sai_user_input					; se não, sai da função (se houver mais funções mete-las antes daqui)
	MOV R8, 0							; seleciona o som 3 (para o movimento do rover)
	MOV [INICIA_MUSICA], R8				; toca o som uma vez

atrasa_rover:
	CALL	atraso						; Se a figura estiver demasiado rápida alterem nas Constantes

move_boneco:
	CALL	apaga_boneco				; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD	R2, R7							; para desenhar objeto na coluna seguinte (direita ou esquerda)

atualiza_coordenadas:
	MOV	R4, DEF_ROVER					; endereço da tabela que define o boneco
	ADD R4, 2							; passa para a palavra seguinte (coluna)
	MOV [R4], R2						; atualiza a posição do rover na tabela


sai_user_input:
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
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
; Argumentos:   R0  --> output do teclado                    (colunas)
; 				R1  --> input do teclado                     (linhas)
; 				R2  --> endereço das linhas do teclado
; 				R3  --> endereço das colunas do teclado
;				R4  --> memoria do display
; 				R6  --> contador do input/output do teclado  (como os dois são inicialisados não há problema)
;					--> guarda as letras A / B
;				R8  --> posição em coluna da tecla           (em formato 1248)
;				R9  --> valor da tecla primida
; 				R10 --> posição em linha da tecla            (em formato 0123)
; 				R11 --> posição em coluna da tecla           (em formato 0123)
;
; Retorna:	R7  --> 1 se for para ir para a direita, -1 se para a esquerda
;
; **********************************************************************
teclado:
	PUSH	R0			; Guardar os registos que vão ser usados por segurança
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
    MOV  R2, TEC_LIN   		; endereco do periferico das linhas
    MOV  R3, TEC_COL   		; endereco do periferico das colunas


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

; Funções teclas
funcoes_teclas:
	MOV R6, DIREITA			; guarda a tecla A (para o CMP funcionar)
    CMP R9, R6				; A foi primida?
    JZ  direita				; vai para o incrementa
    MOV R6, ESQUERDA		; guarda a tecla B (para o CMP funcionar)
    CMP R9, R6 				; B foi primida?
    JZ  esquerda			; vai para o decrementa
	MOV R6, INCREMENTA_D	; guarda a tecla B (para o CMP funcionar)
    CMP R9, R6 				; B foi primida?
    JZ  incrementa_d		; vai para o decrementa
	MOV R6, DECREMENTA_D	; guarda a tecla B (para o CMP funcionar)
    CMP R9, R6 				; B foi primida?
    JZ  decrementa_d		; vai para o decrementa


	JMP fim_teclado			; se não for nenhuma das duas acaba a função

direita:
    MOV R7, +1       		; incrementa o contador
	JMP fim_teclado			; acaba a função

esquerda:
    MOV R7, -1      		; decrementa o contador
	JMP fim_teclado			; acaba a função

incrementa_d:
	MOV R6, DISPLAYS
	MOV R4, [CONTADOR_DISPLAY]
	ADD R4, +1
	MOV [R6], R4
	MOV [CONTADOR_DISPLAY], R4
	JMP ha_tecla

decrementa_d:
	MOV R6, DISPLAYS
	MOV R4, [CONTADOR_DISPLAY]
	ADD R4, -1
	MOV [R6], R4
	MOV [CONTADOR_DISPLAY], R4
	JMP ha_tecla

ha_tecla:
    MOVB [R2], R1    		; escrever no periferico de saida (linhas)
    MOVB R0, [R3]    		; ler do periferico de entrada (colunas)
    AND  R0, R5      		; elimina bits para alem dos bits 0-3
    CMP  R0, R8      		; a mesma tecla está premida?
    JZ  ha_tecla	  		; se sim salta vola a verificar

fim_teclado:
	POP		R11				; Recuperar os registos guardados
	POP		R10
	POP		R9
	POP		R8
	POP		R6
	POP     R4
	POP		R3
	POP		R2
	POP		R1
	POP		R0
	RET	;return


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
	PUSH	R0
	MOV R11, atraso		; quantos ciclos tem o atraso
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP		R11
	POP		R0
	RET


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco (especificar com R4) na linha e
;			    coluna indicadas com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco a desenhar
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
	MOV  [DEFINE_LINHA],  R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL],  R3	; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;				R5 - limite minimo ecrã
;				R6 - largura do boneco
;				R7 - sentido de movimento do boneco (valor a somar à coluna
;					em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 		R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites:
	PUSH	R2
	PUSH 	R4
	PUSH	R5
	PUSH	R6

testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA		; guarda o limite minimo do ecrã
	CMP	R2, R5				; está antes ou depois do minimo?
	JGT	testa_limite_direito; se estiver depois, testa o limite máximo
	CMP	R7, 0				; vai mexer em que direção?
	JGE	sai_testa_limites	; se para a direita (ou não mexe), sai da função
	JMP	impede_movimento	; se para a esquerda, para o movimento
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD R4, 2				; passa para a palavra seguinte (largura)
	MOV	R6, [R4]			; obtém a largura do boneco
	ADD	R6, R2				; guarda a posição mais à direita do boneco
	MOV	R5, MAX_COLUNA		; guarda o limite máximo do ecrã
	CMP	R6, R5				; está antes ou depois do máximo
	JLE	sai_testa_limites	; se estiver antes, sai da função (está no meio do ecrã)
	CMP	R7, 0				; vai mexer em que direção?
	JGT	impede_movimento	; se para a direita, para o movimento
	JMP	sai_testa_limites	; se para a esquerda (ou não mexe), sai da função
impede_movimento:
	MOV	R7, 0				; impede o movimento, forçando R7 a 0

sai_testa_limites:	
	POP	R6
	POP	R5
	POP	R4
	POP R2
	RET

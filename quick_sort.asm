.data
	arq_entrada: .asciiz "Alan Turing.txt"	#Nome do arquivo de entrada
	arq_saida:   .asciiz "saida.txt"      	#Nome do arquivo de saida
	buffer:      .space 8750		#Numero de caracteres que tem o arquivo de entrada
	
	array: .word 4 5 0 6 2 3 1 9
	
.text
	.globl start
	.ent start
	
start:
	li $t8, 8750 #Numero maximo de caracteres do arquivo
	li $t9, 1    #Numero de Bytes de cada caractere, 1 Bytes
	
	jal abrir_arquivo_leitura
  	jal ler_arquivo
  	
  	la $a0, buffer #Guardando o endereco do inicio do array
  	mul $a1, $t8, $t9 #Calculando o tamanho em Bytes do arquivo
  	add $a1, $a0, $a1 #Aramzenando no registrador $a1 o endereco final do array
  	
  	jal quick_sort #Inicia a funcao do Quick Sort
  	
  	jal abrir_arquivo_escrita
  	jal gravar_arquivo
  	jal fechar_arquivo	
	
	j fim
	
abrir_arquivo_leitura:
 	li $v0, 13	#Adiciona codigo para abrir um arquivo
 	la $a0, arq_entrada #Nome do arquivo de entrada
 	li $a1, 0	#Abrindo arquivo para leitura (Leitura=0 | Escrita=1)
 	li $a2, 0	# ???
 	syscall		#Inicia a leitura do arquivo
 	move $s0, $v0	#Salva a descricao do arquivo no registrador $s0 
 	jr $ra		#Retorna para o endereco onde foi chamado
 
ler_arquivo:
 	li $v0, 14	#Adiciona o codigo para ler um arquivo
 	la $a1, buffer 	#Armazendo o endereco do buffer no registrador $a2
 	move $a2, $t8	#Adicionando o numero maximo de caracteres para leitura
 	move $a0, $s0	#Adicionando o endereco do arquivo no registrador $a0
 	syscall 	#Inicia o processo de leitura do arquivo
 	jr $ra		#Retorna para o endereco onde foi chamado
 
abrir_arquivo_escrita:
 	li $v0, 13	#Adiciona codigo para abrir um arquivo
 	la $a0, arq_saida #Nome do arquivo de saida
 	li $a1, 1	#Abrindo arquivo para leitura (Leitura=0 | Escrita=1)
 	li $a2, 0	# ???
 	syscall		#Inicia a leitura do arquivo
 	move $s0, $v0	#Salva a descricao do arquivo no registrador $s0 
 	jr $ra		#Retorna para o endereco onde foi chamado
 
gravar_arquivo:
 	li $v0, 15	#Adicionando codigo para gravar uma String num Arquivo
 	move $a0, $s0	#Adicionando o endereco do arquivo no registrador $a0
 	la $a1, buffer	#Endereco do buffer que contem o texto a ser escrito
 	move $a2, $t8	#Adicionando o numero maximo de caracteres para escrita
 	syscall		#Inicia a escrita da String no arquivo
 	jr $ra		#Retorna para o endereco onde foi chamado
 	
fechar_arquivo:
 	li $v0, 16	#Adicionando codigo para fechar o arquivo
 	la $a0, arq_entrada #Adiciona no registrador $a0 o endereco do arquivo de entrada
 	syscall		#Fecha o arquivo de entrada
 	la $a0, arq_saida #Adiciona no registrador $a0 o endereco do arquivo de saida
 	syscall		#fecha o arquivo de saida
 	jr $ra		#Retorna para o endereco onde foi chamado
	
quick_sort:
	#Registrador $a0 guarda endereco do INICIO do array
	#Registrador $a1 guarda endereco do FIM do array

	sub $sp, $sp, 16 #Libera 16 Bytes na Pilha para armazenar novos valores
	sw $ra, 0($sp) #Armazena o endereco de retorno na Pilha
	sw $s0, 4($sp) #Armazena o endereco de INICIO do Array
	sw $s1, 8($sp) #Armazena o endereco de FIM do array
	sw $s2, 12($sp)#Armazena o endereco do PIVO
	
	or $s0, $zero, $a0 #Armazena no registrador $s0 o endereco do INICIO do array
	or $s1, $zero, $a1 #Armazena no registrador $s1 o endereco do FIM do array
	sub $t0, $s1, 1 #Armazena no registrador $t0 o endereco do PIVO
	
	#INICIO -> $s0
	#FIM    -> $s1
	#PIVO   -> $t0
	
	blt $s0, $t0, quick_sort_recursao #Se o INICIO for menor que o PIVO, então inicia a recursao do quick_sort
	#Caso o INICIO nao for menor que o PIVO, o vetor ja esta ordenado
	j quick_sort_fim #Termina a execucao dessa recursao do quick_sort
	
quick_sort_recursao:
	or $a0, $zero, $s0 #Guarda o endereco do INICIO
	or $a1, $zero, $s1 #Guarda o endereco do FIM
	jal interacao_array #Desvia para a interacao do array, onde realiza as trocas
	
	or $s2, $zero, $v0 #Recuperando o novo endereco do PIVO e armazenando em $s2
	
	#Apos dividir o array em dois blocos, chamar quick_sort para array a esquerda [inicio...pivo] e direita [pivo+4...fim]
	
	or $a0, $zero, $s0 #Guarda o endereco do INICIO
	or $a1, $zero, $s2 #Guarda o endereco do novo PIVO
	jal quick_sort #Chama recurssivamente o quick_sort para o array da ESQUERDA [inicio...pivo]
	
	addiu $t0, $s2, 1 #Soma + 4 Bytes ao endereco do PIVO ($s2), para pegar o proximo elemento do vetor
	
	or $a0, $zero, $t0 #Guarda o endereco do PIVO+4 (INICIO)
	or $a1, $zero, $s1 #Guarda o endereco do FIM do array
	jal quick_sort #Chama recurssivamente o quick_sort para o array da DIREITA [pivo+4...fim]
	
quick_sort_fim:
	lw $ra, 0($sp) #Recupera o endereco de retorno da Pilha
	lw $s0, 4($sp) #Recupera o endereco de INICIO do Array
	lw $s1, 8($sp) #Recupera o endereco de FIM do Array
	lw $s2, 12($sp)#Recupera o endereco do PIVO
	
	addiu $sp, $sp, 16 #Libera o espaco da Pilha

	jr $ra #Retorna para quem chamou

interacao_array:
	# $a0 -> INICIO do array
	# $a1 -> FIM do array
	# $t0 -> PIVO
	or $t0, $zero, $a1 #Armazena no registrador $t0 o endereco do FIM
	sub $t0, $t0, 1 #Armazena no registrador $t0 o endereco do PIVO
	
	or $t1, $zero, $a0 #Guarda o endereco do INICIO do array (NovaPosicaoPivo)
	or $t2, $zero, $a0 #Guarda o endereco do INICIO do array (Interador)
		
inicio_for:
	bge $t2, $t0, fim_for #Verifica se o Interador é maior que o PIVO (Verifica se chegou no final do array)
	#Caso nao esteja no final do array
	
	lb $t3, ($t0) #Carrega o valor do PIVO no registrador $t3
	lb $t4, ($t2) #Carrega o valor do Interador no registrador $t4
	
	blt $t4, $t3, trocar #Verifica se o valor do Interador é menor que o PIVO -> if (interador < pivo)
	
	#Fim do IF
	addiu $t2, $t2, 1 #Pulando Interador para o proximo endereco (interador++)
	j inicio_for 
	
trocar: #Trocar valor do (Interador) pelo (NovaPosicaoPivo)
	lb $t6, ($t1) #Guardando o valor da (NovaPosicaoPivo) no Registrador $t6
	
	or $t5, $zero, $t6 #Guarda o valor de (NovaPosicaoPivo) no registrador $t5
	or $t6, $zero, $t4 #Guarda o valor do (Interador) no registrador $t6
	or $t4, $zero, $t5 #Guarda o valor de (NovaPosicaoPivo) no registrador $t4
	
	sb $t6, ($t1) #Armazena em $t1 o conteudo de $t6 (Interador)
	sb $t4, ($t2) #Armazena em $t2 o conteudo de $t4 (NovaPosicaoPivo)
	
	addiu $t1, $t1, 1 #Pulando o (NovaPosicaoPivo) para a proxima endereco
	addiu $t2, $t2, 1 #Pulando Interador para o proximo endereco (interador++)
	j inicio_for #Volta para o inicio do for
	
fim_for:#Trocar valor do (PIVO) pelo (NovaPosicaoPivo)
	lb $t6, ($t1) #Guardando o valor da (NovaPosicaoPivo) no registrador $t6
	
	or $t5, $zero, $t6 #Guarda o valor de (NovaPosicaoPivo) no registrador $t5
	or $t6, $zero, $t3 #Guarda o valor do PIVO no registrador $t5
	or $t3, $zero, $t5 #Guarda o valor de (NovaPosicaoPivo) no registrador $t3
	
	sb $t6, ($t1) #Armazena em $t1 o conteudo de $t6 (PIVO)
	sb $t3, ($t0) #Armazena em $t0 o conteudo de $t3 (NovaPosicaoPivo)
	
	or $v0, $zero, $t1 #Aramzendo em $v0 o endereco do da NovaPosicaoPivo
	jr $ra #Retornando para quem chamou
	
fim:

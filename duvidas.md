## Dúvidas sobre a implementação

- Precisamos definir cabeçalho no arquivo e metadados?

## Estrutura da partição

[super bloco][free space mgmt][i-nodes][root dir][files and directories]

Tam total = 100mb = 102400kb = 25600 blocos

2 bytes * 25600 = 52000 bytes = 50 kb = 12 Blocos

25586 * 2

Lista de arquivos

[Nome do arquivo] -> [dados(primeiro bloco, quantidade de blocos e outras infos)]

[super bloco]  (magic number) + (total de blocos) ==> 1 bloco

[espaço livre] ==> 1 bloco

[fat] ==> 12 blocos

[files] ==> 25586 bloco


Estrutura do diretorio

Ponteiro = 2 bytes
Nome = 128 bytes
Tamanho = 27 bits ~= 4 bytes
Tipo de arquivo = 1 byte
Data(A) = 4 bytes 
Data(C) = 4 bytes 
Data(M) = 4 bytes 

TODO:: Preencher restante dos bytes inutilizados do BitMap com 1
TODO : Escrever a quantidade necessária para ser alocada no método FSFile::new_file
TODO : Size do arquivo está errado no ls

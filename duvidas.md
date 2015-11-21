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

[ ] TODO:: Preencher restante dos bytes inutilizados do BitMap com 1
[X] TODO : Escrever a quantidade necessária para ser alocada no método FSFile::new_file
[ ] TODO:: Raise Exception quando a path nao existir. Talvez dar um try catch no simulador e pegar exception de path
[ ] TODO:: Fazer o algoritmo do rmdir recursivo para apagar os subdiretorios tambem.
[X] TODO:: Arrumar ls quando não existe diretório
[ ] TODO : Size do arquivo está errado no ls
[ ] TODO:: Se eu tiver uma pasta '/dev/null/' e der um touch em um arquivo chamado null em "/dev" o arquivo é criado, avaliar se precisamos tratar esse caso 
[X] TODO:: Levantar erro pro usuário montar a unidade antes de executar qlq comando

Comandos : 

[ ] RM
[ ] Find
[X] Umount
[X] Mount correto
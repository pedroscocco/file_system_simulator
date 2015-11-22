#   ****************************************************************************
#
#   Fellipe Souto Sampaio           - 7990422
#   Pedro Alves de Medeiros Scocco  - 7558183
# 
#   Computer Science Undergraduate - University of São Paulo (IME/USP)
#   Operational Systems - Program Exercise III - README
#   Prof: Daniel M. Batista
#
#   November, 2015
#
#   ****************************************************************************

################################################################################
                               Como Compilar?
################################################################################
  O programa não precisa ser compilado, está escrito inteiramente na linguagem de script Ruby (https://www.ruby-lang.org/). 
  Para executar basta ter o ruby instalado, via binário ou RVM (https://rvm.io/). Recomendamos uma versão >= 2.0

################################################################################
                               Como executar?
################################################################################
  Para executar o programa pode-se executar o comando : 

$ ./run-ep3

  Ou direto na pasta 'src/' o comando:

$ ruby simulator.rb
    
################################################################################
                               Comandos do EP3
################################################################################

  Todos os comandos pedidos no enunciado foram implementados:
    
    mount, cp, mkdir, rmdir, cat, touch, ls, rm, find, df, umount, sai
    
  Alêm desses também foram implementados os seguintes comandos para facilitar os testes:
  
  debug            - entra no modo de interpretador para testar manualmente o programa
  full_simulation  - roda todos os testes pedidos pelo enunciado e exibe os resultados de tempo

################################################################################
                          Detalhes de Implementação
################################################################################

  Os detalhes de implementação e as decisões feitas podem ser encontrados nos slides da apresentação.

################################################################################
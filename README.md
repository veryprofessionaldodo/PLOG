# PLOG
MIEIC 2017/208

## Trabalho1
Pretende-se neste trabalho implementar, em linguagem Prolog, um jogo de tabuleiro
para dois jogadores. Um jogo de tabuleiro caracteriza-se pelo tipo de tabuleiro e de peças,
pelas regras de movimentação das peças (jogadas possíveis) e pelas condições de terminação do
jogo com derrota, vitória ou empate. Pretende-se desenvolver uma aplicação para jogar um
jogo deste tipo, usando o Prolog como linguagem de implementação. O jogo deve permitir três
modos de utilização: Humano/Humano, Humano/Computador e Computador/Computador.
Devem ser incluídos pelo menos dois níveis de jogo para o computador. Deve ser construída uma
interface adequada com o utilizador, em modo de texto.
A aplicação terá um visualizador gráfico 3D, a realizar na Unidade Curricular de LAIG.

##### Jogo escolhido: Latrunculi XXI - https://www.boardgamegeek.com/boardgame/209094/latrunculi-xxi

## Trabalho 2

### Objetivo: 
O objetivo deste trabalho é a construção de um programa em Programação em Lógica
com Restrições para a resolução de um dos problemas de otimização ou decisão combinatória
sugeridos neste enunciado. Adicionalmente, deverá ser elaborado um artigo descrevendo o
trabalho realizado e os resultados obtidos.

### Sistema de Desenvolvimento: 
O sistema de desenvolvimento recomendado é o SICStus Prolog, que inclui um módulo de resolução de restrições sobre domínios finitos: clp(FD).

### Problema: Estratégia Empresarial

Feita uma análise SWOT (pontos fortes, pontos fracos, oportunidades e ameaças) da situação
atual, uma empresa está a ponderar aplicar uma série de medidas com vista à melhoria da sua
situação. Tal melhoria pode verificar-se num conjunto de critérios C = {c1, c2, …, cn}. Cada
medida mi tem um custo associado, bem como impactos positivos ou negativos num ou mais
critérios.
Dado um orçamento limitado, pretende-se saber que medidas devem ser tomadas com vista a
maximizar a melhoria obtida. Cada critério deve poder ser priorizado, sendo a soma das
prioridades igual a 1.
Modele este problema como um problema de otimização e resolva-o com PLR, de modo a que
seja possível resolver problemas desta classe com diferentes parâmetros, isto é, diferentes
critérios e suas prioridades, diferentes medidas e seu impacto, etc.

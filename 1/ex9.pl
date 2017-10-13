comprou(joao, honda).
ano(honda, 1997). 
comprou(joao, uno).
ano(uno, 1998).
valor(honda, 20000).
valor(uno, 7000). 

pode_vender(Pessoa, Carro, Ano_Atual) :- comprou(Pessoa, Carro), ano(Carro, Ano_Compra), Diff is Ano_Atual - Ano_Compra, Diff < 10, valor(Carro, Valor), Valor > 10000.
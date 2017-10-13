food(peru).
food(frango).
food(salmao).
food(solha).
food(cerveja).
food(vinho_verde).
food(vinho_maduro).
food(vinho_verde).

likes(ana,peru).
likes(bruno, vinho_verde).
likes(ana, vinho_verde).
likes(antonio, vinho_maduro).

married(ana, bruno).
married(antonio, joana).

matches(vinho_verde, salmao).
matches(vinho_maduro, peru).

married_and_likes(X, Y, Z) :- married(X,Y), likes(X,Z), likes(Y,Z).
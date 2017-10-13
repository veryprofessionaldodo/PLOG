bird(tweety).
fish(goldy).
worm(molie).
cat(silvester).

like(X,Y):-bird(X), worm(Y).
like(X,Y):-cat(X), fish(Y).
like(X,Y):-cat(X), bird(Y).
like(X,Y):-friend(X,Y);friend(Y,X).

friend(X,Y):- X = me, pet(X, Y).
pet(me, silvester).

eat(X,Y):- pet(Z,X), Z = me , like(X,Y).

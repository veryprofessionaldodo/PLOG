male(aldo).
female(christina).
male(lincoln).
female(lisa).
male(michael).
female(sara).

parent(lincoln, aldo).
parent(lincoln, christina).

parent(michael, aldo).
parent(michael, christina).

parent(lJ, lisa).
parent(lJ, lincoln).

parent(ella, michael).
parent(ella, sara).

parent(X, Mother, Father) :- parent(X, Mother), female(Mother),
                           parent(X, Father), male(Father).

children(aldo, lincoln).
children(christina, lincoln).

children(lincoln, lJ).
children(lisa, lJ).

children(michael,ella).
children(sara,ella).




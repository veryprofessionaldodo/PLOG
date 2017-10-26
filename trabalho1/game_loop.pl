/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

:- consult(utils).
:- consult(interface).


/* BEGINNING OF GAME */



latrunculli:- write('Which type of game do you want to play? \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI\n'),
              read(ReadMode), write(ReadMode), playMode(ReadMode).

/* Starts a new game in pvp. */
playMode(1) :-  write('Good luck to both!\n'), board(StartBoard), play(StartBoard, 1), print_make_move.

/* Starts a new game in pvAI. */
playMode(2) :-  write('Good luck!\n'), board(StartBoard), play(StartBoard, 2), print_make_move.

/* Starts a new game in AIvAI. */
playMode(3) :-  write('Watch it all unfold before you!\n'), board(StartBoard), play(StartBoard, 3), nl, print_make_move.

/* Invalid game mode. */
playMode(X) :-  write('Invalid game type! Try again. \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI'),
              read(X), write(X), playMode(X).



/* THE GAME LOOP */


/* Game Loop, in pvp. */
play(Board, 1) :- print_board, read_move(1), print_board, read_move(2), print_board.

/* Game Loop in pvAI. */
play(Board, 2) :- print_board.

/* Game Loop in AIvAI. */
play(Board, 3) :- print_board.

/* Reads move for a player passed in argument. */
read_move(X):- write('Make your move Player '), write(X), nl, read(MoveString), splitString(MoveString, "-", "." , Move), write(Move), interpret(Move).

/* Takes input and makes a play out of it. */
interpret(X).





/* Sees what piece is in position. */
getPeca(Tabuleiro,Coluna,Linha,Peca):- nth1(Coluna, Tabuleiro, X), nth1(Linha, X, Peca).
















/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

/* Utilities */

/* ASCII value to number. */
ascii_to_number(048,0).
ascii_to_number(049,1).
ascii_to_number(050,2).
ascii_to_number(051,3).
ascii_to_number(052,4).
ascii_to_number(053,5).
ascii_to_number(054,6).
ascii_to_number(055,7).
ascii_to_number(056,8).
ascii_to_number(057,9).



/* ASCII value to letter. */
ascii_to_letter(097, a).
ascii_to_letter(098, b).
ascii_to_letter(099, c).
ascii_to_letter(100, d).
ascii_to_letter(101, e).
ascii_to_letter(102, f).
ascii_to_letter(103, g).
ascii_to_letter(104, h).
ascii_to_letter(105, i).
ascii_to_letter(106, j).


/* Split Array into Args */
string_to_move(StringA-StringB, ListOfMoves):-
	name(StringA, [ColumnASCII1,RowASCII1]), name(StringB,[ColumnASCII2,RowASCII2]), isColumn(ColumnASCII1), isColumn(ColumnASCII2), name(Row1, [RowASCII1]), name(Row2, [RowASCII2]), 
	name(Column1, [ColumnASCII1]), name(Column2, [ColumnASCII2]), isRow(Row1), isRow(Row2),
	ListOfMoves = [Column1,Row1,Column2,Row2].

isColumn(Letter) :- member(Letter, "abcdefghj").

isRow(Number) :- Number > 0, Number < 9.

/* All valid player letters. */
player_letter(1,'w').
player_letter(1,'W').
player_letter(2,'b').
player_letter(2,'B').

/* Converts Column Letter to Number */
column_to_number('a',1).
column_to_number('b',2).
column_to_number('c',3).
column_to_number('d',4).
column_to_number('e',5).
column_to_number('f',6).
column_to_number('g',7).
column_to_number('h',8).
column_to_number('i',9).
column_to_number('j',10).

/* Line Number to position in Board array. */
line_to_position(1,8).
line_to_position(2,7).
line_to_position(3,6).
line_to_position(4,5).
line_to_position(5,4).
line_to_position(6,3).
line_to_position(7,2).
line_to_position(8,1).

/* Attempt to move. */
attempt_to_move(Move) :- is_vertical_or_horizontal(Move).

/* Check if is horizontal or vertical move. */
is_vertical_or_horizontal(Move) :- vertical(Move) ; horizontal(Move).

horizontal(Move) :- nth0(1, Move, Row), nth0(3, Move, Row), board(Board). /*traverse_move_horizontal(Board, Move).*/ 
vertical(Move) :- nth0(0, Move, Column), nth0(2, Move, Column), board(Board). /* traverse_move_vertical(Board, Move). */ 

/* PARA ACABAR */ 

/* Down */
traverse_move_vertical(Board, Move) :- nth0(0, Move,Column), nth0(1, Move, Row1), nth0(3, Move, Row2), Row1 \= Row2, Row1 < Row2,
			Row1 is Row1 - 1, check_from_X_to_Y_Row_Left(Board, Column, Row1, Row2).

/* Up */
traverse_move_vertical(Board, Move) :- nth0(0, Move,Column), nth0(1, Move, Row1), nth0(3, Move, Row2), Row1 \= Row2, Row1 > Row2,
			Row1 is Row1 + 1, check_from_X_to_Y_Row_Right(Board, Column, Row1, Row2).

check_from_X_to_Y_Row_Up(Board, Row, Column1, Column2) :- write('Check ColumnUp from '), write(Column1), write(' to '), write(Column2), nl,
		get_piece(Board, Column1, Row, Piece), Piece = ' ',
		check_from_X_to_Y_Row(Board, Row, Column1, Column2) ; check_from_X_to_Y_Row_Up(Board, Row, Column1 + 1, Column2).

check_from_X_to_Y_Row_Down(Board, Row, Column1, Column2) :- write('Check ColumnDown from '), write(Column1), write(' to '), write(Column2), nl,
		get_piece(Board, Column1, Row, Piece), Piece = ' ',
		check_from_X_to_Y_Row(Board, Row, Column1, Column2) ; check_from_X_to_Y_Row_Up(Board, Row, Column1 - 1, Column2).

check_from_X_to_Y_Row(Board, Column, Row, Row).

/* Right */
traverse_move_horizontal(Board, Move) :- write('\nTraversing Right.'), nth0(0, Move,Column1), nth0(2, Move, Column2), nth0(3, Move, Row), Column1 \= Column2, 
	name(Column1, ColumnASCII1), name(Column2, ColumnASCII2), ColumnASCII1 < ColumnASCII2,  NewColumn is Column1 + 1, check_from_X_to_Y_Row_Up(Board, Row, NewColumn, Column2).

/* Left */
traverse_move_horizontal(Board, Move) :-  nth0(0, Move,Column1), nth0(2, Move, Column2), nth0(3, Move, Row), write(Column1), nl, write(Column2),
			Column1 \= Column2, name(Column1, ColumnASCII1), name(Column2, ColumnASCII2), ColumnASCII1 > ColumnASCII2, write('merda'),
			NewColumn is ColumnASCII1 - 1, check_from_X_to_Y_Row_Down(Board, Row, NewColumn, Column2).

check_from_X_to_Y_Column_Right(Board, Column, Row1, Row2) :- get_piece(Board, Column, Row1, Piece), Piece = ' ',
		check_from_X_to_Y_Column(Board, Column, Row1, Row2) ; check_from_X_to_Y_Column_Right(Board, Column, Row1 + 1, Row2).

check_from_X_to_Y_Column_Left(Board, Column, Row1, Row2) :- get_piece(Board, Column, Row1, Piece), Piece = ' ', 
		check_from_X_to_Y_Column(Board, Column, Row1, Row2) ; check_from_X_to_Y_Column_Right(Board, Column, Row1 - 1, Row2).

check_from_X_to_Y_Column(Board, Row, Column, Column).


/* Sees what piece is in position. */
get_piece(Board,ColumnLetter,Line,Piece):- column_to_number(ColumnLetter, ColumnNumber), line_to_position(Line, LineNumber),
     nth1(LineNumber, Board, X), nth0(ColumnNumber, X, Piece).





















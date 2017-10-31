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

isColumn(Letter) :- member(Letter, "abcdefghjABCDEFGHJ").

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























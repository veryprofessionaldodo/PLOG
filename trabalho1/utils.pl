% Utilities 
:- dynamic(playcounter/1).


is_row(Number) :- Number > 0, Number < 9.

isEqual(A,A).

% All valid player letters. 
player_letter(1,'w').
player_letter(1,'W').
player_letter(2,'b').
player_letter(2,'B').

% Converts Column Letter to Number 
column_to_number('a',1).
column_to_number('A',1).
column_to_number('b',2).
column_to_number('B',2).
column_to_number('c',3).
column_to_number('C',3).
column_to_number('d',4).
column_to_number('D',4).
column_to_number('e',5).
column_to_number('E',5).
column_to_number('f',6).
column_to_number('F',6).
column_to_number('g',7).
column_to_number('G',7).
column_to_number('h',8).
column_to_number('H',8).
column_to_number('i',9).
column_to_number('I',9).
column_to_number('j',10).
column_to_number('J',10).

% Split Array into Args 
string_to_move(StringA-StringB, ListOfMove):-
	name(StringA, [ColumnASCII1,RowASCII1]), name(StringB,[ColumnASCII2,RowASCII2]), isColumn(ColumnASCII1), isColumn(ColumnASCII2), name(Row1, [RowASCII1]), name(Row2, [RowASCII2]), 
	name(Column1, [ColumnASCII1]), name(Column2, [ColumnASCII2]), is_row(Row1), is_row(Row2),
	ListOfMove = [Column1,Row1,Column2,Row2].

isColumn(Letter) :- member(Letter, "abcdefghj").

% Line Number to position in Board array. 
line_to_position(1,8).
line_to_position(2,7).
line_to_position(3,6).
line_to_position(4,5).
line_to_position(5,4).
line_to_position(6,3).
line_to_position(7,2).
line_to_position(8,1).

% Attempt to move. 
attempt_to_move(Move) :- is_vertical_or_horizontal(Move).

% Check if is horizontal or vertical move. 
is_vertical_or_horizontal(Move) :- vertical(Move) ; horizontal(Move).

horizontal(Move) :- nth0(1, Move, Row), nth0(3, Move, Row), board(Board), traverse_move_horizontal(Board, Move). 
vertical(Move) :- nth0(0, Move, Column), nth0(2, Move, Column), board(Board), traverse_move_vertical(Board, Move).  

% Vertical
traverse_move_vertical(Board, Move) :- nth0(0, Move,Column), nth0(1, Move, Row1), nth0(3, Move, Row2), Row1 \= Row2,
			((Row1 < Row2, NewRow1 is Row1 + 1) ; (Row1 > Row2, NewRow1 is Row1 -1)), check_from_X_to_Y_Row(Board, Column, NewRow1, Row2).

% End Condition 
check_from_X_to_Y_Row(Board, Column, Row, Row) :- get_piece(Board, Column, Row, Piece), isEqual(Piece,' '). 

check_from_X_to_Y_Row(Board, Column, Row1, Row2) :- get_piece(Board, Column, Row1, Piece),  isEqual(Piece,' '),
		((Row1 < Row2, NewRow1 is Row1 + 1) ; (Row1 > Row2, NewRow1 is Row1 - 1)), check_from_X_to_Y_Row(Board, Column, NewRow1, Row2).


% Horizontal
traverse_move_horizontal(Board, Move) :- nth0(0, Move,ColumnLetter1), nth0(2, Move, ColumnLetter2), nth0(3, Move, Row),
	    column_to_number(ColumnLetter1, Column1), column_to_number(ColumnLetter2, Column2), Column1 \= Column2, 
	    ((Column1 < Column2, NewColumn1 is Column1 + 1) ; (Column1 > Column2, NewColumn1 is Column1 -1)),
	    check_from_X_to_Y_Column(Board, Row, NewColumn1, Column2).

% End Condition
check_from_X_to_Y_Column(Board, Row, Column, Column):-get_piece(Board, Column, Row, Piece), isEqual(Piece,' ').

check_from_X_to_Y_Column(Board, Row, Column1, Column2) :- ((Column1 < Column2, NewColumn1 is Column1 + 1) ; (Column1 > Column2, NewColumn1 is Column1 -1)),
		get_piece(Board, NewColumn1, Row, Piece), isEqual(Piece, ' '), check_from_X_to_Y_Column_Right(Board, Row, NewColumn1, Column2).



% Checks if player is moving is own piece, not an enemy's or a blank space. 
is_own_piece(Move, Player) :- nth0(0, Move, Column), nth0(1, Move, Line), board(Board), 
        get_piece(Board, Column, Line, Piece), player_letter(Player, Piece).


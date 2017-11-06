/************************/
/***** AI BEHAVIOUR *****/
/************************/

% Points in each AI Move:
% 10 - Direct attack to Dux
% 9 - Defends own Dux
% 7 - Positioning move to Dux
% 6 - Capture by Testudo, Flank or Phalanx
% 5 - Positioning move to Testudo, Flank or Phalanx
% 2 - Capture enemy pawn
% 1 - Position to enemy pawn
% 0 - No available move that attack enemy, random move selected.


AILevel(1).
AILevel(2).
AILevel(3).

% Gather all moves for all pieces.
gather_all_moves(AIDifficulty, ListOfMoves) :- AILevel(AIDifficulty), write('\nThinking...\n'), board(Board), gather_moves_recursive(Board, ListOfMoves, 0).

% End of recursion.
gather_moves_recursive([], ListOfMoves, RowNumber).

% Recursive function that calls itself to see all the pieces.
gather_moves_recursive([Row|Tail], ListOfMoves, RowNumber) :- gather_moves_by_row(Row, ListOfMoves, RowNumber, 0), NewRow is RowNumber + 1, gather_moves_recursive(Tail, ListOfMoves, NewRow).

% Has reached the ending row.
gather_moves_by_row([], ListOfMoves, RowNumber, ColumnNumber).

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, RowNumber, ColumnNumber) :- gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves), NewColumn is ColumnNumber + 1, 
			gather_moves_by_row(Tail, ListOfMoves, RowNumber, NewColumn). 

% Gather all moves in a specific place.			
gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves).


% TODO

% Takes all available moves, and orders them by effiency according to table above.
% Each difficulty has specific moves that it can verify. Hardest difficulty can play all atack formations
% while easier difficulties can't utilize those moves.

% HARD
order_moves_by_efficiency(AILevel, ListOfMoves, OrderedList) :- AILevel == 3.

% MEDIUM
order_moves_by_efficiency(AILevel, ListOfMoves, OrderedList) :- AILevel == 3.

% EASY
order_moves_by_efficiency(AILevel, ListOfMoves, OrderedList) :- AILevel == 3.

% Verifications
dux_in_danger().

attack_testudo().

attack_flank().

attack_phalanx().



pilot(lamb).
pilot(besenyei).
pilot(chambliss).
pilot(maclean).
pilot(mangold).
pilot(jones).
pilot(bonhomme).

team(lamb, breitling).
team(besenyei, red_bull).
team(chambliss, red_bull).
team(maclean, mediterranean_racing).
team(mangold, cobra).
team(jones, matador).
team(bonhomme, matador).

plane(lamb, mx2).
plane(besenyei, edge540).
plane(chambliss, edge540).
plane(maclean, edge540).
plane(mangold, edge540).
plane(jones, edge540).
plane(bonhomme, edge540).

circuit(istanbul).
circuit(porto).
circuit(budapest).

num_gates(istanbul, 9).
num_gates(budapest, 6).
num_gates(porto, 5).

winner(porto, jones).
winner(istanbul, mangold).
winner(budapest, mangold).

winnerTeam(Circuit, Team) :- circuit(Circuit), winner(Circuit, Pilot),
                   team(Pilot, Team).

more_than_gates(Circuit, Number) :- circuit(Circuit),
                num_gates(Circuit, Gates), Number > Gates.

more_than_1_win(Pilot) :- winner(Circuit1, Pilot), winner(Circuit2, Pilot), 
                 Circuit2 \= Circuit1.

not_piloting(X, Plane) :- pilot(X), plane(X, Plane1), Plane1 \= Plane.

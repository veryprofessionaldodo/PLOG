:-use_module(library(clpfd)).
:-use_module(library(lists)).
:-reconsult(test_cases2).

% Function to be called from SICStus terminal.
solveProblem(Budget):-
  statistics(walltime, [_TimeSinceStart | [_TimeSinceLastCall]]),
  getCostImpact(AllCost,AllImpact),
  !, 
  optimize(AllCost,AllImpact,Result,Budget),
  showResult(Result),
  statistics(walltime, [_NewTimeSinceStart | [ExecutionTime]]),
  write('Execution took '), write(ExecutionTime), write(' ms.'), nl.
   
% Measures the total impact of all measures.
getCostImpact(AllCost, AllImpact) :-
  findall(Priority,(criteria_priority(_,Priority)), AllPriorities),
  sumlist(AllPriorities, TotalPriority), 
  RoundedTotal is round(TotalPriority),
  RoundedTotal == 1,
  findall(ImpactCost, (measure(_Description, Cost, Positives, Negatives), once(measureImpact(AllPriorities, Cost, Positives, Negatives, ImpactCost))), AllImpact),
  findall(Cost,measure(_, Cost,_,_), AllCost).

% If priority sum is different than 1.
getCostImpact(_,_) :-
  write('Invalid priority sum!'), fail.

% Measures the specific impact of one measure.
measureImpact(AllPriorities, Cost, Positives, Negatives, Impact) :-
  findall(Good, (member(PriorityNumber-Value, Positives), nth0(PriorityNumber, AllPriorities, Priority), Good is (Value*Priority*1000/Cost)), PositiveImpacts),
  findall(Bad, (member(PriorityNumber-Value, Negatives), nth0(PriorityNumber, AllPriorities, Priority), Bad is (Value*Priority*1000/Cost)), NegativeImpacts),
  sumlist(PositiveImpacts, SumPos), 
  sumlist(NegativeImpacts, SumNeg),
  ImpactRound is SumPos-SumNeg, 
  Impact is round(ImpactRound).

% Main function, calls all functions to solve problem.
optimize(AllCost, AllImpact,ListResult, MaxBudget):-
  write(AllImpact), nl,
  constrain(AllCost, AllImpact,ListResult,[],TotalEfficiency,0, MaxBudget),
  length(AllImpact,L),
  domain(ListResult,1,L),
  all_distinct(ListResult),
  maximize(labeling([],ListResult), TotalEfficiency).

% Main restrictions.
constrain(_, _,List,List,Efficiency,Efficiency, CurrentBudget):-
  CurrentBudget#=0.

constrain(AllCost, _,List,List,Efficiency,Efficiency,CurrentBudget):-
  fitsBudget(AllCost,1,List,CurrentBudget).

constrain(AllCost, AllImpact,ListResult,List,TotalEfficiency,Efficiency, CurrentBudget):-
  element(X,AllImpact,Y),
  element(X,AllCost,Cost),
  append(List, [X], NewList),
  Cost #=< CurrentBudget,
  NewBudget #= CurrentBudget-Cost,
  NewEfficiency #= Efficiency + Y,
  constrain(AllCost, AllImpact,ListResult,NewList,TotalEfficiency,NewEfficiency,NewBudget).

% Checks if more measures can be fit into the available budget.
fitsBudget(AllCost,Pos,List,CurrentBudget):-
  nth1(Pos,AllCost,Elem),
  (Elem#>CurrentBudget;global_cardinality(List,[Pos-1])),
  NewPos is Pos+1,
  fitsBudget(AllCost,NewPos,List,CurrentBudget).

fitsBudget(AllCost,Pos,_,_):-
  length(AllCost,L),
  Pos>L.

% Show results recursively.
showResult(Result):-
  findall(Name,(measure(Name,_,_,_)), AllMeasures),
  write('You should apply the following measures:\n'),
  show(Result, AllMeasures).

show([], _).

show([H|T], AllMeasures):-
  nth1(H,AllMeasures,Elem),
  write(Elem),
  write('\n'),
  show(T, AllMeasures).

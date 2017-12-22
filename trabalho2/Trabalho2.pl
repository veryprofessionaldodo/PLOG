:-use_module(library(clpfd)).
:-use_module(library(lists)).
:-reconsult(utils).
:-reconsult(test_cases).

% Function to be called from SICStus.
solveProblem(Budget):-
  statistics(walltime, [TimeSinceStart | [TimeSinceLastCall]]),
  getCostImpact(AllCost,AllImpact), 
  optimize(AllCost,AllImpact,Result,Budget),
  showResult(Result),
  statistics(walltime, [NewTimeSinceStart | [ExecutionTime]]),
  write('Execution took '), write(ExecutionTime), write(' ms.'), nl.
   
% Measures the total impact of all measures.
getCostImpact(AllCost, AllImpact) :-
  findall(Priority,(criteria_priority(_,Priority)), AllPriorities),
  sumlist(AllPriorities, TotalPriority), 
  RoundedTotal is round(TotalPriority),
  RoundedTotal == 1,
  findall(ImpactCost, (measure(_Description, Cost, Positives, Negatives), once(measureImpact(AllPriorities, Cost, Positives, Negatives, ImpactCost))), AllImpact),
  findall(Cost,measure(_, Cost,_,_), AllCost).

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

exceedsBudget(AllCost,Pos,_,_):-
        length(AllCost,L),
        Pos>L.

exceedsBudget(AllCost,Pos,List,MaxBudget):-
        nth1(Pos,AllCost,Elem),
        (Elem#>MaxBudget;global_cardinality(List,[Pos-1])),
        NewPos is Pos+1,
        exceedsBudget(AllCost,NewPos,List,MaxBudget).

optimize(AllCost, AllImpact,ListResult, MaxBudget):-
        constrain(AllCost, AllImpact,ListResult,[],TotalEfeciency,0, MaxBudget),
        length(AllImpact,L),
        domain(ListResult,1,L),
        all_distinct(ListResult),
        maximize(labeling([],ListResult), TotalEfeciency).


constrain(_, _,List,List,Efeciency,Efeciency, MaxBudget):-
        MaxBudget#=0.

constrain(AllCost, _,List,List,Efeciency,Efeciency,MaxBudget):-
        exceedsBudget(AllCost,1,List,MaxBudget).


constrain(AllCost, AllImpact,ListResult,List,TotalEfeciency,Efeciency, MaxBudget):-
          element(X,AllImpact,Y),
          element(X,AllCost,Cost),
          append(List, [X], NewList),
          Cost #=< MaxBudget,
          NewBudget #= MaxBudget-Cost,
          NewEfeciency #= Efeciency + Y,
          constrain(AllCost, AllImpact,ListResult,NewList,TotalEfeciency,NewEfeciency,NewBudget).



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


	

	

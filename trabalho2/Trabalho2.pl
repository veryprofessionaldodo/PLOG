:-use_module(library(clpfd)).
:-use_module(library(lists)).
:-reconsult(utils).

% total budget.
budget(2500).

% criteria_priority(Id,Description, Priority).
criteria_priority('Employee Efficiency', 0.4).
criteria_priority('Public Relations', 0.1).
criteria_priority('Software', 0.3).
criteria_priority('Hardware', 0.2).

%measure(Id, Description, Cost, Bonus([Id-Improvement]), Setbacks([Id-Impact])).
measure('Tutorials', 100, [0-2, 1-4], [2-1]).
measure('New Computers', 500, [2-5, 1-8], [0-1]).
measure('Hire more staff', 900, [0-10, 1-20], [2-2, 3-3]).
measure('Improve food quality', 200, [0-4, 1-2], []).
measure('In house software', 1000, [0-10, 1-20], [0-3]).


getCostImpact(AllCost,AllImpact):- findall(Priority,(criteria_priority(_,Priority)), AllPriorities),
        findall(ImpactCost,(measure(_,Cost,Positive,Negative), getTotalImpact(Positive,Negative, 0, Impact,AllPriorities), ImpactCostBRound is Impact /Cost, ImpactCost is round(ImpactCostBRound)), AllImpact),
        findall(Cost,measure(_,Cost,_,_), AllCost).
        
        
getTotalImpact([] ,[], Helper, Impact,_):- Impact = Helper.
                                  
getTotalImpact([] ,[PN-IN|RN], Helper, Impact,AllPriorities):-  

        nth0(PN, AllPriorities,NImp),
        Newhelper is Helper -NImp*IN*1000,
        getTotalImpact([],RN,Newhelper,Impact,AllPriorities).
        
getTotalImpact([PP-IP|RP], [], Helper, Impact,AllPriorities):-
        nth0(PP, AllPriorities, Imp),     
        Newhelper is Helper + (Imp *IP*1000),
        getTotalImpact(RP,[],Newhelper,Impact,AllPriorities).           
        
getTotalImpact([PP-IP|RP],[PN-IN|RN], Helper, Impact,AllPriorities):-  
        nth0(PP, AllPriorities, Imp),
        nth0(PN, AllPriorities,NImp),
        Newhelper is Helper + (Imp *IP*1000-NImp*IN*1000),
        getTotalImpact(RP,RN,Newhelper,Impact,AllPriorities).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%THIS CODE IS WORKING%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*optimize(AllCost, AllImpact,ListResult, MaxBudget):-
        constrain(AllCost, AllImpact,ListResult,[], MaxBudget),!.


exceedsBudget(AllCost,Pos,_,_):-
        length(AllCost,L),
        Pos>L.

exceedsBudget(AllCost,Pos,List,MaxBudget):-
        nth1(Pos,AllCost,Elem),
        (Elem>MaxBudget;member(Pos, List)),
        NewPos is Pos+1,
        exceedsBudget(AllCost,NewPos,List,MaxBudget).
        
        
constrain(_, _,ListResult,List, 0):-ListResult=List.

constrain(AllCost, _,ListResult,List, MaxBudget):-
        exceedsBudget(AllCost,1,List,MaxBudget),
        ListResult=List.

constrain(AllCost, AllImpact,ListResult,List, MaxBudget):-
          element(X,AllImpact,Y),
          element(X,AllCost,Cost),
          append(List, [X], NewList),
          Cost #=< MaxBudget,
          all_distinct(NewList),
          maximize(labeling([],[Y,Cost]), Y), 
          NewBudget is MaxBudget-Cost,
          constrain(AllCost, AllImpact,ListResult,NewList, NewBudget).*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


solveProblem(Budget):-
               getCostImpact(AllCost,AllImpact),
               optimize(AllCost,AllImpact,Result,Budget),
               showResult(Result).

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


	

	

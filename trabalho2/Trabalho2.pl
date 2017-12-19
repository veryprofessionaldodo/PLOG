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
measure('Tutorials', 100, [0-2000, 1-4000], [2-1000]).
measure('New Computers', 500, [2-5000, 1-8000], [0-1000]).
measure('Hire more staff', 900, [0-10000, 1-20000], [2-2000, 3-3000]).
measure('Improve food quality', 200, [0-4000, 1-2000], []).
measure('In house software', 1000, [0-10000, 1-20000], [0-3000]).


getCostImpact(AllCost,AllImpact):- findall(Priority,(criteria_priority(_,Priority)), AllPriorities),
        findall(ImpactCost,(measure(_,Cost,Positive,Negative), getTotalImpact(Positive,Negative, 0, Impact,AllPriorities), ImpactCostBRound is Impact /Cost, ImpactCost is round(ImpactCostBRound)), AllImpact),
        findall(Cost,measure(_,Cost,_,_), AllCost),
        write(AllPriorities),
        write(AllImpact),
        write(AllCost).
        
        
getTotalImpact([] ,[], Helper, Impact,_):- Impact = Helper.
                                  
getTotalImpact([] ,[PN-IN|RN], Helper, Impact,AllPriorities):-  

        nth0(PN, AllPriorities,NImp),
        Newhelper is Helper -NImp*IN,
        getTotalImpact([],RN,Newhelper,Impact,AllPriorities).
        
getTotalImpact([PP-IP|RP], [], Helper, Impact,AllPriorities):-
        nth0(PP, AllPriorities, Imp),     
        Newhelper is Helper + (Imp *IP),
        getTotalImpact(RP,[],Newhelper,Impact,AllPriorities).           
        
getTotalImpact([PP-IP|RP],[PN-IN|RN], Helper, Impact,AllPriorities):-  
        nth0(PP, AllPriorities, Imp),
        nth0(PN, AllPriorities,NImp),
        Newhelper is Helper + (Imp *IP-NImp*IN),
        getTotalImpact(RP,RN,Newhelper,Impact,AllPriorities).

optimize(AllCost, AllImpact,Y,X):-
          element(X,AllImpact,Y),
          maximize(labeling([],[Y]), Y),
          element(X,AllCost,Cost),
          minimize(labeling([],[Cost]),Cost).

	

	

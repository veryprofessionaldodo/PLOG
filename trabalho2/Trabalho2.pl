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
measure('Tutorials', 100, [0-20, 1-40], [2-10]).
measure('New Computers', 500, [2-50, 1-80], [0-10]).
measure('Hire more staff', 900, [0-100, 1-200], [2-20, 3-30]).
measure('Improve food quality', 200, [0-40, 1-20], []).
measure('In house software', 1000, [0-100, 1-200], [0-30]).


getCostImpact(AllPriorities,AllImpact):- findall(Priority,(criteria_priority(_,Priority)), AllPriorities),
        findall(ImpactCost-Cost,(measure(_,Cost,Positive,Negative), getTotalImpact(Positive,Negative, 0, Impact,AllPriorities), ImpactCost is Impact /Cost), AllImpact),
        write(AllPriorities),
        write(AllImpact).
        
        
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
        
        
        
/*
% Measures the total impact of a specific measure.
calculate_impact(MeasureId, Impact) :-
	measure(MeasureId, _Description, _Cost, Bonus, Setbacks), 
	findall(Good, (member(CId-Value, Bonus), criteria_priority(CId, _Desc, Priority), Good is (Value*Priority)), Positives),
	findall(Bad, (member(CId-Value, Setbacks), criteria_priority(CId, _Desc, Priority), Bad is (Value*Priority)), Negatives),
	sumlist(Positives, SumPos), 
	sumlist(Negatives, SumNeg),
	Impact is SumPos-SumNeg.

optimize :-
	budget(Budget),
	findall(CId, criteria_priority(CId, _Criterion, _Priority), Criteria), !, % Gather all criteria above.
	findall(MId-Impact-Cost, (measure(MId, _Description, Cost, _Impacts, _Setbacks),
			calculate_impact(MId, Impact)), Measures), !, % Gather all measures above.
	Result=[],
	length(Measures, MeasuresLength),
	domain(Result, 0, MeasuresLength),
	constrain(Result)
	labeling([],Result),
	write(Measures).*/
	

	

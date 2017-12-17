:-use_module(library(clpfd)).
:-use_module(library(lists)).
:-reconsult(utils).

% total budget.
budget(3000).

% criteria_priority(Id,Description, Priority).
criteria_priority(1,'Employee Efficiency', 0.4).
criteria_priority(2,'Public Relations', 0.1).
criteria_priority(3,'Software', 0.3).
criteria_priority(4,'Hardware', 0.3).

%measure(Id, Description, Cost, Bonus([Id-Improvement]), Setbacks([Id-Impact])).
measure(1, 'Tutorials', 100, [1-20, 2-40], [3-10]).
measure(2, 'New Computers', 500, [3-50, 4-80], [1-10]).
measure(3, 'Hire more staff', 900, [1-100, 2-200], [3-20, 4-30]).
measure(4, 'Improve food quality', 200, [1-40, 2-20], []).
measure(5, 'In house software', 1000, [1-100, 2-200], [1-30]).

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
	write(Measures).
	

	

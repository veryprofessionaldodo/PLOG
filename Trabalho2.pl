:-use_module(library(clpfd)).

% total budget.
budget(20000).

% criteria_priority(Id, Description, Priority).
criteria_priority(1, 'Employee Efficiency', 0.2).
criteria_priority(2, 'Public Relations', 0.1).
criteria_priority(3, 'Software', 0.4).
criteria_priority(4, 'Hardware', 0.3).

%measure(Id, Description, Cost, Bonus([Id-Improvement]), Setbacks([Id-Impact])).
measure(1, 'Tutorials', 100, [1-20, 2-40], [3-10]).

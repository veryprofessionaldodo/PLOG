% criteria_priority(Description, Priority).
criteria_priority('Employee Efficiency', 0.1).
criteria_priority('Public Relations', 0.15).
criteria_priority('Software', 0.15).
criteria_priority('Time', 0.2).
criteria_priority('Structure of Company', 0.1).
criteria_priority('Scalability', 0.05).
criteria_priority('Hardware', 0.05).
criteria_priority('Debugging', 0.12).
criteria_priority('Hardware', 0.08).

%measure(Description, Cost, Bonus([Id-Improvement]), Setbacks([Id-Impact])).
measure('Tutorials', 200, [0-2, 1-4, 3-2, 5-1, 6-2], [2-1, 4-1,7-3,8-2]).
measure('New Computers', 350, [0-1, 4-2, 5-6, 7-1, 8-2], [1-1, 2-1,3-3,6-2]).
measure('Hire more staff', 250, [3-2, 4-1, 6-5, 7-5, 8-2], [0-3, 1-2,2-4,5-4]).
measure('Improve food quality', 200, [0-1, 1-2, 2-6, 3-1, 4-2], [6-1, 7-1,8-3,5-3]).
measure('In house software', 500, [1-2, 2-5, 4-2, 7-1, 8-4], [0-3, 3-2,5-3,6-2]).
measure('Changes to team structure', 700, [1-2, 3-2, 5-6, 6-1, 8-2], [0-1, 2-1,4-3,7-2]).
measure('Improvements to software development model', 800, [1-5, 3-3, 5-2, 7-4], [0-1, 2-1,4-3,7-2, 8-1]).
measure('Better Software for Designers', 900, [3-5,5-3,6-2,7-4], [0-1,1-1,2-3,4-5,8-1]).
measure('Better Software for Debugging', 400, [1-2,2-5,3-2,7-15], [0-1,4-1,5-3,6-5,8-4]).
measure('Better Quality Control', 800, [1-2,5-5,6-2,7-15], [0-1,2-2,3-5,4-2,8-2]).

% criteria_priority(Description, Priority).
criteria_priority('Employee Efficiency', 0.1).
criteria_priority('Public Relations', 0.15).
criteria_priority('Software', 0.07).
criteria_priority('Time Management', 0.2).
criteria_priority('Structure of Company', 0.1).
criteria_priority('Scalability', 0.05).
criteria_priority('Hardware', 0.05).
criteria_priority('Debugging', 0.10).
criteria_priority('Hardware', 0.08).
criteria_priority('Cafeteria', 0.02).
criteria_priority('Market Prospect', 0.08).

%measure(Description, Cost, Bonus([Position-Improvement]), Setbacks([Position-Impact])).
measure('Tutorials', 300, [0-2, 1-4, 3-2, 5-1, 6-2,10-4], [2-1, 4-1,7-3,8-2,9-1]).
measure('New Computers', 350, [0-1, 4-2, 5-6, 7-1, 8-2,9-1,10-1], [1-1, 2-1,3-3,6-2]).
measure('Hire more staff', 250, [3-2, 4-1, 6-5, 7-5, 8-2,9-2,10-4], [0-3, 1-2,2-4,5-4]).
measure('Improve food quality', 300, [0-1, 1-2, 2-6, 3-1, 4-2,9-5], [6-1, 7-1,8-3,5-3,10-5]).
measure('In house software', 500, [1-2, 2-5, 4-2, 7-1, 8-4,10-1], [0-3, 3-2,5-3,6-2,9-1]).
measure('Changes to team structure', 700, [1-2, 3-2, 5-6, 6-1, 8-2,9-1], [0-1, 2-1,4-3,7-2,10-7]).
measure('Improvements to software development model', 800, [1-5, 3-3, 5-2, 7-4,9-1,10-4], [0-1, 2-1,4-3,7-2, 8-1]).
measure('Better Software for Designers', 900, [3-5,5-3,6-2,7-4,9-1], [0-1,1-1,2-3,4-5,8-1,10-2]).
measure('Better Software for Debugging', 400, [1-2,2-5,3-2,7-15,9-3,10-5], [0-1,4-1,5-3,6-5,8-4]).
measure('Better Quality Control', 850, [1-2,5-5,6-2,7-15,9-1], [0-1,2-2,3-5,4-2,8-2,10-8]).
measure('Improvements to Cafeteria', 850, [9-15], [0-1,2-1,3-1,4-1,8-1,10-4]).
measure('Better Hardware', 900, [1-2,5-10,6-4,7-2,9-1,10-8], [0-4,2-3,3-2,4-1,8-1]).
measure('More Train for Managers', 700, [0-7, 1-5, 2-6, 3-6, 4-2,10-1], [6-1, 7-5,8-6,5-1,9-1]).
measure('In house software', 500, [5-4, 6-10, 7-5, 8-10, 0-8,10-9], [1-8, 2-2,3-9,4-7,9-1]).
measure('Improved Leisure Room', 900, [4-20, 6-35, 7-10, 8-10, 9-8], [1-8, 2-1,3-14,5-10,0-3,10-4]).
measure('More Market Prospect', 600, [2-5, 3-10, 4-8, 8-7, 9-8], [0-8,1-3,5-5,6-6,7-1,10-6]).
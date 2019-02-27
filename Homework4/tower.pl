%Huge shout outs to the TA slides. They were such a huge help.
%Anytime a finite domain solver is used, I learned how to implement it throught the slides.

%This function is used to check that T contains N elements
lateral_check([], _). %Base case
lateral_check([ Head | Tail ], N) :-
    length(Head, N) , lateral_check(Tail, N). %Check first row, then call again on tail

%Make sure each element in T is below N
value_check(_, []). %Base case
value_check(N, [ Head | Tail]) :-
    fd_domain(Head, 1, N) , value_check(N, Tail).

%Borrowed code from: https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
%Used to transpose T so checks only have to be done one way
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

%Flips the matrix to check other side
flip_matrix([], []).
flip_matrix([ Head | Tail ], [ A | B ]) :-
    reverse(Head, A) , flip_matrix(Tail, B).

%Are the elements before this one less?
lowest_boi([], _).
lowest_boi([ Head | Tail ], Holdme) :-
    Head #< Holdme , %Thank you TA slides
    lowest_boi(Tail, Holdme). % Call on the rest of the list

%Checks exact values, this was the hard part for sure 
check_me([], _, Acc) :- % Base vase
    Acc = 0.
check_me([ Head | Tail ], List, Acc) :-
    % Go through list and accumulate values as it is passed
    append(List, [ Head ], List2) ,
    check_me(Tail, List2, Acc2),
    (lowest_boi(List, Head) -> Acc is Acc2 + 1; Acc2 = Acc).

%Left to right, checks how many towers are visible
check_row([], []).
check_row([ Head | Tail ], [ Val | Othervals ]) :-
    check_me(Head, [], Total) ,
    Total = Val ,
    check_row(Tail, Othervals).

%This function checks the towers that are able to be seen
answer_check(T, CoolerT, Top, Bottom, Left, Right) :-
    check_row(T, Left) ,
    check_row(CoolerT, Top) ,
    %Flip matricies and perform same function
    flip_matrix(T, Eet) ,
    flip_matrix(CoolerT, Trelooc) ,
    check_row(Eet, Right) ,
    check_row(Trelooc, Bottom).


tower(N, T, C) :-
    %Perform basic checks on parameters
    length(T, N) , %Make sure T contains N lists
    lateral_check(T, N) , %Makes sure each list in T contains N elements
    C = counts(Top, Bottom, Left, Right) , %Taken from specs
    maplist(fd_all_different, T) , %Makes sure that each element in each list is different
    value_check(N, T) , %Checks values
    %Check that tower counts are valid
    length(Top, N) ,
    length(Bottom, N) ,
    length(Left, N) ,
    length(Right, N) , 
    transpose(T, CoolerT) , %Flips T so it may be checked in the other direction
    maplist(fd_all_different, CoolerT) , %Makes sure that each element in each list is different
    value_check(N, CoolerT) , %Checks values
    %Finally, check for real answers
    maplist(fd_labeling, T) , %Unique answers
    answer_check(T, CoolerT, Top, Bottom, Left, Right). %Finally, check the answer now that parameters are fine

%Here is where I will implement my own slower versions of fd things
%fd_domain replacement
domain_check(_, []). %Base case
domain_check(N, [ Head | Tail]) :- %Make sure all numbers are in place
    Max is N + 1 ,
    Head #< Max ,
    Head #> 0 ,
    domain_check(N, Tail).

%fd_all_different replacement
all_different(_, []). %Base case
all_different(History, [ Head | Tail]) :-
    \+ member(Head, History) , % Thank you TA slides
    all_different([ Head | History], Tail).

%fd_labeling replacement
label_check(N, T) :-
    %findall tutorial: http://www.cse.unsw.edu.au/~billw/dictionaries/prolog/findall.html
    findall(Holdme, between(1, N, Holdme), Goeshere) ,
    %permutation tutorial: http://www.swi-prolog.org/pldoc/man?predicate=permutation/2
    permutation(Goeshere, T).

plain_tower(N, T, C) :-
    %Perform basic checks on parameters
    length(T, N) , %Make sure T contains N lists
    lateral_check(T, N) , %Makes sure each list in T contains N elements
    C = counts(Top, Bottom, Left, Right) , %Taken from specs
    maplist(domain_check(N), T) ,
    maplist(all_different([]), T) ,
    %Check that tower counts are valid
    length(Top, N) ,
    length(Bottom, N) ,
    length(Left, N) ,
    length(Right, N) , 
    maplist(label_check(N), T) ,
    transpose(T, CoolerT) , %Flips T so it may be checked in the other direction
    maplist(all_different([]), CoolerT) , %fd_all_different
    %Finally, for real answers
    answer_check(T, CoolerT, Top, Bottom, Left, Right). %Finally, check the answer now that parameters are fine

%Run an example 20 times to avoid divide by 0 error
tower_alot(Tt) :-
    statistics(cpu_time, [Ti,_]) ,
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    statistics(cpu_time, [Tf, _]) ,
    Tt is Tf - Ti .

%Run an example 20 times to avoid divide by 0 error
plain_tower_alot(Pt) :-
    statistics(cpu_time, [Pi,_]) ,
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    plain_tower(5, [[2,3,4,5,1], [5,4,1,3,2], [4,1,5,2,3], [1,2,3,4,5], [3,5,2,1,4]], C),
    statistics(cpu_time, [Pf, _]) ,
    Pt is Pf - Pi .

speedup(Answer) :-
    %Unify the argument to the fp ratio of tower's CPU time to plain
    %Tutorial for statistics: http://gprolog.univ-paris1.fr/manual/html_node/gprolog048.html#statistics%2F2
    tower_alot(Tt) ,
    plain_tower_alot(Pt) , 
    Answer is (Pt/Tt) .

ambiguous(N, C, T1, T2) :-
    tower(N, T1, C) , %Check first solution
    tower(N, T2, C) , %Check second solution
    T1 \= T2.
%Huge shout outs to the TA slides. They were such a huge help.
%Anytime a finite domain solver is used, I learned how to implement it throught the slides.
%Trivial function to verify N is not negative
is_pos(N) :- N >= 0.

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
    is_pos(N) , %Make sure N is a non-negative value
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
    maplist(fd_labeling, T) , %Unique answers
    answer_check(T, CoolerT, Top, Bottom, Left, Right). %Finally, check the answer now that parameters are fine

%Here is where I will implement my own slower versions of fd things
%Bad version of fd_all_different
all_different_but_bad([], _). %Base case
all_different_but_bad([ Head | Tail ], History) :-
    not(member(Head, History)) , %If haven't seen before
    all_different_but_bad(Tail, [ Head | History ]). %Check the rest

plain_tower(N, T, C) :-
    %Perform basic checks on parameters
    is_pos(N) , %Make sure N is a non-negative value
    length(T, N) , %Make sure T contains N lists
    lateral_check(T, N) , %Makes sure each list in T contains N elements
    C = counts(Top, Bottom, Left, Right) , %Taken from specs
    maplist(all_different_but_bad, T) , %Instead of fd_all_different
    %Instead of value_check (That uses fd_domain)
    %Check that tower counts are valid
    length(Top, N) ,
    length(Bottom, N) ,
    length(Left, N) ,
    length(Right, N) , 
    transpose(T, CoolerT) , %Flips T so it may be checked in the other direction
    maplist(all_different_but_bad, CoolerT) , %Instead of fd_all_different for the transpose
    %Instead of value_check (That uses fd_domain) fpr the transpose
    % Get rid ununique answers without fd_labeling
    answer_check(T, CoolerT, Top, Bottom, Left, Right). %Finally, check the answer now that parameters are fine

ambiguous(N, C, T1, T2) :-
    tower(N, T1, C) , %Check first solution
    tower(N, T2, C) , %Check second solution
    T1 \= T2.
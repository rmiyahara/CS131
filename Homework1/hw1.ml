(*Write a function subset a b that returns true iff a⊆b, i.e., if the set represented by the list a is a subset of the set represented by the list b.*)
let rec subset a b = match a with
    [] -> true
    | head :: tail -> if List.mem head b then subset tail b else false;;

(*Write a function equal_sets a b that returns true iff the represented sets are equal*)
let equal_sets a b =
    subset a b && subset b a;;

(*Write a function set_union a b that returns a list representing a∪b.*)
let rec set_union a b = match b with
    [] -> a
    | head :: tail -> if List.mem head a then set_union a tail else set_union (head :: a) tail;;

(*Write a function set_intersection a b that returns a list representing a∩b*)
let set_intersection a b =
    List.filter (fun p -> List.mem p b) a;;

(*Write a function set_diff a b that returns a list representing a−b, that is, the set of all members of a that are not also members of b.*)
let set_diff a b =
    List.filter (fun p -> not(List.mem p b)) a;;

(*Write a function computed_fixed_point eq f x that returns the computed fixed point for f with respect to x, assuming that eq is the equality
* predicate for f's domain. A common case is that eq will be (=), that is, the builtin equality predicate of OCaml; but any predicate can be used.
* If there is no computed fixed point, your implementation can do whatever it wants: for example, it can print a diagnostic, or go into a loop,
* or send nasty email messages to the user's relatives.*)
let rec computed_fixed_point eq f x =
    if eq (f x) x then x else computed_fixed_point eq f (f x);;

(*OK, now for the real work. Write a function filter_reachable g that returns a copy of the grammar g with all unreachable rules removed.
* This function should preserve the order of rules: that is, all rules that are returned should be in the same order as the rules in g.*)
let filter_reachable g =
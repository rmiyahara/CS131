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
    | head :: tail -> if List.mem head a then set_union a tail else set_union (head :: a) tail

(*Write a function set_intersection a b that returns a list representing a∩b*)
let rec set_intersection a b =
    List.filter (fun p -> List.mem p b) a;;
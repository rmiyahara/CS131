(*
* NAME: Ryan Miyahara
* ID: 804585999
* EMAIL: rmiyahara144@gmail.com
*)

let rec convert_grammar gram1 =

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let rec parse_tree_leaves tree = match tree with
    [] -> []
    | Leaf head :: tail -> head :: parse_tree_leaves tail
    | Node _ :: tail -> parse_tree_leaves tail
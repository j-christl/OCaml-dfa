# OCaml-dfa

<br/><br/>
<a href="http://ocaml.org">
  <img src="http://ocaml.org/logo/Colour/PNG/colour-logo.png"
       alt="OCaml"
       width=200px />
</a>
<br/><br/>

Simple implementation of deterministic finite automata in OCaml

(See https://en.wikipedia.org/wiki/Deterministic_finite_automaton )

## Example

```ocaml
(* Automaton accepting binary inputs which only consist of '1's (or blank) *)
let automaton_binary_only_ones =  
                    ["q1";"q2"], (* Q: set of states *)
                    ['0';'1'],   (* Σ: alphabet *)  
                    (fun state input -> match state with
                                                | "q1" -> if input = '0' then "q2" else "q1"
                                                | "q2" -> "q2"
                                                | _ -> raise (Failure "Invalid input")
                    ),      (* δ: transition function *)
                    "q1",   (* q0: start state *)
                    ["q1"]  (* F: set of accept states *)

(* second example automaton: It accepts binary inputs which are multiples of three *)
let automaton_binary_multiples_of_three =  
                    ["q0";"q1";"q2"], (* Q: set of states *)
                    ['0';'1'],        (* Σ: alphabet *)  
                    (fun state input -> match state with
                                                | "q0" -> if input = '0' then "q0" else "q1"
                                                | "q1" -> if input = '0' then "q2" else "q0"
                                                | "q2" -> if input = '0' then "q1" else "q2"
                                                | _ -> raise (Failure "Invalid")
                    ),      (* δ: transition function *)
                    "q0",   (* q0: start state *)
                    ["q0"]  (* F: set of accept states *)

# dfa_process automaton_binary_only_ones "11111110";;
- : bool * string = (false, "q2")
# dfa_process automaton_binary_only_ones "1111";;
- : bool * string = (true, "q1")
# print_dfa_graphviz automaton_binary_multiples_of_three;; (* Note that we used the second automaton here *)
- : string =
"digraph dfa {
  rankdir="LR"
  "" [shape=none]
  "q0" [shape=doublecircle]
  "q1" [shape=circle]
  "q2" [shape=circle]
  "" -> q0
  "q0" -> "q0" [label="0"]
  "q1" -> "q2" [label="0"]
  "q2" -> "q1" [label="0"]
  "q0" -> "q1" [label="1"]
  "q1" -> "q0" [label="1"]
  "q2" -> "q2" [label="1"]
}"
```
The resulting graph image (for example if we enter it at [Webgraphviz](http://www.webgraphviz.com/)):
<br/><br/>
<a href="https://en.wikipedia.org/wiki/Deterministic_finite_automaton#/media/File:DFA_example_multiplies_of_3.svg">
  <img src="https://github.com/yoshc/OCaml-dfa/blob/master/example-graphviz.png"
       alt="Resulting Graphviz graph"
       width=400px />
</a>
<br/><br/>

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
(* Automaton accepting binary inputs which only consist of '1's *)
let automaton_binary_only_ones =  
                    ["q1";"q2"], (* Q: set of states *)
                    ['0';'1'],   (* Σ: alphabet *)  
                    (fun state input -> match state with
                                                | "q1" -> if input = '0' then "q2" else "q1"
                                                | "q2" -> "q2"
                                                | _ -> raise (Failure "Invalid input")
                    ), (* δ: transition function *)
                    "q1", (* q0: start state *)
                    ["q1"] (* F: set of accept states *)
                    
# dfa_process automaton_binary_only_ones "11111110";;
- : bool * string = (false, "q2")
# dfa_process automaton_binary_only_ones "1111";;
- : bool * string = (true, "q1")
```

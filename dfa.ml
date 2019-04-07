(* OCaml-dfa
 * ************
 * Simple implementation of deterministic finite automata in OCaml
 * (See https://en.wikipedia.org/wiki/Deterministic_finite_automaton )
 * https://github.com/yoshc/OCaml-dfa
 * ************
 *)

(* -----
 * Help functions
 * (See https://github.com/yoshc/OCaml-utils )
 * ----- 
 *)
let list_index_of l element =
  let rec list_index_of_rec li element count =
    match li with
        []    -> -1
      | x::xs ->  if x = element then count
                  else list_index_of_rec xs element (count+1) 
  in list_index_of_rec l element 0

let list_contains l element =
  (list_index_of l element) >= 0

let string_to_charlist str =
  let rec impl i len =
    if i = len then [] else (String.get str i)::(impl (i+1) len)
  in impl 0 (String.length str)

(* -----
 * DFA functions
 * ----- 
 *)

(* defines a deterministic finite automaton (DFA) *)
type dfa =  string list * (* Q: set of states *)
            char list * (* Σ: alphabet *) 
            (string -> char -> string) * (* δ: transition function *)
            string * (* q0: start state *)
            string list (* F: set of accept states *)

(* val dfa_process : dfa -> string -> (bool * string)
 *
 * Processes a given input on an given automaton
 * Returns a tuple (accepted,end_state) where
 *   accepted   := true if given input is accepted by the automaton, false otherwise
 *   end_state  := the end state of the automaton after processing the input
 *)
let rec dfa_process (automaton_:dfa) (input_:string) =
    let rec dfa_step (automaton:dfa) (input:char list) (current_state:string) =
        let states_set, alphabet, transit_fun,start_state,accept_states = automaton in
        match input with
            | [] -> (if list_contains accept_states current_state then
                        (true, current_state)
                     else (false, current_state))
            | h::t -> dfa_step automaton t (transit_fun current_state h)
    in
        let _,_,_,start_state,_ = automaton_ in
        dfa_step automaton_ (string_to_charlist input_) start_state

(* val print_dfa_graphviz : dfa -> string
 *
 * Converts the given dfa into its graphviz string
 *)
let print_dfa_graphviz (automaton_:dfa) =
  let rec print_accept_states accept_states_ =
    match accept_states_ with
      | [] -> ""
      | x::xs -> "  \"" ^ x ^ "\" [shape=doublecircle]\n" ^ (print_accept_states xs)
  in let rec print_states states_set_ accept_states_ =
    match states_set_ with
      | [] -> ""
      | x::xs -> (if (list_contains accept_states_ x) then (print_states xs accept_states_)
                  else ("  \"" ^ x ^ "\" [shape=circle]\n" ^ (print_states xs accept_states_)))
  in let rec process_letter letter transit_fun_ states_set_ =
    match states_set_ with
      | [] -> ""
      | curr_state::rest_states ->
          let result_state = try (transit_fun_ curr_state letter) with (Failure _) -> (process_letter letter transit_fun_ rest_states) in
            ("  \"" ^ curr_state ^ "\" -> \"" ^ result_state ^ "\" [label=\"" ^ (String.make 1 letter) ^ "\"]\n") ^ (process_letter letter transit_fun_ rest_states)
  in let rec print_transitions transit_fun_ alphabet_ states_set_ =
    match alphabet_ with
      | [] -> ""
      | x::xs -> (process_letter x transit_fun_ states_set_) ^ (print_transitions transit_fun_ xs states_set_)
  in let impl automaton =
    let states_set, alphabet, transit_fun,start_state,accept_states = automaton in
    "digraph dfa {\n  rankdir=\"LR\"\n  \"\" [shape=none]\n"
    ^ ("")
    ^ (print_accept_states accept_states)
    ^ (print_states states_set accept_states)
    ^ ("  \"\" -> " ^ start_state ^ "\n")
    ^ (print_transitions transit_fun alphabet states_set)
    ^ "}"
  in impl automaton_

(* -----
 * Example automata
 * ----- 
 *)

(* first example automaton: It accepts binary inputs which only consist of '1's
 * examples: "11111"    -> accepted
 *           "11111111" -> accepted
 *           "1101111"  -> not accepted
 *           "11110"    -> not accepted
 *)
let automaton_binary_only_ones =  
                    ["q1";"q2"], (* Q: set of states *)
                    ['0';'1'],   (* Σ: alphabet *)  
                    (fun state input -> match state with
                                                | "q1" -> if input = '0' then "q2" else "q1"
                                                | "q2" -> "q2"
                                                | _ -> raise (Failure "Invalid")
                    ), (* δ: transition function *)
                    "q1", (* q0: start state *)
                    ["q1"] (* F: set of accept states *)

(* second example automaton: It accepts binary inputs which are multiples of three
 * (See https://en.wikipedia.org/wiki/Deterministic_finite_automaton#/media/File:DFA_example_multiplies_of_3.svg )
 * examples: "11"   -> accepted
 *           "110"  -> accepted
 *           "111"  -> not accepted
 *)
let automaton_binary_multiples_of_three =  
                    ["q0";"q1";"q2"], (* Q: set of states *)
                    ['0';'1'],   (* Σ: alphabet *)  
                    (fun state input -> match state with
                                                | "q0" -> if input = '0' then "q0" else "q1"
                                                | "q1" -> if input = '0' then "q2" else "q0"
                                                | "q2" -> if input = '0' then "q1" else "q2"
                                                | _ -> raise (Failure "Invalid")
                    ), (* δ: transition function *)
                    "q0", (* q0: start state *)
                    ["q0"] (* F: set of accept states *)

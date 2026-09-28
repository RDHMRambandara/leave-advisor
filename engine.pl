% =====================================================================
%  engine.pl  -  INFERENCE ENGINE (forward + backward chaining)
%                and EXPLANATION FACILITY
% =====================================================================
:- ensure_loaded(kb).

:- dynamic known/1, derived/2, support/3.

% ---------------------------------------------------------------------
% Working memory
%   known(F)            facts given by the user
%   derived(F, RuleId)  facts inferred by the engine
%   support(RuleId, F, InstantiatedConditions)  used for explanations
% ---------------------------------------------------------------------
reset_session :-
    retractall(known(_)), retractall(derived(_, _)), retractall(support(_, _, _)).

% a fact is true if it is in the knowledge base, was given, or was derived
fact(F) :- kb_fact(_, F, _).
fact(F) :- known(F).
fact(F) :- derived(F, _).

is_test(C) :-
    callable(C), C =.. [Op|Args], length(Args, 2),
    memberchk(Op, [is, >=, =<, <, >, =:=, =\=]).

attr_known(Attr) :- known(T), functor(T, Attr, 1), !.

% evaluate ONE condition against working memory
holds(C) :- is_test(C), !, call(C).
holds(not(F)) :- !, functor(F, A, 1), attr_known(A), \+ fact(F).
holds(C) :- fact(C).

holds_all([]).
holds_all([C|Cs]) :- holds(C), holds_all(Cs).

% ---------------------------------------------------------------------
% FORWARD CHAINING  (data-driven: "given these facts, what follows?")
% Repeat: find any rule whose conditions all hold and whose conclusion is
% new; add the conclusion; stop when nothing new can be derived.
% ---------------------------------------------------------------------
forward_chain :-
    retractall(derived(_, _)), retractall(support(_, _, _)),
    fc_loop.

fc_loop :- fc_step, !, fc_loop.
fc_loop.

fc_step :-
    rule(Id, _, _, Conds, Concl),
    holds_all(Conds),
    \+ derived(Concl, _),
    assertz(derived(Concl, Id)),
    assertz(support(Id, Concl, Conds)).

% ---------------------------------------------------------------------
% BACKWARD CHAINING  (goal-driven: "can this conclusion be proved?")
% Starts from a goal, finds rules whose conclusion matches, and proves
% their conditions recursively. Missing input facts are ASKED on demand.
% bc(Goal, ProofTree) builds a proof tree used for the explanation.
% ---------------------------------------------------------------------
bc(G, test(G)) :- is_test(G), !, call(G).
bc(not(G), naf(G)) :- !, functor(G, A, 1), ensure_asked(A), \+ fact(G).
bc(G, fact(G, user)) :-
    functor(G, A, 1), input(A, _, _), !,
    ensure_asked(A), known(G).
bc(G, fact(G, kb(Id))) :- kb_fact(Id, G, _).
bc(G, derived(G, Id, Subs)) :-
    rule(Id, _, _, Conds, G),
    bc_all(Id, Conds, Subs).

bc_all(_, [], []).
bc_all(Id, [C|Cs], [T|Ts]) :-
    nb_setval(current_rule, Id),
    bc(C, T),
    bc_all(Id, Cs, Ts).

% ---------------------------------------------------------------------
% ASKING THE USER
% ---------------------------------------------------------------------
ensure_asked(A) :- attr_known(A), !.
ensure_asked(A) :- nb_current(noninteractive, true), !, fail, A = A.
ensure_asked(A) :-
    input(A, Type, Q),
    ( nb_current(current_rule, R), R \== none
    -> format('~n  [Why am I asking? Rule ~w needs this information.]~n', [R])
    ;  true ),
    prompt_value(Type, Q, V),
    T =.. [A, V],
    assertz(known(T)).

prompt_value(yesno, Q, V) :- !,
    format('  ~w (yes/no): ', [Q]), flush_output,
    read_answer(S),
    (   memberchk(S, [y, yes]) -> V = yes
    ;   memberchk(S, [n, no])  -> V = no
    ;   format('  Please type yes or no.~n'), prompt_value(yesno, Q, V) ).
prompt_value(choice(Opts), Q, V) :- !,
    format('  ~w~n', [Q]),
    forall(nth1(I, Opts, O), format('     ~w) ~w~n', [I, O])),
    format('  Your choice (number or name): '), flush_output,
    read_answer(S),
    (   atom_number(S, N), integer(N), nth1(N, Opts, V0) -> V = V0
    ;   memberchk(S, Opts) -> V = S
    ;   format('  Invalid choice.~n'), prompt_value(choice(Opts), Q, V) ).
prompt_value(number, Q, V) :- !, prompt_value(number(0, 1000000000), Q, V).
prompt_value(number(Min, Max), Q, V) :-
    format('  ~w: ', [Q]), flush_output,
    read_answer(S),
    (   atom_number(S, N), number(N), N >= Min, N =< Max -> V = N
    ;   format('  Please enter a number between ~w and ~w.~n', [Min, Max]),
        prompt_value(number(Min, Max), Q, V) ).

read_answer(A) :-
    read_line_to_string(user_input, S),
    (   S == end_of_file -> halt
    ;   string_lower(S, L), split_string(L, "", " \t\r\n", [T]), atom_string(A, T) ).

% ---------------------------------------------------------------------
% EXPLANATION FACILITY
% ---------------------------------------------------------------------
% Explain how each forward-chaining conclusion was reached
explain_forward :-
    format('~n-------- HOW THE CONCLUSIONS WERE REACHED (rules applied, in order) --------~n'),
    findall(Id-C, derived(C, Id), L),
    (   L == [] -> format('No rule could be applied to the facts provided.~n')
    ;   forall(nth1(N, L, Id-C), explain_step(N, Id, C)) ).

explain_step(N, Id, C) :-
    rule(Id, Src, Desc, _, _),
    support(Id, C, Conds),
    format('~n[~w] Rule ~w: ~w~n', [N, Id, Desc]),
    format('     IF   ~w~n', [Conds]),
    format('     THEN ~w~n', [C]),
    source(Src, Name, URL),
    format('     Source (~w): ~w~n              ~w~n', [Src, Name, URL]).

% Print the plain-English results of forward chaining
print_results :-
    format('~n======================= RESULTS =======================~n'),
    findall(S, (derived(C, _), describe(C, S)), L),
    (   L == [] -> format('No advice could be produced from the facts given.~n')
    ;   forall(member(S, L), format(' * ~w~n', [S])) ).

% Print the proof tree of a backward-chaining proof
print_tree(T) :- print_tree(T, 0).

print_tree(fact(G, user), I) :- ind(I), format('~w   [given by the user]~n', [G]).
print_tree(fact(G, kb(Id)), I) :-
    kb_fact(Id, G, Src), ind(I),
    format('~w   [knowledge-base fact ~w, source ~w]~n', [G, Id, Src]).
print_tree(test(G), I) :- ind(I), format('~w   [arithmetic check passed]~n', [G]).
print_tree(naf(G), I) :- ind(I), format('not ~w   [confirmed: not the case]~n', [G]).
print_tree(derived(G, Id, Subs), I) :-
    rule(Id, Src, Desc, _, _), ind(I),
    format('~w   [proved by rule ~w: ~w  (source ~w)]~n', [G, Id, Desc, Src]),
    I2 is I + 4,
    forall(member(S, Subs), print_tree(S, I2)).

ind(N) :- forall(between(1, N, _), put_char(' ')).

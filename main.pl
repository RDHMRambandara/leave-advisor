% =====================================================================
%  main.pl  -  USER INTERFACE (text menu)
%  Sri Lankan Employee Leave & Statutory Benefits Advisor
%  Run:  swipl main.pl
% =====================================================================
:- ensure_loaded(engine).
:- initialization(main, main).

main :-
    nb_setval(current_rule, none),
    banner,
    menu_loop.

banner :-
    format('~n=====================================================~n'),
    format('  SRI LANKAN EMPLOYEE LEAVE & BENEFITS ADVISOR~n'),
    format('  Rule-based expert system (Prolog)~n'),
    format('=====================================================~n').

menu_loop :-
    format('~nMAIN MENU~n'),
    format('  1) Full assessment            (forward chaining)~n'),
    format('  2) Ask one specific question  (backward chaining)~n'),
    format('  3) View knowledge base        (facts, rules and sources)~n'),
    format('  0) Exit~n'),
    format('Choose an option: '), flush_output,
    read_answer(A),
    (   A == '1' -> full_assessment, menu_loop
    ;   A == '2' -> goal_menu,       menu_loop
    ;   A == '3' -> show_kb,         menu_loop
    ;   A == '0' -> format('Goodbye.~n')
    ;   format('Invalid option.~n'), menu_loop ).

% ---------------------------------------------------------------------
% MODE 1: FORWARD CHAINING
% ---------------------------------------------------------------------
full_assessment :-
    reset_session, nb_setval(current_rule, none),
    format('~n--- FULL ASSESSMENT: answer the questions below ---~n'),
    ask_order(Order),
    forall(member(A, Order), ( should_ask(A) -> ensure_asked(A) ; true )),
    format('~nFacts entered:~n'),
    forall(known(F), format('   ~w~n', [F])),
    forward_chain,
    print_results,
    explain_forward,
    pause_msg.

should_ask(A) :-
    (   input_when(A, Cs) -> forall(member(C, Cs), known(C)) ; true ).

% ---------------------------------------------------------------------
% MODE 2: BACKWARD CHAINING
% ---------------------------------------------------------------------
goals([ '1'-('How many ANNUAL LEAVE days?',            [annual_leave_days(_)]),
        '2'-('How many CASUAL LEAVE days?',            [casual_leave_days(_)]),
        '3'-('What MATERNITY LEAVE applies?',          [maternity_leave(_, _, _, _)]),
        '4'-('Is the employee eligible for GRATUITY?', [gratuity_eligible(yes),
                                                        gratuity_ineligible(_),
                                                        gratuity_excluded(_)]),
        '5'-('How much is the GRATUITY?',              [gratuity_amount(_)]),
        '6'-('What are the EPF contributions?',        [epf_employee_contribution(_),
                                                        epf_employer_contribution(_)]),
        '7'-('What is the ETF contribution?',          [etf_employer_contribution(_)]) ]).

goal_menu :-
    reset_session, nb_setval(current_rule, none),
    goals(Gs),
    format('~n--- ASK A SPECIFIC QUESTION ---~n'),
    forall(member(K-(Q, _), Gs), format('  ~w) ~w~n', [K, Q])),
    format('  0) Back~nChoose a question: '), flush_output,
    read_answer(A),
    (   A == '0' -> true
    ;   memberchk(A-(Q, GoalList), Gs)
    ->  format('~nGOAL: ~w~n', [Q]),
        format('The system now works BACKWARD from the goal and asks only for the facts it needs.~n'),
        prove_goals(GoalList, Found),
        (   Found == false
        ->  format('~nThe goal could not be proved from the facts given (it does not apply).~n')
        ;   true ),
        pause_msg
    ;   format('Invalid option.~n'), goal_menu ).

prove_goals([], false).
prove_goals([G|Gs], Found) :-
    (   bc(G, Tree)
    ->  Found = true,
        format('~n================ ANSWER ================~n'),
        (   describe(G, S) -> format(' * ~w~n', [S]) ; format(' * ~w~n', [G]) ),
        format('~n-------- PROOF (how the answer was reached) --------~n'),
        print_tree(Tree)
    ;   prove_goals(Gs, Found) ).

% ---------------------------------------------------------------------
% MODE 3: VIEW KNOWLEDGE BASE
% ---------------------------------------------------------------------
show_kb :-
    format('~n=========== SOURCES ===========~n'),
    forall(source(Id, N, U), format(' ~w: ~w~n      ~w~n', [Id, N, U])),
    format('~n=========== FACTS ===========~n'),
    forall(kb_fact(Id, F, S), format(' ~w  ~w   (source ~w)~n', [Id, F, S])),
    format('~n=========== RULES ===========~n'),
    forall(rule(Id, S, D, C, T),
           format(' ~w (source ~w): ~w~n     IF   ~w~n     THEN ~w~n', [Id, S, D, C, T])),
    pause_msg.

pause_msg :-
    format('~nPress Enter to return to the menu...'), flush_output,
    read_answer(_).

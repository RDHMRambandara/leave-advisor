% =====================================================================
%  tests.pl  -  TEST CASES (forward + backward chaining)
%  Run:  swipl tests.pl
% =====================================================================
:- ensure_loaded(engine).
:- initialization(run_tests, main).

% case(Id, Description, InputFacts, MustDerive, MustNotDerive)
case(t01, 'Shop&Office, 40h, first year, starts Feb, 6 months done, earns 60000',
     [sector(shop_office), hours_per_week(40), year_of_service(first), start_month(2),
      completed_months(6), monthly_earnings(60000)],
     [weekly_holiday(full_pay), start_quarter(q1), annual_leave_days(14), casual_leave_days(3),
      casual_leave_covers_ill_health(yes), poya_holiday(yes), public_holidays_with_pay(9),
      epf_employee_contribution(4800), epf_employer_contribution(7200), etf_employer_contribution(1800)],
     []).
case(t02, 'First year, starts May (quarter 2)',
     [sector(shop_office), year_of_service(first), start_month(5), completed_months(4)],
     [start_quarter(q2), annual_leave_days(10), casual_leave_days(2)], []).
case(t03, 'First year, starts August (quarter 3)',
     [sector(shop_office), year_of_service(first), start_month(8), completed_months(3)],
     [start_quarter(q3), annual_leave_days(7), casual_leave_days(1)], []).
case(t04, 'First year, starts November (quarter 4), 1 month done -> 0 casual days',
     [sector(shop_office), year_of_service(first), start_month(11), completed_months(1)],
     [start_quarter(q4), annual_leave_days(4), casual_leave_days(0)], []).
case(t05, 'Second year or later, 45h',
     [sector(shop_office), hours_per_week(45), year_of_service(later)],
     [annual_leave_days(14), annual_leave_min_consecutive(7), casual_leave_days(7),
      weekly_holiday(full_pay)], []).
case(t06, 'Only 20 hours per week -> no full-pay weekly holiday rule',
     [sector(shop_office), hours_per_week(20), year_of_service(later)],
     [annual_leave_days(14)], [weekly_holiday(full_pay)]).
case(t07, 'Wages Board employee -> refer to Wages Board, no Shop&Office leave',
     [sector(wages_board), monthly_earnings(40000)],
     [refer_wages_board_decision(yes), epf_employee_contribution(3200)],
     [annual_leave_days(_), casual_leave_days(_), poya_holiday(_)]).
case(t08, 'Maternity, Shop&Office Act, live birth, child under one',
     [female(yes), maternity_law(soea), childbirth(live), child_under_one(yes)],
     [maternity_leave(working_days, 84, 14, 70), feeding_intervals(2)], []).
case(t09, 'Maternity, Shop&Office Act, still birth',
     [female(yes), maternity_law(soea), childbirth(still), child_under_one(no)],
     [maternity_leave(working_days, 42, 14, 28)], [feeding_intervals(_)]).
case(t10, 'Maternity, Maternity Benefits Ordinance, live birth',
     [female(yes), maternity_law(mbo), childbirth(live), child_under_one(yes)],
     [maternity_leave(weeks, 12, 2, 10), feeding_intervals(2)], []).
case(t11, 'Maternity, Maternity Benefits Ordinance, still birth',
     [female(yes), maternity_law(mbo), childbirth(still)],
     [maternity_leave(weeks, 6, 2, 4)], []).
case(t12, 'Not female -> no maternity conclusions',
     [female(no), maternity_law(soea), childbirth(live)],
     [], [maternity_leave(_, _, _, _)]).
case(t13, 'Gratuity: monthly-rated, 20 workmen, 8 years, salary 80000',
     [worker_count(20), completed_years(8), domestic_or_chauffeur(no), noncontrib_pension(no),
      monthly_rated(yes), last_monthly_salary(80000), fraud_termination(no), gratuity_delay_months(0)],
     [gratuity_eligible(yes), gratuity_amount(320000), gratuity_payment_deadline_days(30)],
     [gratuity_forfeitable_to_extent_of_loss(_), gratuity_surcharge_percent(_)]).
case(t14, 'Gratuity: daily-rated, 10 years, daily wage 2000',
     [worker_count(50), completed_years(10), domestic_or_chauffeur(no), noncontrib_pension(no),
      monthly_rated(no), last_daily_wage(2000)],
     [gratuity_eligible(yes), gratuity_amount(280000)], []).
case(t15, 'Gratuity: only 3 completed years -> not eligible',
     [worker_count(30), completed_years(3), domestic_or_chauffeur(no), noncontrib_pension(no)],
     [gratuity_ineligible(less_than_5_completed_years)], [gratuity_eligible(_)]).
case(t16, 'Gratuity: employer has 10 workmen -> not eligible under the Act',
     [worker_count(10), completed_years(9), domestic_or_chauffeur(no), noncontrib_pension(no)],
     [gratuity_ineligible(employer_has_fewer_than_15_workmen)], [gratuity_eligible(_)]).
case(t17, 'Gratuity: domestic servant excluded even with 12 years',
     [worker_count(30), completed_years(12), domestic_or_chauffeur(yes), noncontrib_pension(no)],
     [gratuity_excluded(domestic_or_chauffeur)], [gratuity_eligible(_)]).
case(t18, 'Gratuity: non-contributory pension excluded',
     [worker_count(30), completed_years(12), domestic_or_chauffeur(no), noncontrib_pension(yes)],
     [gratuity_excluded(non_contributory_pension)], [gratuity_eligible(_)]).
case(t19, 'Gratuity: terminated for fraud -> forfeiture rule',
     [worker_count(30), completed_years(6), domestic_or_chauffeur(no), noncontrib_pension(no),
      fraud_termination(yes)],
     [gratuity_eligible(yes), gratuity_forfeitable_to_extent_of_loss(yes)], []).
case(t20, 'Gratuity paid 2 months late -> 15% surcharge',
     [worker_count(30), completed_years(6), domestic_or_chauffeur(no), noncontrib_pension(no),
      gratuity_delay_months(2)],
     [gratuity_eligible(yes), gratuity_surcharge_percent(15)], []).
case(t21, 'Gratuity paid 14 months late -> 30% surcharge',
     [worker_count(30), completed_years(6), domestic_or_chauffeur(no), noncontrib_pension(no),
      gratuity_delay_months(14)],
     [gratuity_surcharge_percent(30)], []).
case(t22, 'Gratuity paid on time (0 months late) -> no surcharge',
     [worker_count(30), completed_years(6), domestic_or_chauffeur(no), noncontrib_pension(no),
      gratuity_delay_months(0)],
     [gratuity_eligible(yes)], [gratuity_surcharge_percent(_)]).

% bcase(Id, Description, InputFacts, Goal, ExpectedInstance | none)
bcase(b01, 'Backward: annual leave, second year+',
      [sector(shop_office), year_of_service(later)],
      annual_leave_days(_), annual_leave_days(14)).
bcase(b02, 'Backward: casual leave, first year, 8 months done',
      [sector(shop_office), year_of_service(first), completed_months(8)],
      casual_leave_days(_), casual_leave_days(4)).
bcase(b03, 'Backward: gratuity amount, monthly-rated',
      [worker_count(20), completed_years(8), domestic_or_chauffeur(no), noncontrib_pension(no),
       monthly_rated(yes), last_monthly_salary(80000)],
      gratuity_amount(_), gratuity_amount(320000)).
bcase(b04, 'Backward: gratuity_eligible fails for 2 years of service',
      [worker_count(20), completed_years(2), domestic_or_chauffeur(no), noncontrib_pension(no)],
      gratuity_eligible(yes), none).
bcase(b05, 'Backward: maternity leave, MBO live birth',
      [female(yes), maternity_law(mbo), childbirth(live)],
      maternity_leave(_, _, _, _), maternity_leave(weeks, 12, 2, 10)).
bcase(b06, 'Backward: ETF contribution on 50000',
      [monthly_earnings(50000)],
      etf_employer_contribution(_), etf_employer_contribution(1500)).

run_tests :-
    nb_setval(noninteractive, true),
    nb_setval(current_rule, none),
    findall(Id, case(Id, _, _, _, _), Ids),
    findall(R, (member(I, Ids), run_case(I, R)), Rs),
    findall(Id, bcase(Id, _, _, _, _), BIds),
    findall(R, (member(I, BIds), run_bcase(I, R)), BRs),
    append(Rs, BRs, All),
    length(All, Total),
    include(==(pass), All, Passed), length(Passed, P),
    format('~n=== ~w / ~w tests passed ===~n', [P, Total]),
    ( P =:= Total -> true ; halt(1) ).

run_case(Id, Result) :-
    case(Id, Desc, Facts, Must, MustNot),
    reset_session,
    forall(member(F, Facts), assertz(known(F))),
    forward_chain,
    findall(E, (member(E, Must), \+ derived(E, _)), Missing),
    findall(A, (member(A, MustNot), derived(A, _)), Unexpected),
    findall(R, derived(_, R), Fired),
    (   Missing == [], Unexpected == [] -> Result = pass, Tag = 'PASS'
    ;   Result = fail, Tag = 'FAIL' ),
    format('~n[~w] ~w  (forward chaining)~n  ~w~n', [Tag, Id, Desc]),
    format('  Expected conclusions: ~w~n', [Must]),
    format('  Rules fired: ~w~n', [Fired]),
    ( Missing \== [] -> format('  MISSING: ~w~n', [Missing]) ; true ),
    ( Unexpected \== [] -> format('  UNEXPECTED: ~w~n', [Unexpected]) ; true ).

run_bcase(Id, Result) :-
    bcase(Id, Desc, Facts, Goal, Expected),
    reset_session,
    forall(member(F, Facts), assertz(known(F))),
    (   Expected == none
    ->  ( \+ bc(Goal, _) -> Result = pass, Tag = 'PASS' ; Result = fail, Tag = 'FAIL' ),
        Actual = 'goal could not be proved'
    ;   (   bc(Goal, Tree), Goal =@= Expected
        ->  Result = pass, Tag = 'PASS', Actual = Goal, term_to_atom(Tree, _)
        ;   Result = fail, Tag = 'FAIL', Actual = 'not proved / different answer' ) ),
    format('~n[~w] ~w  (backward chaining)~n  ~w~n  Goal: ~w~n  Expected: ~w~n  Actual: ~w~n',
           [Tag, Id, Desc, Goal, Expected, Actual]).

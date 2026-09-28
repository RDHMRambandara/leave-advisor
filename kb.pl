% =====================================================================
%  kb.pl  -  KNOWLEDGE BASE
%  Sri Lankan Employee Leave & Statutory Benefits Advisor
%  Every fact and rule below carries a source id (s1..s5), see source/3.
% =====================================================================

:- discontiguous kb_fact/3, rule/5, describe/2, input/3, input_when/2.

% ---------------------------------------------------------------------
% SOURCES
% ---------------------------------------------------------------------
source(s1, 'Dept. of Labour Sri Lanka - Salary/Wages/Leave (Shop & Office Employees Act No. 19 of 1954)', 'https://labourdept.gov.lk/salary-wages-leave/').
source(s2, 'Dept. of Labour Sri Lanka - Child Labour, Night Work & Maternity Benefits', 'https://labourdept.gov.lk/child-labour-night-work-maternity-benefits-2/').
source(s3, 'Payment of Gratuity Act No. 12 of 1983 (full text, Labour Code)', 'https://labourdept.gov.lk/downloads/labour_code/55.pdf').
source(s4, 'Central Bank of Sri Lanka - Employees Provident Fund', 'https://www.cbsl.gov.lk/en/employees-provident-fund').
source(s5, 'Employees Trust Fund Board (ETFB)', 'https://etfb.lk/welcome/').

% ---------------------------------------------------------------------
% DOMAIN FACTS  kb_fact(Id, Fact, Source)
% ---------------------------------------------------------------------
kb_fact(f01, weekly_hours_threshold(28),        s1).
kb_fact(f02, annual_first_year(q1, 14),         s1).
kb_fact(f03, annual_first_year(q2, 10),         s1).
kb_fact(f04, annual_first_year(q3, 7),          s1).
kb_fact(f05, annual_first_year(q4, 4),          s1).
kb_fact(f06, annual_later_year(14),             s1).
kb_fact(f07, min_consecutive_annual(7),         s1).
kb_fact(f08, casual_leave_per_year(7),          s1).
kb_fact(f09, months_per_casual_day(2),          s1).
kb_fact(f10, max_public_holidays(9),            s1).
kb_fact(f11, maternity_soea(live, 84, 14, 70),  s2).
kb_fact(f12, maternity_soea(still, 42, 14, 28), s2).
kb_fact(f13, maternity_mbo(live, 12, 2, 10),    s2).
kb_fact(f14, maternity_mbo(still, 6, 2, 4),     s2).
kb_fact(f15, feeding_intervals_per_day(2),      s2).
kb_fact(f16, epf_rate(employee, 8),             s4).
kb_fact(f17, epf_rate(employer, 12),            s4).
kb_fact(f18, etf_rate(employer, 3),             s5).
kb_fact(f19, gratuity_min_years(5),             s3).
kb_fact(f20, gratuity_min_workers(15),          s3).
kb_fact(f21, gratuity_due_days(30),             s3).
% surcharge(LowerMonthsExclusive, UpperMonthsInclusive, Percent)   (Act s.5(4))
kb_fact(f22, surcharge(0, 1, 10),               s3).
kb_fact(f23, surcharge(1, 3, 15),               s3).
kb_fact(f24, surcharge(3, 6, 20),               s3).
kb_fact(f25, surcharge(6, 12, 25),              s3).
kb_fact(f26, surcharge(12, 9999, 30),           s3).

% ---------------------------------------------------------------------
% RULES  rule(Id, Source, Description, Conditions, Conclusion)
% ---------------------------------------------------------------------
% ---- Leave (Shop & Office Employees Act) ----
rule(r01, s1, 'Weekly holiday with full pay (28+ hours worked)',
     [sector(shop_office), hours_per_week(H), weekly_hours_threshold(T), H >= T],
     weekly_holiday(full_pay)).
rule(r02, s1, 'Employment starting Jan-Mar is in quarter 1',
     [start_month(M), M >= 1, M =< 3], start_quarter(q1)).
rule(r03, s1, 'Employment starting Apr-Jun is in quarter 2',
     [start_month(M), M >= 4, M =< 6], start_quarter(q2)).
rule(r04, s1, 'Employment starting Jul-Sep is in quarter 3',
     [start_month(M), M >= 7, M =< 9], start_quarter(q3)).
rule(r05, s1, 'Employment starting Oct-Dec is in quarter 4',
     [start_month(M), M >= 10, M =< 12], start_quarter(q4)).
rule(r06, s1, 'Annual leave in the first year depends on start quarter',
     [sector(shop_office), year_of_service(first), start_quarter(Q), annual_first_year(Q, D)],
     annual_leave_days(D)).
rule(r07, s1, 'Annual leave from the second year onward',
     [sector(shop_office), year_of_service(later), annual_later_year(D)],
     annual_leave_days(D)).
rule(r08, s1, 'Second-year+ annual leave must include consecutive days',
     [sector(shop_office), year_of_service(later), min_consecutive_annual(C)],
     annual_leave_min_consecutive(C)).
rule(r09, s1, 'Casual leave in the first year: 1 day per 2 completed months',
     [sector(shop_office), year_of_service(first), completed_months(M),
      months_per_casual_day(P), D is M // P],
     casual_leave_days(D)).
rule(r10, s1, 'Casual leave from the second year: 7 days per year',
     [sector(shop_office), year_of_service(later), casual_leave_per_year(D)],
     casual_leave_days(D)).
rule(r11, s1, 'Casual leave may be used for private business, ill health or other reasonable cause',
     [sector(shop_office)], casual_leave_covers_ill_health(yes)).
rule(r12, s1, 'Full Moon Poya day is a holiday',
     [sector(shop_office)], poya_holiday(yes)).
rule(r13, s1, 'Paid public holidays (declared by the Minister, max 9)',
     [sector(shop_office), max_public_holidays(N)], public_holidays_with_pay(N)).
rule(r14, s1, 'Wages Board trades follow their own Wages Board decision for leave',
     [sector(wages_board)], refer_wages_board_decision(yes)).

% ---- Maternity ----
rule(r15, s2, 'Maternity leave, live birth, Shop & Office Act (working days)',
     [female(yes), maternity_law(soea), childbirth(live), maternity_soea(live, T, B, A)],
     maternity_leave(working_days, T, B, A)).
rule(r16, s2, 'Maternity leave, still birth, Shop & Office Act (working days)',
     [female(yes), maternity_law(soea), childbirth(still), maternity_soea(still, T, B, A)],
     maternity_leave(working_days, T, B, A)).
rule(r17, s2, 'Maternity leave, live birth, Maternity Benefits Ordinance (weeks)',
     [female(yes), maternity_law(mbo), childbirth(live), maternity_mbo(live, T, B, A)],
     maternity_leave(weeks, T, B, A)).
rule(r18, s2, 'Maternity leave, still birth, Maternity Benefits Ordinance (weeks)',
     [female(yes), maternity_law(mbo), childbirth(still), maternity_mbo(still, T, B, A)],
     maternity_leave(weeks, T, B, A)).
rule(r19, s2, 'Two feeding intervals per day for a mother of a child under one year',
     [female(yes), child_under_one(yes), feeding_intervals_per_day(N)],
     feeding_intervals(N)).

% ---- EPF / ETF ----
rule(r20, s4, 'Employee EPF contribution is 8% of monthly earnings',
     [monthly_earnings(E), epf_rate(employee, R), A is E * R / 100],
     epf_employee_contribution(A)).
rule(r21, s4, 'Employer EPF contribution is 12% of monthly earnings',
     [monthly_earnings(E), epf_rate(employer, R), A is E * R / 100],
     epf_employer_contribution(A)).
rule(r22, s5, 'Employer ETF contribution is 3% of monthly earnings (not deducted from employee)',
     [monthly_earnings(E), etf_rate(employer, R), A is E * R / 100],
     etf_employer_contribution(A)).

% ---- Gratuity (Payment of Gratuity Act No. 12 of 1983) ----
rule(r23, s3, 'Domestic servants / personal chauffeurs in a private household are excluded (s.7)',
     [domestic_or_chauffeur(yes)], gratuity_excluded(domestic_or_chauffeur)).
rule(r24, s3, 'Workers entitled to a non-contributory pension are excluded (s.7)',
     [noncontrib_pension(yes)], gratuity_excluded(non_contributory_pension)).
rule(r25, s3, 'Eligible: employer has 15+ workmen and worker has 5+ completed years (s.5(1))',
     [worker_count(W), gratuity_min_workers(MW), W >= MW,
      completed_years(Y), gratuity_min_years(MY), Y >= MY,
      not(domestic_or_chauffeur(yes)), not(noncontrib_pension(yes))],
     gratuity_eligible(yes)).
rule(r26, s3, 'Not eligible: employer has fewer than 15 workmen (s.5(1))',
     [worker_count(W), gratuity_min_workers(MW), W < MW],
     gratuity_ineligible(employer_has_fewer_than_15_workmen)).
rule(r27, s3, 'Not eligible: fewer than 5 completed years of service (s.5(1))',
     [completed_years(Y), gratuity_min_years(MY), Y < MY],
     gratuity_ineligible(less_than_5_completed_years)).
rule(r28, s3, 'Monthly-rated: half a month salary per completed year (s.6(2)(a))',
     [gratuity_eligible(yes), monthly_rated(yes), completed_years(Y),
      last_monthly_salary(S), A is S / 2 * Y],
     gratuity_amount(A)).
rule(r29, s3, 'Other workers: 14 days wage per completed year (s.6(2)(b))',
     [gratuity_eligible(yes), monthly_rated(no), completed_years(Y),
      last_daily_wage(W), A is W * 14 * Y],
     gratuity_amount(A)).
rule(r30, s3, 'Gratuity must be paid within 30 days of termination (s.5(1))',
     [gratuity_eligible(yes), gratuity_due_days(D)],
     gratuity_payment_deadline_days(D)).
rule(r31, s3, 'Gratuity is forfeited to the extent of loss caused by fraud/misappropriation/damage (s.13)',
     [gratuity_eligible(yes), fraud_termination(yes)],
     gratuity_forfeitable_to_extent_of_loss(yes)).
rule(r32, s3, 'Surcharge on late payment depends on months of delay (s.5(4))',
     [gratuity_eligible(yes), gratuity_delay_months(M), M > 0,
      surcharge(L, U, P), M > L, M =< U],
     gratuity_surcharge_percent(P)).

% ---------------------------------------------------------------------
% INPUT ATTRIBUTES (facts asked from the user)
% input(Attribute, Type, Question)
% ---------------------------------------------------------------------
input(sector, choice([shop_office, wages_board]),
      'Is the employee covered by the Shop & Office Employees Act (shop_office) or by a Wages Board trade (wages_board)?').
input(hours_per_week, number, 'Hours worked per week, excluding overtime?').
input(year_of_service, choice([first, later]),
      'Is the employee in the FIRST year of employment, or in the second year or later (later)?').
input(start_month, number(1, 12), 'In which month (1-12) did the employment start?').
input(completed_months, number(0, 12), 'How many months of service are completed in the first year (0-12)?').
input(monthly_earnings, number, 'Total monthly earnings in Rs. (used for EPF/ETF)?').
input(female, yesno, 'Is the employee female?').
input(maternity_law, choice([soea, mbo]),
      'Which law covers her maternity leave: Shop & Office Act (soea) or Maternity Benefits Ordinance (mbo)?').
input(childbirth, choice([live, still, none]), 'Childbirth type (live birth / still birth / none)?').
input(child_under_one, yesno, 'Does she have a child under one year of age?').
input(check_gratuity, yesno, 'Do you want a gratuity assessment (employee is leaving / has left)?').
input(worker_count, number, 'How many workmen did the employer employ on any day in the last 12 months?').
input(completed_years, number, 'Completed years of service with this employer?').
input(domestic_or_chauffeur, yesno, 'Is the employee a domestic servant or personal chauffeur in a private household?').
input(noncontrib_pension, yesno, 'Is the employee entitled to a NON-contributory pension?').
input(monthly_rated, yesno, 'Is the employee paid a monthly rate?').
input(last_monthly_salary, number, 'Last drawn monthly salary in Rs. (basic + cost-of-living allowance)?').
input(last_daily_wage, number, 'Last drawn daily wage in Rs.?').
input(fraud_termination, yesno, 'Was the service terminated for fraud, misappropriation or wilful damage?').
input(gratuity_delay_months, number, 'How many months late has the gratuity been paid (0 if not late)?').

% Order in which the forward-chaining mode asks questions
ask_order([sector, hours_per_week, year_of_service, start_month, completed_months,
           monthly_earnings, female, maternity_law, childbirth, child_under_one,
           check_gratuity, worker_count, completed_years, domestic_or_chauffeur,
           noncontrib_pension, monthly_rated, last_monthly_salary, last_daily_wage,
           fraud_termination, gratuity_delay_months]).

% A question is only asked when these earlier answers hold
input_when(hours_per_week,        [sector(shop_office)]).
input_when(year_of_service,       [sector(shop_office)]).
input_when(start_month,           [sector(shop_office), year_of_service(first)]).
input_when(completed_months,      [sector(shop_office), year_of_service(first)]).
input_when(maternity_law,         [female(yes)]).
input_when(childbirth,            [female(yes)]).
input_when(child_under_one,       [female(yes)]).
input_when(worker_count,          [check_gratuity(yes)]).
input_when(completed_years,       [check_gratuity(yes)]).
input_when(domestic_or_chauffeur, [check_gratuity(yes)]).
input_when(noncontrib_pension,    [check_gratuity(yes)]).
input_when(monthly_rated,         [check_gratuity(yes)]).
input_when(last_monthly_salary,   [check_gratuity(yes), monthly_rated(yes)]).
input_when(last_daily_wage,       [check_gratuity(yes), monthly_rated(no)]).
input_when(fraud_termination,     [check_gratuity(yes)]).
input_when(gratuity_delay_months, [check_gratuity(yes)]).

% ---------------------------------------------------------------------
% PLAIN-ENGLISH DESCRIPTIONS OF CONCLUSIONS
% (conclusions without a describe/2 clause are internal helper facts)
% ---------------------------------------------------------------------
money(A, S) :- ( integer(A) -> format(atom(S), '~D', [A]) ; format(atom(S), '~2f', [A]) ).

describe(weekly_holiday(full_pay), 'Weekly holiday: one whole day and one half-day, with full pay.').
describe(annual_leave_days(D), S) :- format(atom(S), 'Annual leave: ~w days with full pay.', [D]).
describe(annual_leave_min_consecutive(C), S) :-
    format(atom(S), 'At least ~w of the annual leave days must be taken consecutively.', [C]).
describe(casual_leave_days(D), S) :-
    format(atom(S), 'Casual leave: up to ~w day(s) with full pay this year.', [D]).
describe(casual_leave_covers_ill_health(yes),
         'Casual leave may be taken for private business, ill health or other reasonable cause.').
describe(poya_holiday(yes), 'Full Moon Poya day is a holiday (no extra day if it falls on a weekly holiday).').
describe(public_holidays_with_pay(N), S) :-
    format(atom(S), 'Up to ~w declared public holidays are allowed with full pay.', [N]).
describe(refer_wages_board_decision(yes),
         'Leave is governed by the relevant Wages Board decision - please refer to it.').
describe(maternity_leave(U, T, B, A), S) :-
    format(atom(S), 'Maternity leave: ~w ~w (~w before + ~w after confinement).', [T, U, B, A]).
describe(feeding_intervals(N), S) :-
    format(atom(S), '~w feeding intervals per day for the nursing mother.', [N]).
describe(epf_employee_contribution(A), S) :-
    money(A, M), format(atom(S), 'Employee EPF contribution (8%): Rs. ~w per month.', [M]).
describe(epf_employer_contribution(A), S) :-
    money(A, M), format(atom(S), 'Employer EPF contribution (12%): Rs. ~w per month.', [M]).
describe(etf_employer_contribution(A), S) :-
    money(A, M), format(atom(S), 'Employer ETF contribution (3%, paid by employer only): Rs. ~w per month.', [M]).
describe(gratuity_excluded(R), S) :-
    format(atom(S), 'Gratuity: NOT payable under the Act - excluded category (~w).', [R]).
describe(gratuity_eligible(yes), 'Gratuity: the employee IS eligible under the Payment of Gratuity Act.').
describe(gratuity_ineligible(R), S) :-
    format(atom(S), 'Gratuity: NOT eligible under the Act (~w).', [R]).
describe(gratuity_amount(A), S) :-
    money(A, M), format(atom(S), 'Gratuity amount: Rs. ~w.', [M]).
describe(gratuity_payment_deadline_days(D), S) :-
    format(atom(S), 'Gratuity must be paid within ~w days of termination.', [D]).
describe(gratuity_forfeitable_to_extent_of_loss(yes),
         'Gratuity may be forfeited to the extent of the loss/damage caused by the employee.').
describe(gratuity_surcharge_percent(P), S) :-
    format(atom(S), 'Late payment: employer owes a surcharge of ~w% of the gratuity.', [P]).

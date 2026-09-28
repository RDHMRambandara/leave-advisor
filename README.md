# Sri Lankan Employee Leave & Statutory Benefits Advisor
A rule-based expert system written in Prolog (SWI-Prolog).
It advises on leave (annual, casual, weekly, Poya, public holidays), maternity leave,
EPF/ETF contributions and gratuity, using rules taken from official Sri Lankan sources
(Department of Labour, Central Bank of Sri Lanka, ETF Board, Payment of Gratuity Act).

## 1. Requirements
- SWI-Prolog 9.x (free): https://www.swi-prolog.org/Download.html
  - Windows: install, and tick "Add swipl to the PATH" during setup.
- No other libraries or dependencies.

## 2. Files
| File | Purpose |
|---|---|
| `kb.pl` | Knowledge base: sources, 26 facts, 32 rules, questions, plain-English descriptions |
| `engine.pl` | Inference engine (forward + backward chaining) and explanation facility |
| `main.pl` | User interface (text menu) |
| `tests.pl` | 28 automated test cases |

## 3. How to run
Open a terminal (Command Prompt / PowerShell / Terminal) in this folder and type:

    swipl main.pl

To run the automated test cases:

    swipl tests.pl

## 4. How to use
Main menu:
1. **Full assessment (forward chaining)** - answer the questions; the system derives every
   applicable entitlement and shows the rules it applied.
2. **Ask one specific question (backward chaining)** - pick a question (e.g. "How much is the
   gratuity?"); the system works backward from that goal, asks only for facts it needs
   (explaining why it asks) and prints a proof tree.
3. **View knowledge base** - lists every source, fact and rule.
0. Exit.

Answer types: `yes`/`no`; numbers; or choose an option by number or name.

## 5. Example (Full assessment)
Inputs: shop_office, 40 hours, first, start month 2, 6 months done, earnings 60000, female yes,
soea, live, child under one yes, gratuity yes, 20 workmen, 8 years, domestic no, pension no,
monthly-rated yes, salary 80000, fraud no, delay 2.

Expected: annual leave 14, casual leave 3, maternity 84 working days, EPF 4,800 / 7,200,
ETF 1,800, gratuity Rs. 320,000, surcharge 15%.

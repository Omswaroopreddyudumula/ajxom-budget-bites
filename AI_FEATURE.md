# Lunch Lens

## Benefit and truthful method label

Lunch Lens is a **local rule-based moving-average estimate**, not a trained or generative model. It helps a user compare a possible next meal cost with their budget. It does not predict current venue prices or guarantee a result. The over-budget confirmation is a separate ordinary validation feature.

## Inputs and method

Use the three most recent saved purchases for the selected Meal whose timestamp is strictly earlier than the selected purchase time. Amounts are integer USD cents. Sort newest timestamp first, then descending stable row ID. The baseline is the most recent earlier price. Mean rounding is nearest cent (integer thirds cannot equal a half). Fewer than three earlier records gives an explicit insufficient-history message. Negative input raises a correction error. Changing the meal/date/history recomputes the estimate.

Meal identity, amount and time are relevant. Student identifiers and sensitive data are not inputs. The three-record window is explainable and responds to recent changes; it can overreact to one-off extras. A median of three is a reasonable robust alternative, but this implementation retains the brief's mean and discloses the demonstrated outlier limitation.

## User control

The activity screen shows amounts, date range, estimate, last-price baseline and method. Not now dismisses it, and Show Lunch Lens restores it. The estimate never fills or saves the actual amount. Only explicit Save records a purchase. Empty/invalid data gets feedback rather than invented confidence. Computation uses local saved rows and works without a network.

## Executed fictional fixture cases

`test/domain/rules_test.dart` exercises all five types. These are reproducible fictional cases, not real student spending. Amounts below are chronological oldest-to-newest. Actual outputs matched the listed expected outputs in the passing automated run.

| ID | Type and input cents | Expected and actual | Baseline | Later fictional reference | Absolute errors helper / baseline |
| --- | --- | --- | --- | --- | --- |
| H1 | Normal 450, 600, 750 | 600 | 750 | 650 | 50 / 100 |
| H2 | Insufficient 450, 600 | No estimate | Not scored | Not applicable | Not scored |
| H3 | Invalid 450, -1, 750 | Correction exception | Not scored | Not applicable | Not scored |
| H4 | Boundary 100, 100, 101 | 100 | 101 | 100 | 0 / 1 |
| H5 | Counterexample 500, 2000, 500 | 1000 | 500 | 500 | 500 / 0 |

On the three valid comparison fixtures, helper MAE is 183.33 cents; baseline MAE is 33.67 cents; n=3. Empty/invalid cases are feedback checks and are not included in that denominator. These designed development cases are not held-out evaluation or evidence of population accuracy. Undergraduates do not require the graduate held-out comparison.

## Decision and limitation

The baseline wins on this tiny deliberately challenging set. Retain the mean for transparent comparison with the approved topic recipe, explicitly exposing its outlier sensitivity and allowing the user to ignore it. A future median comparison should use new cases before claiming improvement. No claim of greater accuracy or causal benefit is made.

Widget tests check no-data explanation and dismissal. Android tests check actual SQLite records, offline-independent local computation and saved input persistence. See `evidence/unit-widget-tests.txt`, Android integration logs and `docs/TEST_RESULTS.md` for the exact scope. A peer usability assessment has not been completed.


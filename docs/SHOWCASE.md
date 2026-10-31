# AjxOm showcase rehearsal

The current format is a detailed slide presentation followed by a live application demonstration. Both members must understand the code and explain their actual work. This plan and the script do not prove that the team recording or submission has happened.

## Speaker order

1. **Om, slides 1–4:** introduce Budget Bites, the chosen prompt, scope and team responsibilities.
2. **A.J., slides 5–10:** explain the original Meal/database/History foundation and the final shared data design. Distinguish original contributions from later integration changes.
3. **Om, slides 11–21:** explain frontend behavior, state and lifecycle, forms, purchase workflow, Lunch Lens, evaluation, tests, integration, future work and GitHub.
4. **Om, slide 22:** hand over to the running application.
5. **A.J., live application:** use [AJs_Demo_Script.md](AJs_Demo_Script.md). Om may operate the emulator while A.J. narrates.
6. **Both:** answer questions about the actual implementation and contributions.

## Timing

The roughly 2,400 visible slide words take about 16–17 minutes at 145 words per minute. Reserve 5–6 minutes for the live app walkthrough and 1–2 minutes for questions. Rehearse and adjust delivery so the complete recording remains within 20–25 minutes. Speak during the app actions rather than reading the entire demo script before operating the app.

## Selected questions and visible evidence

The questions-only document selects I1, I2, A1, A2, D1, D2, T1, T2, R1, R2 and R4. It has at least two from each category and includes the mandatory IDs. Upload that document before recording and include it in each final package.

| Questions | Main evidence |
| --- | --- |
| I1, I2 | Frontend screens, stateless display widgets, stateful form/slider behavior |
| A1, A2 | UI/AppStore/data separation, injection, controller disposal and mounted checks |
| D1, D2 | Meal/PurchaseLog CRUD, restrictions, saved preferences and offline process restart |
| T1, T2 | Final logs, helper cases, actual SQLite checks and duplicate/failed-save protection |
| R1, R2 | Real contribution history, integration decisions and disclosed evidence gaps |
| R4 | Helper inputs, mean/baseline, explanation/dismissal, five cases and outlier limitation |

Keep the selected questions document questions-only. Use the same team recording for the presentation and integrated answers. Verify the actual video link and instructor access. Each member follows the required individual upload steps. The published deadline was October 27, 2026 at 11:59 PM Eastern, so follow any instructor-approved late or extension instructions.

## Evidence boundaries

Use the current source and final-prefixed logs. The two tested emulator profiles share an Android API image. Physical-device testing, independent peer revision and historical board snapshots remain incomplete. The recorded contribution history does not demonstrate the steady twenty-meaningful-commits-per-person target. Describe those limits directly and do not infer completed submissions from prepared files.

# Budget Bites

Project One Flutter Build Studio planning repository for **AjxOm**.

Budget Bites will be an offline lunch notebook connecting a student’s saved meals with correctable purchase history. “Between Classes” is the proposed product name, pending team agreement.

## Status

**Planning only. Instructor-team approval is pending. Do not initialize or implement the Flutter app before approval is confirmed.**

The team has selected the Budget Bites brief and undergraduate scope. The proposal is due October 17, 2026 at 11:59 PM Eastern; the final project is due October 27, 2026 at 11:59 PM Eastern.

## Team

| Member | GitHub | Pathway | Responsibilities |
| --- | --- | --- | --- |
| Om Swaroop Reddy Udumula | Omswaroopreddyudumula | Undergraduate | UI, demo section, documentation |
| Anton “A.J.” Orea | ajorea-lab | Undergraduate | Data layer, testing, documentation |

Course section and group number are pending. Personal student identifiers belong in the required course submission documents, not repository documentation.

## Planned scope

- Five core screens: meal catalog, meal editor, meal detail/activity, purchase history/insights, settings.
- Two related SQLite entities, Meal and PurchaseLog, with validated CRUD for both.
- SharedPreferences for budget and display preferences.
- Start/progress/finish/reset workflow, cuisine filter, purchase total, explicit delete policy and duplicate-save protection.
- Lunch Lens: an explainable local mean of the three most recent earlier purchases, compared with a last-price baseline. Show input history, insufficient-data feedback and user control.
- Offline restart checks on two devices/emulators, test evidence and a peer-tested design revision.

These are plans, not implemented features or completed tests. No APK is available.

## Planning and evidence

- [Execution plan](docs/PLANNING.md)
- ClickUp board URL: pending creation and verified team access.
- Required final evidence path: `Kanban_Contribution_Evidence.pdf` (not yet created).
- Dated board snapshots required: October 17, 20, 23 and 27. 
- Each member maintains at least 20 meaningful commits over time and uses feature branches and reviewed pull requests.

## Approval and access

Record the actual instructor-team approval before development. Proposal completion, signatures, course details, repository access for the instructor and ClickUp evidence are still pending. A collaborator invitation is not evidence that the invitation has been accepted.

## Course references

- [Official project overview](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/index.html)
- [Budget Bites topic brief](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/topics/topic-budget-bites.html)
- [Proposal requirements](https://codd.cs.gsu.edu/~lhenry23/mad/Projects/Project1/ver2/submission/Proposal.html)

Setup instructions, resolved dependencies, schema implementation, test results, user guide, known issues and license will be documented as real work is completed after approval.

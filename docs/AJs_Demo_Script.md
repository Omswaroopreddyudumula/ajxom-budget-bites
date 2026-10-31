# A.J.'s live Budget Bites demo script

**Speaker:** A.J. throughout the application demo. Om can operate the emulator while A.J. reads.

**Presentation split:** Om speaks on slides 1–4 and 14–16, about 4–5 minutes in total. A.J. leads slides 5–13 and 17–28, then narrates the full app demo. Presenter assignment does not change authorship: A.J. credits Om for frontend and integration work.

**Order:** Present all 28 slides first, then switch to the installed Android release app. Aim for about 5–6 minutes for this walkthrough, speaking while performing the actions. Rehearse the combined presentation at a comfortable pace and keep the full recording within the course's 20–25 minutes.

Read the quoted paragraphs. The **Show** lines are operator instructions and are not spoken. These are fictional demonstration amounts, not actual purchases. Keep existing records. Use a new unique demo meal name if “Showcase Lunch” already exists. Do not delete unrelated records.

## 1. Home and the purpose of the app

**Show:** Open Budget Bites. Show Home, the budget value, search, cuisine filter and favorites. Set the budget to $10.00 and light mode before this walkthrough if necessary.

> I will now demonstrate the team's integrated application. Home shows the meal catalog and the current lunch budget. A student can search their own meal notes, choose a cuisine or use the favorites filter. These are local records, and the starter meals are fictional examples. I will use a separate fictional meal so the demonstration does not change unrelated records.

## 2. Create, read and edit a meal

**Show:** Select **Add meal**. Enter **Showcase Lunch**, venue **Fictional demo cafe**, entree **Wrap** at **5.50**, and side **Fruit** at **1.00**. Leave the other price at zero and save. Search for the meal. Open **Edit meal**, change the venue note to **Fictional demo cafe, student menu**, and save.

> This is the reusable meal editor from Om's frontend work. I am entering a name, venue note and estimated item prices. Saving creates a Meal with its own database ID. The two prices produce a six-dollar-fifty-cent catalog estimate. Editing the venue updates the same record rather than creating another meal. This demonstrates the connection between the form and our database CRUD boundary.

## 3. Validate and save an actual purchase

**Show:** Open **View meal**, then **Start plan**. Enter **6.999** in **Actual amount (USD)** and attempt Save to show the decimal-place validation. Correct it to **6.50**, then choose **Save purchase and finish**. Open **History** and select this meal using the meal filter.

> A planned estimate and an actual purchase are separate values. This amount has too many decimal places, so the form asks me to correct it before saving. After I enter six dollars and fifty cents and explicitly save, the app creates a purchase record linked to this meal. History is our purchase log, and its total reflects the selected meal and date filters.

## 4. Read and correct history

**Show:** Select **View receipt**, close it, then **Edit purchase**. Change **6.50** to **6.00** and choose **Save correction**. From History use **Add purchase**, select the same meal and save **4.50**. Add a second purchase of **7.50**. Reselect the meal filter if necessary. The three receipts now total **18.00**.

> The receipt shows the amount saved for a particular purchase. I can correct that amount to six dollars without changing the meal's current estimate. The spending total refreshes after the correction. I have now added two more fictional purchases, four dollars fifty and seven dollars fifty, which gives this meal three receipts totaling eighteen dollars.

## 5. Delete safely and protect relationships

**Show:** Add an extra **1.00** purchase for the same meal. The total becomes **19.00**. Delete that $1.00 receipt and confirm. The total returns to **18.00**. From Home attempt **Delete meal** on Showcase Lunch to show the linked-purchase restriction. Keep the three existing receipts.

> A purchase can also be deleted independently. This confirmation removes only the temporary one-dollar receipt and refreshes the total. The meal still has three linked purchases, so deleting the parent meal produces a restriction message. This protects the relationship between the catalog entry and its receipts. The original backend foundation and the integrated constraints work together here.

## 6. Explain Lunch Lens and reset a draft

**Show:** Open the meal's activity. Show Lunch Lens: earlier amounts **7.50, 4.50, 6.00**, mean **6.00**, last-price baseline **7.50**. Choose **Not now**, then **Show Lunch Lens**. Select **Start plan**, scroll to **Reset draft**, and confirm Reset. Do not save another receipt. Return to History to verify $18.00 remains.

> Lunch Lens now has enough earlier history. Its three amounts average six dollars, while the last-price baseline is seven dollars fifty. The card explains this calculation, and I can dismiss or reopen it. The helper does not enter the actual amount for me. Resetting this unsaved plan also leaves our three saved receipts and eighteen-dollar total unchanged.

## 7. Preferences and an offline restart

**Show:** In Settings move the budget slider from **10.00** to **13.50**, then enable dark mode. Turn on the emulator's airplane mode and explicitly turn Wi-Fi off. Open Android App info for Budget Bites, choose **Force stop** and confirm. Relaunch the app. Show $13.50 and dark mode in Settings. Open History and reselect Showcase Lunch to show three receipts and $18.00.

> Settings saves the budget and display preference locally. I am now turning off networking and restarting the app's process. After relaunch, the budget and dark mode remain saved. The three purchase records and their total are also still available. This demonstrates persistence through the running release app, with SQLite storing the records and SharedPreferences storing the simple settings.

## 8. Close and invite questions

**Show:** Keep History or the helper card visible, then return to the call or recording view.

> This completes the walkthrough of meal management, actual purchase history, the local helper and offline persistence. Thank you for watching. We are ready to answer questions about our individual work and the implementation.

---

## Rehearsal checks, not spoken

- Verify the three receipts really are $6.00, $4.50 and $7.50 before showing the helper. Keep their timestamps earlier than the activity's selected time. Do not promise a fixed receipt ID.
- If other data exists, use the meal filter before citing the $18.00 total. A new installation intentionally has no purchase history.
- On an insufficient-history card, create the three demonstration receipts rather than claiming that an estimate is present.
- For an unlinked meal-delete example, create a separate temporary meal with no receipts, delete it and confirm. Do not remove the meal used for the persistence demonstration.
- If a control needs more time, continue describing the visible state. The steps are a rehearsal plan, not a claim that a new recording has already been completed.
- The earlier three silent emulator clips remain available as backups. This revision uses a live app demo after the slides.

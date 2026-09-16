# Motion and interface design

Cherry Money uses short, purposeful transitions to explain navigation and state changes.

- Page content enters once with a 280 ms fade and 8 px rise. Updating account data does not replay the entrance.
- Onboarding illustrations, titles and progress markers transition in 240 ms.
- Review status changes immediately replace the old accessible status, with a short fade for the new status.
- Approval gives a visible confirmation and a floating message tied to the actual successful action.
- Pending actions display their operation and a small progress indicator. Reduced motion uses a static waiting icon.
- Financial amounts always display the actual value. They never count through invented intermediate balances.
- Review progress derives from the session's transaction counts; it is not a reward or a financial performance score.

Custom motion respects system reduced-motion and accessibility navigation preferences, including preference changes while an entrance is running. Native Apple swipe-back transitions are preserved. No decorative animation runs continuously.

The cash overview uses Cherry's burgundy palette, readable income/outgoing labels and a clearly marked demo balance. Statuses use words and icons as well as colour. Transaction headings stack on narrow screens or with larger text. Demo/live boundaries and purchase gates remain unchanged.

This is interface refinement, not a claim of production banking readiness. Live banking, real extraction and Google OAuth setup remain subject to the integration boundaries in the README.

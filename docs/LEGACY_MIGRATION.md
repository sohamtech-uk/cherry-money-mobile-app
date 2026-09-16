# Migration provenance

This repository now contains only the Flutter application. At the owner's request, the initial import history and preservation branch were removed from active published branches. The new Flutter-only root is `First commit`, authored by `sohamtechuk` with the actual cleanup date. Feature branches use `feat/`; bug fixes use `fix/`.

The source archive records revision `41a45e79ed1b1627749a5500b6965d6ff48b3372`. The original ZIP and upstream mobile repository remain unchanged. A complete pre-cleanup Git bundle is stored outside this repository at `../cherry-money-before-history-cleanup.bundle`. No signing material was imported.

The existing mobile product already had email login, signup with Terms acceptance, password reset and Google sign-in. Flutter reproduces these flows; Google now requires a signed-token-verifying backend. This migration and rewritten repository history do not establish Shipaton eligibility.

App identity: `uk.co.cherrymoney.mobile`. No store release has been submitted by this work.

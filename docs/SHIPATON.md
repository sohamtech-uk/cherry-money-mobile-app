# Shipaton 2026

Cherry Money Mobile demonstrates capture → explainable document matching → exception review → human approval → audit → finance insight, with meaningful RevenueCat gating.

## Eligibility remains unconfirmed

Official rules: https://revenuecat-shipaton-2026.devpost.com/rules
Submission deadline: September 30, 2026, 11:45pm PDT (October 1, 07:45 BST).
The first public mobile release must occur within the contest submission period; updates to previously released apps do not qualify. A Flutter rewrite or new identifier does not by itself prove eligibility. Confirm whether Cherry Invoice/CherryBank has ever been publicly released before claiming this entry is new. The current code is not publicly released.

## RevenueCat

The configured Test Store entitlement is `cherrymoney_pro`. The legacy `pro` identifier remains accepted for compatibility; `business` is reserved for a future tier. Free=3 and Pro=100 capture/approval actions per calendar month on device. Detailed demo cashflow insight is Pro only. The `default` RevenueCat offering supplies monthly, yearly and lifetime Test Store packages. Purchase and restore results update SDK entitlement state; no simulated success. Missing keys leave Free/demo usable. Apple/Google products, signed sandbox purchases and refund/revocation cases still require store setup.

## Existing versus new

Before this work: supplied Angular/Ionic/Capacitor app and separate Cherry backend/web product. Existing mobile store release history is unknown.
During this work: Flutter root project, new application identifier, focused demo workspace, matching/audit/capture/coplan UI, secure API client, RevenueCat abstraction and purchase UI, tests and CI. Do not describe the pre-existing backend as newly built for the contest.

## Release and submission checklist

- [ ] Confirm first-public-release eligibility and store ownership.
- [ ] Complete native tests and fix any failed CI/build checks.
- [x] Configure the RevenueCat Test Store entitlement, products, offering and public development SDK key.
- [ ] Connect Apple/Google products and test a signed native sandbox purchase/restore.
- [ ] Review product's demo-only value; complete live premium workflows before commercial launch.
- [ ] Publish privacy policy, subscription terms, support contact and store data declarations.
- [ ] Configure signing, screenshots, icon assets and Apple IAP capability.
- [ ] Publish an eligible native app, downloadable in the United States, before deadline.
- [ ] Provide live store URL, RevenueCat project ID and judge access/promo codes as required.
- [ ] Record demo video showing actual running features and labelled demo boundaries.
- [ ] Complete Devpost fields and check submitted entry/video links.

**Store publication is not part of this implementation task.** No App Store, Google Play or Devpost submission has been made. TestFlight/internal testing alone does not meet standard contest publication requirements. Public source is not required for ordinary categories; Next Gen has separate rules.

## Demo narrative and screenshots

1. Dashboard: visible Demo data indicator and attention count.
2. Capture sample receipt: preview → clearly synthetic extraction → review transaction.
3. Northstar invoice: inspect amount/date/reference evidence; approve match.
4. Audit timeline: show the human decision and reconciled state.
5. Exceptions: demonstrate amount mismatch/duplicate not silently approved.
6. Ask Cherry: ask what needs attention; identify the structured response.
7. Premium insight: Free routes to upgrade; on configured native build demonstrate store purchase and restore.

Take screenshots of these real screens. Do not claim real AI extraction, live bank connectivity, accounting integration or purchase verification from demo screenshots.

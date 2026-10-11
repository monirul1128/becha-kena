# BKH Business Manager

A mobile-first Flutter demo for the BKH Business Manager reseller and administration workspaces.

## Run

```sh
flutter pub get
flutter run
```

The first screen lets you choose the Reseller or Administrator workspace. Administrators sign in through Firebase Authentication, and only accounts with the trusted `admin: true` custom claim can open the admin workspace. Admin Settings supports a verified email change and a re-authenticated password change. Enable Email/Password in Firebase Authentication and assign the custom claim to the initial admin account from a trusted environment before use. The seeded sample data and OMS state live in memory and reset when the app restarts. Batch targets grow from the previous batch target; the growth result is adjusted to the nearest target that can be divided into consecutive ৳50 increments (for example, ৳500 = ৳50 + ৳100 + ৳150 + ৳200). Batch Management shows each batch calculation and division, while Order Management shows batch assignments, transfers, payments, and settlement state. Withdrawal Requests and Disbursement share one page, and Wallet summarizes payments, withdrawals, current balance, and transaction history. System Reset restores the in-app sample records and settings after confirmation.

Customer and product management include `.xlsx` upload and sample-template download actions alongside their existing Add forms. Replace the example row in the template before uploading. Customer workbooks need `name` and `mobile_number` columns; `address` is optional. Format mobile-number cells as text to preserve leading zeros. Product workbooks need `category`, `title`, and `wholesale_price` columns; `description` is optional. Product categories from imported files are also added to the product category selector. Wholesale prices must be positive multiples of ৳50; retail prices are calculated with the current profit rate. Duplicate customer mobile numbers and product titles are skipped.

**Current scope:** Firebase Authentication protects administrator access and credential changes, but reseller sign-in remains a UI-only demo. Business data is still in memory with no database connection; payment confirmation and disbursement results are not verified provider transactions, and wallet credits are not real funds. System Reset affects only the data held in this app. A production deployment needs authenticated backend APIs, transactional persistence, provider verification/webhooks, and scheduled server-side processing before any real funds are handled.

## Included screens

- **Reseller:** dashboard, order list and details, wallet, withdrawal request, product catalog, notifications, profile, login, and registration.
- **Administrator:** dashboard, customer and product management, reseller management, batch calculations and division, batch-filtered order assignment/transfer/settlement, combined withdrawal and disbursement management, wallet, notifications, and system settings with reset.

Run the unit and UI tests with `flutter test`.

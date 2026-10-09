# BechaKena Hub

A mobile-first Flutter demo for the BechaKena Hub reseller and administration workspaces.

## Run

```sh
flutter pub get
flutter run
```

The first screen lets you choose the Reseller or Administrator workspace. The seeded sample data and OMS state live in memory and reset when the app restarts. The demo supports customer and product entry, reseller activation, price calculation, target division and order assignment, simulated order confirmation and transfer, full-batch settlement, wallet accounting, and withdrawal request/result workflows.

Admin CSV import uses the device file picker and accepts UTF-8 `.csv` files. Customer columns are `name,mobile_number,address`; product columns are `category,title,description,wholesale_price`. Product categories from imported files are also added to the product category selector. Wholesale prices must be positive multiples of ৳50; retail prices are calculated with the current profit rate. Duplicate customer mobile numbers and product titles are skipped.

**Demo only:** the role picker is not authentication or a permission boundary. Payment confirmation and disbursement results are explicitly simulated and are not verified provider transactions; wallet credits are not real funds. There is no database, durable audit log, background batch/transfer scheduler, CSV disbursement download, or payment-provider integration. A production deployment needs authenticated backend APIs, transactional persistence, provider verification/webhooks, and scheduled server-side processing before any real funds are handled.

## Included screens

- **Reseller:** dashboard, order list and details, wallet, withdrawal request, product catalog, notifications, profile, login, and registration.
- **Administrator:** dashboard, customer and product management, reseller management, order management, batch workflow, withdrawal requests, disbursement, wallet, notifications, and system settings.

Run the unit and UI tests with `flutter test`.

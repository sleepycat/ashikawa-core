# Version 0.8

[Release on Github](https://github.com/triAGENS/ashikawa-core/releases/tag/v0.8.0)

**Codename: Timer Koala Sing**

* Support for ArangoDB 1.3
* Dropping support for Ruby 1.8.7
* API changes:
  * `Database#collections` no longer returns system collections, use `Database#system_collections` for that
  * Renamed `Collection#[]` to `Collection#fetch` and introducing a new `Collection#[]` method
* Additions:
  * Support for Auto Increment
* Deprecations:
  * `Collection#<<` (use `Collection#create_document` instead)
  * `Collection#[]=` (use `Collection#replace` instead)
  * `Document#to_hash` (use `Collection#hash` instead)
* Improvements:
  * Introduction of Equality methods and better `inspect` methods via Equalizer
  * Improved error handling for Arango errors
  * MultiJSON was removed
  * Support for Transactions
* Various Bug Fixes, Dependency Updates and Refactorings

*Codename in honor of Federico Viticci, President of Special Business.*

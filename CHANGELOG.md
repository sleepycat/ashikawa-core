# Version 0.9

**Codename: Weramur**

* Support for ArangoDB 1.4
* Dropping support for Ruby 1.9.2
* Additions:
    * Support for multiple databases
    * Create unique indexes
* Performance Improvements:
    * Document creation is faster now
* Deprecations: 
    * `Database#authenticate_with`: Use the initializer block instead
    * Methods deprecated in 0.8 were removed
* Bug Fixes:
    * Getting single attributes via an AQL query works now
* Continuous Integration
    * All specs now also run on a ArangoDB with authentication activated
* A lot of refactoring, more enforced coding guidelines
    * Especially the Specs were heavily refactored
    * Specs are now in the new RSpec Syntax

*Codename in honor of Saor Patrol.*

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

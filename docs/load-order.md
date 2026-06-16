# Load & Seed Order

This document explains how the per-type lookup methods
(`Dictionary.address_city`, `Dictionary.student_school`, ...) come to exist,
and why earlier versions broke depending on **when** models were loaded and
**when** `DictType` rows were written. If you hit a `NoMethodError: undefined
method 'address_city' for class Dictionary`, this is the page to read.

## Background: how lookups are generated

Up to 0.2.x, `Dictionary.address_city` was resolved lazily at call time through
`method_missing`. Every call re-checked `DictType.all_types`, so it never
mattered when the data was seeded — the first call always worked.

From 0.3.0 onward the lookups are **real singleton methods**, generated eagerly
by `Dictionary.reload_dict_methods`, which walks `DictType.all_types` and calls
`define_singleton_method` for each category. This is faster and introspectable
(`Dictionary.respond_to?(:address_city)`), but it means the methods only exist
once generation has actually run for a given model.

Generation is triggered from three places:

1. **Boot** — the Railtie's `config.to_prepare` calls
   `RailsDictionary.load_dict_methods` after the app initializes.
2. **Runtime writes** — `DictType` has `after_save`/`after_destroy
   :delete_all_caches`, which resets the cached type list and calls
   `RailsDictionary.reload_dict_methods`.
3. **Model load** (added in 0.4.0) — when a model runs `acts_as_dictionary`,
   its `included` hook generates its own lookups from current data.

`RailsDictionary.reload_dict_methods` only regenerates methods on models that
have **registered themselves**. A model registers (appends to
`RailsDictionary.dictionary_model_names`) the moment its class body runs
`acts_as_dictionary`. With `config.eager_load = false` (development, test,
console, runner) that does not happen until the constant is first referenced.

## The two moving parts

Method generation needs **both** of these to be true at the moment it runs:

- the dictionary model (`Dictionary`) is **loaded/registered**, and
- the `dict_types` table **exists and contains the rows** you expect.

Every historical bug is some ordering where one of those was not yet true when
the only generation trigger fired, and nothing fired again afterward.

## Scenarios

Each scenario below has an isolated, single-process reproduction under
`spec/load_order/` (the shared rspec suite can't exercise boot ordering because
its tables and models already exist). Run them with `bundle exec rake
load_order`.

### 1. Pre-seeded boot (normal production) — `preseeded_boot.rb`

`dict_types` is migrated and populated **before** the app boots. Seeding via
`insert`/SQL skips callbacks, so trigger #2 never fires. The methods must come
from trigger #1 (boot). Works as long as the model is reachable at
`to_prepare`, which it is under eager loading in production.

### 2. Empty boot, data arrives later — `empty_boot_recovers.rb`

The app boots while `dict_types` does **not exist yet** (e.g. before the first
migration, or during `db:create`). Generation at boot must not raise — it is
guarded by `RailsDictionary.dict_table_ready?`. No methods exist yet. Once the
table is created and a `DictType` is **created** (not bulk-inserted), trigger #2
regenerates and the lookup appears.

### 3. Slave/lookup model loaded after seeding — `lazy_slave_model_boot.rb`

This is the bug that motivated 0.4.0, and the one a host app's
seed/fixture file hits. With lazy loading:

- `DictType` gets referenced and seeded first (`DictType.create!(...)`).
- At that point `Dictionary` has **never been referenced**, so it is not
  registered. Trigger #2 fires but finds an empty model registry and defines
  nothing.
- The host then references `Dictionary` for the first time. Before 0.4.0 the
  `included` hook only registered the model; it did **not** generate methods,
  so `Dictionary.address_city` raised. A *second* call could succeed only if
  some later reload happened to run after registration (e.g. the dev reloader
  re-running `to_prepare`), which is why the failure looked intermittent.

0.4.0 fixes this with trigger #3: the model generates its own lookups in its
`included` hook, so load order between `DictType`, `Dictionary`, and seeding no
longer matters.

### 4. Reverse load order (`Dictionary` before `DictType`)

If the dictionary model loads before the `DictType` constant is defined, trigger
#3 is **skipped** (guarded by `Object.const_defined?(:DictType)`) rather than
raising. Generation then happens at the next boot hook or the next `DictType`
write. The gem's own `spec/init_models.rb` defines `Dictionary` first and
relies on this.

## Guarantees after 0.4.0

- Boot with a missing/unmigrated DB never raises (`dict_table_ready?`).
- A model loaded after its data was seeded gets its lookups immediately on load.
- A model loaded before `DictType` exists defers cleanly and recovers at the
  next boot hook or `DictType` write.
- Runtime `DictType.create!`/`destroy` keeps categories in sync via callbacks.

## If you still see a missing lookup

Force a regeneration and inspect state:

```ruby
RailsDictionary.dictionary_model_names   # is your model registered?
RailsDictionary.dict_table_ready?        # can the table be queried?
DictType.all_types                       # are the categories present?
RailsDictionary.reload_dict_methods      # regenerate now
Dictionary.respond_to?(:address_city)    # => true
```

Bulk seeding (`insert_all`, fixtures, raw SQL) bypasses the `after_save`
callback. If you seed that way after boot, call
`RailsDictionary.reload_dict_methods` yourself afterward.

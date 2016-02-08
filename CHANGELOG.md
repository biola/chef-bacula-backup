bacula-backup Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the bacula-backup cookbook.

v1.10.2 (2016-02-08)
------------------
- Add new `['bacula']['fd']['max_concurrent_jobs']` & `['bacula']['sd']['max_concurrent_jobs']` attributes
  - These will configure the FD & SD `Maximum Concurrent Jobs`

v1.10.1 (2016-02-01)
------------------
- Add new `['bacula']['fd']['file_retention']` & `default['bacula']['fd']['job_retention']` attributes
  - Formerly hardcoded to `30 days` & `6 months` respectively.

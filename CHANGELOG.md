bacula-backup Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the bacula-backup cookbook.

v1.10.1 (2016-02-01)
------------------
- Add new `['bacula']['fd']['file_retention']` & `default['bacula']['fd']['job_retention']` attributes
  - Formerly hardcoded to `30 days` & `6 months` respectively.

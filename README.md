# Account Journal

## Table of Contents

- [Overview](#solution-assumptions)
  - [Solution Assumptions](#solution-assumptions)
  - [Considered extensions](#considered-extensions)
- [Getting started and local development](#getting-started-and-local-development)
  - [Install](#install)
  - [Local Development](#local-development)
  - [How to run](#how-to-run)

## Overview

A simple banking application allowing to collect account and transaction journal information to calculate account closing balances on the daily basis.

The design of the system is following basic accounting concepts of a ledger:
- The is a concept of an account
- Account opening balance is loaded as an credit journal entry (as per basic accounting principles)
- Account balance is always calculated as a sum of its associated ledger items
- By the end of the application run, a closing balance is calculated and produced for each account to be used as an opening balance for the next run

The application is designed an an MVP, hence it is a simple command line application at the time, with a design in mind to extend it to suit further development needs.

### Solution Assumptions

A list of assumptions made around the solution:

- The solution must support an extension to have multiple account owners, however it is unnecessary to build the ownership model from the get go
  - Hence the assumption is that all accounts at this stage will be owned by 1 company only
- If one of the accounts does not meet validation requirements - we still process the rest of the accounts
- If one of the transactions does not meet validation requirements - we will process the rest of the transactions
- For input validation failures - it is sufficient to list them at the end of the application run
- The application is to be designed to run on the manual basis with an idea to be extended to be run automatically/triggered via a UI upload and/or UI forms
- No db is required for the first iteration and a closing account balance output is sufficient 
- Transactions are to be processed in order they appear in the input file
- Can only transact between known accounts (ones we have uploaded opening balances for)
- When an account has multiple opening balance entries, it is appropriate to treat them as multiple continuous to an opening balances 
  - Hence the balance is the sum of opening credits for those accounts
### Considered Extensions

- Treat money as integers to make sure rounding errors do not impact account balance calculations
- use accounts model to support multiple account owners
- Use a different way to input data into the application
- Containerize
- The output formatting is not ideal - making it better would be a good idea


## Getting started and local development

### Install

1. Install ruby 3.2.1 with your choice of ruby manager
  - eg. using [`asdf` ruby plugin](https://github.com/asdf-vm/asdf-ruby)
2. Install bundler by running `gem install bundler` command
3. Install ruby dependencies by running `bundle install` command

### Local Development

To run unit tests, code coverage and rubocop (linting) locally, use `run_specs` script:

```bash
$ ./bin/run_specs
```

Running rubocop locally:

```bash
$ bundle exec rubocop
```

Running unit tests and code coverage locally:

```bash
$ bundle exec rspec
```


## How to run

TODO:
a command line application
when run and receive errors - a manual intervention is required to either:
- validate and fix entry details
- manually validate a failed transfer - details incorrect? etc?

The system can be re-run multiple times if fixes to input files have been provided. The difference - pick the right output file.

./bin/run spec/fixtures/mable_acc_balance.csv spec/fixtures/mable_trans.csv alpha_sales_account_closing_balances.csv

running multiple times will overwrite the closing balance file every time
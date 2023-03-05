# Account Journal Management App

## Table of Contents

- [Project description](#project-description)
  - [Solution assumptions](#solution-assumptions)
  - [Considered extensions](#considered-extensions)
- [Getting started and local development](#getting-started-and-local-development)
  - [Install](#install)
  - [Local development](#local-development)
  - [Running locally](#running-locally)

## Project description

A simple banking application allowing to collect account and transaction journal information to calculate account closing balances on the daily basis.
The system is designed to process those transactions one customer at a time.

The system is designed based off basic accounting concepts:

- There is an account journal in place that tracks all deposits and withdrawals for an account as credits and debits respectively
- Account balance is always calculated as a sum of its associated ledger journal entries
- By the end of the application run, closing balances are calculated and produced for each account with an idea to be used as an opening balance input file for the next run
- Account opening balances are loaded as an credit journal entry (as per basic accounting principles)
  - Note: There is a deliberate choice of avoiding using 'ledger' as a domain concert. This is because 'ledger' implies the presence of explicit logic by definition, eg. ledger balancing, expense management, funds classification, etc. 

The application is designed an an MVP, hence it is a simple command line application, with a design in mind to extend it to suit further development needs.

### Solution assumptions

A list of assumptions made around the solution:

- The solution does not need to support multiple account owners at this time
  - Hence the assumption is that all accounts will be owned by 1 company only for every run
- If one of the accounts does not meet validation requirements - we still process the rest of the accounts
- If one of the transactions does not meet validation or transaction processing requirements - we will process the rest of the transactions
- For input validation failures - it is sufficient to list them at the end of the application run
- The application is to be designed to run on the manual basis with an idea to be extended to be run automatically/triggered via a UI upload and/or UI forms
- No db is required for the first iteration and a closing account balance output is sufficient 
- Transactions are to be processed in order they appear in the input file
- Can only transact between known accounts
  - In this context a known account is an account we have uploaded opening balance for
- When an account has multiple opening balance entries, it is appropriate to treat them as a sum to determine its account balance
### Considered Extensions

- Treat money as integers to make sure rounding errors do not impact account balance calculations
- Use accounts model to support multiple account owners
- Use a different way to input data into the application
- Dockarise the app to ensure it is cross-platform
- The error output formatting is not ideal - making it better would be a good idea
- many many more :) 

## Getting started and local development

### Install

1. Install ruby 3.2.1 with your choice of ruby manager
  - eg. using [`asdf` ruby plugin](https://github.com/asdf-vm/asdf-ruby)
2. Install bundler by running `gem install bundler` command
3. Install ruby dependencies by running `bundle install` command

### Local development

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

### Running locally

This is a simple command line application and hence requires to be run in your terminal.

To run the app locally, use below command:

```bash
$ ./bin/run account_opening_balances_filename transactions_filename (optional)account_closing_balances_filename
```

Tor instance, to run this app against the provided test fixtures (which are checked in for convenience) run the following:

```bash
$ ./bin/run spec/fixtures/mable_acc_balance.csv spec/fixtures/mable_trans.csv alpha_sales_account_closing_balances.csv
```

#### Important notes

- The system can be re-ran multiple times for a given output file - **the output file will be overwritten every run**. 
- Input validation errors will be printed in the console
  - you can fix those in the input file as appropriate and re-run the app
- Transaction processing error will be printed in the console
  - you can fix those in the input file as appropriate and re-run the app

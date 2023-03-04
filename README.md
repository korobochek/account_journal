# Account Journal Service

A simple banking service allowing to collect account and transaction journal information to calculate account closing balances on the daily basis.

## Getting started and Local Development

### Install locally

1. Install ruby 3.2.1 with your choise of ruby manager
  - eg. using [`asdf` ruby plugin](https://github.com/asdf-vm/asdf-ruby)
2. Install bundler by runnning `gem install bundler` command
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


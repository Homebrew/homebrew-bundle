# Contributing

* Fork the project on GitHub.
* Implement your feature addition or bug fix.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
  * Run `rspec` or `rspec spec/{file or functionality you modified}_spec.rb`
  * Ensure 100% code coverage (shown only when running `rspec`)
* Ensure style conformation by running RuboCop with `brew style homebrew/bundle`.
  * This assumes that your tap is your working directory, which is a common practice.
* Add documentation, if necessary, to the `README.md`, to `cmd/brew-bundle.rb`, and elsewhere relevant.
* Commit. Do not alter git history.
* Send a pull request. Bonus points for non-`master` branches.
  * Check CI output for your branch. If the build failed, double check these two common problems:
    * Your PR _must_ pass all existing tests with 100% code coverage.
    * Your PR _must_ pass RuboCop checks.

## Security

Please report security issues to our [HackerOne](https://hackerone.com/homebrew/).

## Code of Conduct

Please note that this project is released with a [Code of Conduct](https://github.com/Homebrew/.github/blob/HEAD/CODE_OF_CONDUCT.md#code-of-conduct). By participating in this project you agree to abide by its terms.

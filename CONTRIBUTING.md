## Contributing
* Fork the project on GitHub.
* Implement your feature addition or bug fix.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
  * Run `rake` or `rspec spec/{file or functionality you modified}_spec.rb`
  * Ensure 100% code coverage, shown only when running `rake`.
* Ensure style conformation by running Rubocop with `brew style homebrew/bundle`.
  * This assumes that your tap is your working directory, which is a common practice.
* Add documentation, if necessary, to the README, to `cmd/brew-bundle.rb`, and elsewhere relevant.
* Commit. Do not mess with `Rakefile`, bump the version, or alter git history.
  * If you want to have your own version, that is fine, but bump version in a commit by itself we can ignore when we pull.
* Send a pull request. Bonus points for topic branches.
  * Check CI output for your branch. If the build failed, double check these two common problems:
    * Your PR _must_ pass all existing tests with 100% code coverage.
    * Your PR _must_ pass Rubocop checks.
  

## Security
Please report security issues to security@brew.sh.

## Code of Conduct

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

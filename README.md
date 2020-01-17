# Redidit

This Reddit pastiche was built as an excercise in developing with Ruby on Rails.

## [Visit the site](https://redidit-zac-tredger.herokuapp.com/)

## Installation
First clone the repo and then install the needed gems (without production):
```
$ cd /path/to/repos
$ git clone https://github.com/HerrHemd/microblogger.git microblogger
$ cd microblogger
$ bundle install --without production
```

Next, migrate the database:
```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:
```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:
```
$ rails server
```

## Roadmap
- Subscribe-able subredidits that appear in feeds
- Update feeds with AJAX

## License

All source code in this app is under the MIT License. See [LICENSE.md](LICENSE.md) for details.

# Redidit

This Reddit pastiche was built as an excercise in developing with Ruby on Rails.

## [Visit the site](https://zac-tredger-redidit.herokuapp.com/)

## Installation
First clone the repo and then install the dependencies:
```
$ cd /path/to/repos
$ git clone https://github.com/ZacTredger/redidit.git redidit
$ cd redidit
$ bundle install --without production
$ yarn install
```

Next, load the schema and initialiaze the dev database with some seed data:
```
$ rails db:setup
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
- Subscribe-able 'subredidits' that appear in feeds
- Post and retrieve comments with AJAX
- Infinite scroll on feeds with AJAX

## License

All source code in this app is under the MIT License. See [LICENSE.md](LICENSE.md) for details.

Randomly assign a person to a high-frequency airbrake error.

```
bundle exec ruby ./bin/air_man
```

Heroku
======
setup production in config/config.yml
```
heroku create xxx
rake heroku:configure
git push heroku
```

### configure scheduler
```
heroku addons:open scheduler
```

add `./bin/air_man` hourly

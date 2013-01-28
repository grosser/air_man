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

# make sure everything is set up correctly
heroku run rake test:email test:store

# send once by hand to verify it works
heroku run bundle exec ruby ./bin/air_man
```

### configure scheduler
```
heroku addons:open scheduler
```

add `heroku run bundle exec ruby ./bin/air_man` hourly

Randomly assign a person to a high-frequency airbrake error, so shit gets fixed.

```
bundle exec rake report
```

Heroku
======
setup production in config/config.yml
```
heroku create xxx
rake heroku:configure # copy config.yml into heroku ENV
git push heroku

# make sure everything is set up correctly
heroku run rake test:email test:store

# send once by hand to verify it works
heroku run bundle exec rake report
```

### configure scheduler
```
heroku addons:open scheduler
```

add `bundle exec rake report` hourly

Monitoring
==========
Setup a [dead man switch](https://deadmanssnitch.com) so you know the cron is still running and then change the cron to:

`bundle exec rake report && curl https://nosnch.in/xxxxx`


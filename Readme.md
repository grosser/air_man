Email notifications for high-frequency Airbrake errors
 - sends email to assignee (should fix it or blame other developer) and all ccs
 - reposts same error only after configured duration
 - sends error summary (details + aggragated backtraces from last 100 notices)

Try locally:
```
cp config{.example,}.yml
# edit config.yml
bundle exec rake report
```

Heroku
======
setup production section in config.yml
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
Setup a [dead man switch](https://deadmanssnitch.com/r/e02191e260) so you know the cron is still running and then change the cron to:

`bundle exec rake report && curl https://nosnch.in/xxxxx`


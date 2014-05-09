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

Mail
====
```
Subject: AirMan: 270.05/hour Faraday::Error::ClientError Invalid certificate

Details at
https://company.airbrake.io/groups/12313123
last retrieved notice: 7 hours ago at 2013-02-15 22:24:58 UTC
last 2 hours:  ▁▁▂▁▂▁▂▁▁▁▁▂▆█▂▂▂▁▁▁▁▂▁▂▁▂▄▄▄▂▂▂▄▄▁▁▂▁▂▁▁▁▆▁▂▁▁▂▁▁▁▂▄▁▁▁▁▁▁▁
last day:      ▇▄█▄▅▃█▁

Trace 1: occurred 123 times e.g. 213131, 234242343, 345345354, 34243, 3242423
Faraday::Error::ClientError Host not found
... backtrace ...

Trace 2: occurred 16 times e.g. 1231231, 2332323, 234243, 324234
Faraday::Error::ClientError Invalid certificate
... different backtrace ...
```

Heroku
======
setup production section in config.yml
```
heroku create xxx
heroku addons:add postmark:10k  # add free email sending
heroku addons:open postmark     # add a signature and put it into config.yml mailer: from
rake heroku:configure           # copies config.yml into heroku ENV
git push heroku

# make sure everything is set up correctly
heroku run rake test:email test:store

# send once by hand to verify it works
heroku run bundle exec rake test:email[your-address@host.com]
heroku run bundle exec rake report
```

### configure scheduler
```
heroku addons:add scheduler
heroku addons:open scheduler
```

add `bundle exec rake report` hourly

Monitoring
==========
 - Setup a [dead man switch](https://deadmanssnitch.com/r/e02191e260) so you know the cron is still running and then change the cron to: `bundle exec rake report && curl https://nosnch.in/xxxxx`
 - Setup a airbrake project to monitor errors in air_man and add `:report_errors_to:` to config.yml

Author
======
[Michael Grosser](http://grosser.it)
michael@grosser.it<br/>
License: MIT

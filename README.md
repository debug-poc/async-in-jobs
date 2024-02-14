# README

The ActiveRecord connection pool has been set to 2 by default

## From Host
* Run `docker compose run app bash` to get a shell in the container

## From the container shell
* Run `./bin/setup`. This sets up the app along with some seed data
* Run `tmux`
* Press `Ctrl-b` then `%` to split the terminal into two panes

### In the first pane
* Open a rails console in one shell `./bin/rails c`
* Run `Site.first.pages.recently_refreshed.count`. It will be 0
* Run `Site.first.enqueue_refresh` to enqueue jobs to refresh pages

###  In the second pane
* Run `bundle exec sidekiq -c 2` to start sidekiq with 2 threads
* 2 jobs will be processed. Each will take around 5 seconds each. The log output shows the AR connection pool stats while executing each async job


### In the rails console
* Run `Site.first.pages.recently_refreshed.count`. It will be 40


## Video
https://share.cleanshot.com/TYVtmTNb

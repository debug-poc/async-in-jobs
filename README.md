# README

The ActiveRecord connection pool has been set to 2 by default

## Models

### Site
* has_many :pages
* has_many :bulk_refreshes

**Key Attributes**
* `concurrent_refresh_limit` - The number of pages that can be refreshed concurrently. Can be adjusted depending on the capacity of the site to handle concurrent requests
* `refresh_interval_in_minutes` - how often the pages should be refreshed. This depends on the SLA/plan

**Key Methods**
* `enqueue_refresh` - Enqueues jobs to refresh pages. The number of jobs depends on the number of pages  to be refreshed, the `PAGES_PER_BULK_REFRESH_JOB` constant and the number of bulk refreshes pending or being processed. The number of jobs is calculated to ensure that the number of pages being refreshed concurrently does not exceed the `concurrent_refresh_limit`. This method should be called periodically for each site


### Sites::Page
* belongs_to :site

### Sites::BulkRefresh

**Key Constants**
* `PAGES_PER_BULK_REFRESH_JOB` - The number of pages that should be refreshed in a single bulk refresh job. Higher number means fewer jobs but higher memory usage.


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

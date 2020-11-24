# Scheduled tasks

You need to configure scheduled tasks in order to properly run your marketplace in production.

Scheduled tasks are tasks that the system needs to run regularly to keep the application working as expected. Operations such as sending mass emails to all users or cleaning up old data from the database are done in scheduled tasks.

## List of required tasks

Here is a list of scheduled tasks you need to configure:

| Purpose | Command | Recommended run interval | Note |
|---------|---------|--------------------------|------|
| Clean up expired sessions | `bundle exec rails runner ActiveSessionsHelper.cleanup` | Once per day | |
| Send daily/weekly marketplace digest emails | `bundle exec rails runner CommunityMailer.deliver_community_updates` | Once per day | |
| Clean up expired auth tokens | `bundle exec rake sharetribe:delete_expired_auth_tokens` | Once per day | |
| Synchronize [Amazon SES](https://aws.amazon.com/ses/) state | `bundle exec rake sharetribe:synchronize_verified_with_ses` | Every 10 minutes | Only if Amazon SES is use |
| Retry and clean PayPal tokens | `bundle exec rake sharetribe:retry_and_clean_paypal_tokens` | Every 10 minutes | Only if PayPal is in use |

## How to configure scheduled tasks

**Heroku** provides an easy to use and free add-on [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) to configure scheduled tasks.

In **Unix servers** `crontab` can be used to configure scheduled tasks

Consult your hosting provider documentation to find out what is the recommended way to configure scheduled tasks.

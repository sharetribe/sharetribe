# The Sharetribe technical roadmap

This document sheds light on the current development plans of the core Sharetribe team. Plans change constantly as new information comes to light. Thus, this document represents a **snapshot of our plans at this point in time**, based on the information that is currently available.

In other words, the purpose of this document is to share the current state of the Sharetribe team's understanding.

To reiterate: the plans shared in this document should not be considered set in stone. They **will** change when relevant information is absorbed by the team.

- [What is currently being worked on](#what-is-currently-being-worked-on)
    - [Discoverability](#discoverability)
    - [A more modular architecture](#steps-towards-a-more-modular-architecture)
- [What is likely to be worked on next](#themes-that-will-likely-be-worked-on-next)
    - [Upgrading the technology stack](#upgrading-the-technology-stack)
    - [A smooth checkout](#a-smooth-checkout)
    - [An API](#an-api)
- [How can I affect these plans?](#how-can-i-affect-these-plans)

## What is currently being worked on
### Discoverability
#### Why

Liquidity is one of the key success factors of marketplaces. Put simply, it means that supply meets demand: sellers can find buyers and buyers can find what they're looking for.

Obviously, achieving liquidity requires that sellers and buyers find the marketplace. Helping with this challenge is something we’ll be working on (stay tuned!). But once at the marketplace, being able to find what you’re looking for is key. This is what discoverability is about: helping buyers find what sellers are offering.

#### What

1. Sharetribe's search will be rebuilt as a separate search component. As a separate component, further improvements to search will be a lot easier than with the current monolithic Ruby on Rails application.
    - Technical details: the search component will be a separate service (built with Clojure) that provides an HTTP API. It is backed by ElasticSearch. Data is populated from the MySQL binlog stream using a custom-built component.
2. The marketplace listing view will be redesigned, improving usability and adding improved search, filtering and sorting options.


### Steps towards a more modular architecture
#### Why

The Sharetribe platform is currently a monolithic Ruby on Rails application. This is mostly due to historical reasons: the original version of Sharetribe was built using Rails, and has evolved together with the project. The monolithic approach has quite a few downsides:

- Functionality is not properly isolated. Making changes to any code can have far-reaching effects.
- Testing is difficult and slow.
- It is very hard to remove or rebuild one aspect of Sharetribe.
- It is hard to identify and fix bottlenecks in the platform. If a certain function requires horizontal scaling, it’s not possible to scale only that part.

The goal is to eventually split up the platform into separate services, each with a defined purpose.

#### How

As certain functions of Sharetribe are improved, if it makes sense, the function will be pulled out of the core application and into a separate service. The search API is an example of this. The move to a service-based platform will thus not happen with a bang, but gradually, over time.


## Themes that will likely be worked on next

These are the plans that currently feel like the best options for what the Sharetribe team should work on next. Improvements listed below might come out in a month, a year, or (unfortunately) never—it all depends what the team learns along the way.

### Upgrading the technology stack
#### Why

The Sharetribe platform is currently running on Rails 3.2, which was released in early 2012. With Rails 5 right around the corner, it's time to spend some time getting rid of this technical debt and taking the latest version of Rails into use. In addition to providing features that help future development, many tools no longer work with Rails 3.2.

### A smooth checkout
#### Why

We've received lots of feedback on how to make purchases easier in Sharetribe marketplaces. Improving the checkout flow will lead to more transactions.

#### What

Some of the areas we might improve:

1. Availability of services and rented items. When you are booking a service, it's important to know what are the available dates or time slots on a certain day, and automatically block the time slots when a purchase is made.
2. Availability of products. When you are buying a product, it's important to know how many of them there are left in stock, and that the stock is automatically reduced when a purchase is made.
3. Reduce the amount of steps required for a successful transaction. This might include skipping registration, making it possible to book instantly without a confirmation from the provider, etc.
4. Completely redesigned checkout pages with improved usability.
5. More payment options.

### An API
#### Why

Sharetribe's user interface is currently intertwined with the core Sharetribe application. Because of this, modifying the user interface is slow and challenging. Additionally, creating another user interface (say, a mobile app) is either impossible or very hard. To solve this, we want to build an API through which all marketplace data can be viewed and manipulated.


## How can I affect these plans?

Talk to us! These plans are formed based on an overall understanding of Sharetribe customer needs and the Sharetribe vision. Feedback can alter either of these, which will then lead to changes in plans. You can either contact us via [email](mailto:support@sharetribe.com), the Sharetribe [idea forum](http://support.sharetribe.com/forums/240322-sharetribe-development-ideas) or our [community forum](https://www.sharetribe.com/community).

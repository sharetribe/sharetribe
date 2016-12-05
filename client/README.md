Please see parent directory [README.md](../README.md).

Building options
==========================
  1. Rails & React with hot reloading styleguide

  ```bash
  foreman start -f Procfile.hot
  ```
    > Currently runs all webpack configs options:
    > - webpack.client.config.js => .js & .css files to be imported in the Rails side
    > - webpack.server.config.js => server-bundle.js to be used if 'prerender: true'
    > - webpack.storybook.config.js => Hot reloading styleguide setup

  1. Rails & React
  ```bash
  foreman start -f Procfile.static
  ```
  > Currently runs build configs options
  > - webpack.client.config.js => .js & .css files to be imported in the Rails side
  > - webpack.server.config.js => server-bundle.js to be used if 'prerender: true'


  1. Creating Assets for Tests
  ```bash
  foreman start -f Procfile.spec
  ```
  > Currently runs build configs options
  > - webpack.client.config.js => .js & .css files to be imported in the Rails side
  > - webpack.server.config.js => server-bundle.js to be used if 'prerender: true'

If you need to debug the Rails parts of Sharetribe with [Pry](https://github.com/pry/pry), it's not possible with Foreman due to a [known compatibility issue](https://github.com/ddollar/foreman/pull/536). In this case we recommend running Rails with old-fashioned `rails server` and React builds with Foreman in a separate terminal. That way your `binding.pry` calls open nicely in the same window with the Rails process. Procfiles `Procfile.client-static` and `Procfile.client-hot` are configured for that, respective descriptions above apply.


Developing new components
==========================

Components are separated based on [Atomic design](http://bradfrost.com/blog/post/atomic-web-design/): _elements_ (aka atoms), _composites_ (aka molecules), and _sections_ (aka organisms).
- **Elements** are React components which are basic visual elements. For example: avatar image.
- **Composites** are combined elements. E.g. ProfileCard combining Avatar and Name atoms could be a composte.
- **Sections** are higher level composites. They are responsible for page sections like html5 tags do. (Think about ```<header>```, ```<footer>```, ```<main>```, ```<aside>```, and ```<section>```)

Later we might add template & page levels too.


You need to register new React components (e.g. "ExampleApp") for react_on_rails gem to recognize it.
```js
ReactOnRails.register({ ExampleApp });
```
Add it to _sharetribe/client/app/startup/clientRegistration.js_ and _serverRegistration.js_. Read more from [react_on_rails repository](https://github.com/shakacode/react_on_rails) and check [their example app](https://github.com/shakacode/react_on_rails/tree/master/spec/dummy).

New React components can be included to HAML and ERB files with '_react_component_':
```erb
<%= react_component("ExampleApp", props: @app_props_server_render, prerender: true, trace: true) %>
```

_webpack.server.config.js_ creates a _server-bundle.js_ file which is used by react_on_rails gem to create server-side rendering.

_webpack.client.config.js_ defines how component specific styles are extracted using ExtractTextPlugin (if you have imported style.css file in your React component). These generated files (_app-bundle.js_, _vendor-bundle.js_, and _app-bundle.css_) and they are saved to _sharetribe/app/assets/webpack_ folder.

For stylesheets, we are using [CSS Modules](https://github.com/css-modules/css-modules) and [PostCSS](https://github.com/postcss/postcss) with [cssnext](http://cssnext.io/).

We use [React Storybook](https://github.com/kadirahq/react-storybook) for a hot reloading component development environment, in `http://localhost:9001/`. See [instructions for writing stories](https://github.com/kadirahq/react-storybook#writing-stories), for example story see [OnboardingTopBar.story.js](app/components/OnboardingTopBar/OnboardingTopBar.story.js).

Publishing styleguide for preview
---------------------------------

Styleguide can be published as a static build, to be used for e.g. reviews by other team members. Running `npm run deploy-storybook` in `client` directory publishes styleguide from your branch to `https://sharetribe.github.io/sharetribe/[BRANCH_NAME]/`.

We're using a [custom fork](https://github.com/mporkola/storybook-deployer) of [Storybook deployer](https://github.com/kadirahq/storybook-deployer), modified to output different branches to different directories. The goal is to get it merged upstream, but it still requires some work.

Using shared Redux store
------------------------

Currently, there are some components that use their own Redux stores. However, when we build more and more React "apps" (i.e. React on Rails registered components) we will soon end up in a situation where these different apps need to communicate with each other. For example, Topbar app has a notification count and when we build a messaging app, the messaging app needs to signal to the Topbar app that user read a message and the notification count should be thus decreased. This can be done with shared Redux stores.

**Usage:**

To add new data to the store, you can either:

* Add new data to `@redux_store_data` variable in the `ApplicationController` if you want to include that data in all page views.
* Add new data to `@redux_store_data` variable in the current controller, if you want to include that data only in the current page.

To use the store in React component, fetch the store in the "App" file. Here's an example:

``` ruby

# my_controller.rb

  ...

  def index
    # Add data to the store
    @redux_store_data.merge!(myData: {myName: "John Doe"})
  end

  ...

```

```haml
-# index.haml

= react_component("MyApp")
```

``` js
// MyApp.js

export default () => {
  const store = ReactOnRails.getStore('SharedReduxStore');
  return r(Provider, { store }, [
    r(MyContainer)
  ]);
};
```

If you want to pass `props` (which is optional, because the component can get it's data also purely from the store):

``` ruby

# my_controller.rb

  ...

  def index
    # Add data to the store
    @redux_store_data.merge!(myData: {myName: "John Doe"})
  end

  ...

```

```haml
-# index.haml

= react_component("MyAppWithProps", props: "My App with props")
```

``` js
// MyAppWithProps.js

export default (props) => {
  const store = ReactOnRails.getStore('SharedReduxStore');
  return r(Provider, { store }, [
    r(MyWithPropsContainer, props)
  ]);
};
```

**Implementation details:**

* **Store name:** `SharedReduxStore`
* In `clientRegistration.js` and `serverRegistration.js` files we register the `SharedReduxStore`
* In `ApplicationController` we initialize the `@redux_store_data` instance variable.
* In the `application.haml` layout file, we render the Redux store with the data in `@redux_store_data`.

Linting JavaScript and CSS files
================================

For static code linting, we use [ESLint](http://eslint.org/) for JavaScript code and [stylelint](http://stylelint.io/) for CSS code. The configuration can be found in `.eslintrc.js` and `.stylelintrc.js`, respectively.

You can run the linting with:

    npm run lint       # run both ESLint and stylelint
    npm run eslint     # run only ESLint
    npm run stylelint  # run only stylelint

# Client-side routes

_This document description how to use routes in the client-side JavaScript code._

## Usage

In the React component, you need to import `Routes` from `utils/routes` module. After that you can use all the named routes that you would use in the Rails-side:

```js
// MyReactComponent.js

import { Routes } from '../../utils/routes';

class MyReactComponent extends Component {
  render() {
    return a({href: Routes.admin_getitng_started_guide_path()}, t("web.getting_started_link"))
  }
}
```

## Parameters

You can give parameters to the route helper function as you would do in Rails:

```js
Routes.person_path({username: "johndoe", show_closed: true})
```

## Cleaning up

`assets:clobber` deletes all the compiled route bundles.

```bash
rake assets:clobber
```

### Gotchas

The locale for the `Routes` module is not yet set when the component file is evaluated:

```js
// BAD!

// MyComponent.js
import { Routes } from '../../utils/routes';

const guideRoot = Routes.admin_getting_started_guide_path();

class MyComponent extends React.Component {
  render() {
    return a(href: guideRoot) // Returns URL, WITHOUT locale!
  }
}
```

```js
// Good!

// MyComponent.js
import { Routes } from '../../utils/routes';

class MyComponent extends React.Component {
  render() {
    const guideRoot = Routes.admin_getting_started_guide_path();
    return a(href: guideRoot) // Returns URL, with locale, as expected.
  }
}
```

## Implementation details

The route bundling is powered by [js-routes](https://github.com/railsware/js-routes) gem. The gem provides two important utilities:

* `rake js:routes` task to export the routes to `.js` bundle
* The JavaScript `_path` helpers

In addition to that, we have implemented a middleware `JsRoutes::Middleware` that watches changes in the `config/routes.rb` file and compiles a new `.js` route bundle when ever that file changes. By default, this happens only in development mode.

### Deployment to production

`rake js:routes` task is configured so that it's always called before `rake assets:precompile`. So no extra steps are needed during the deployment.

# Client-side routes

_This document description how to use routes in the client-side JavaScript code._

## Usage

In the top-level React component, you need to import `subset` function from `utils/routes` module and call that function with the named routes you want to use. After that, you need to pass the newly created route subset object to the children, if they need routes. Note that you can pass default options to the `subset` function.

```js
// App.js
import { subset } from '../utils/routes';

export default (props, marketplaceContext) => {
  const routes = subset([
    'homepage',
  ], { locale: "en" })

  return r(MyComponent, { routes });
};
```

In the component, you then use the routes subset to create the routes you want:

// MyComponent.js

class MyComponent extends React.Component {
  render() {
    return a(href: this.props.root.homepage_path())
  }
}


## Arguments

You can give arguments to the route helper function as you would do in Rails:

```js
Routes.person_path({username: "johndoe", show_closed: true})
```

## Cleaning up

`assets:clobber` deletes all the compiled route bundles.

```bash
rake assets:clobber
```

## Implementation details

The route bundling is powered by [js-routes](https://github.com/railsware/js-routes) gem. The gem provides two important utilities:

* `rake js:routes` task to export the routes to `.js` bundle
* The JavaScript `_path` helpers

In addition to that, we have implemented a middleware `JsRoutes::Middleware` that watches changes in the `config/routes.rb` file and compiles a new `.js` route bundle when ever that file changes. By default, this happens only in development mode.

### Deployment to production

`rake js:routes` task is configured so that it's always called before `rake assets:precompile`. So no extra steps are needed during the deployment.

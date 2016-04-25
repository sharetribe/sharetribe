Please see parent directory [README.md](../README.md).

Building options
==========================
  1. Hot Reloading of Rails Assets

  ```bash
  foreman start -f Procfile.hot
  ```
    > Currently runs all webpack configs options:
    > - webpack.client.rails.build.config.js => .js & .css files to be imported in application.js & applicatio.css on Rails side
    > - webpack.server.rails.build.config.js => server-bundle.js to be used if 'prerender: true'
    > - webpack.client.rails.hot.config.js   => HMR server setup

  1. Static Loading of Rails Assets
  ```bash
  foreman start -f Procfile.static
  ```
  > Currently runs build configs options
  > - webpack.client.rails.build.config.js => .js & .css files to be imported in application.js & applicatio.css on Rails side
  > - webpack.server.rails.build.config.js => server-bundle.js to be used if 'prerender: true'


  1. Creating Assets for Tests
  ```bash
  foreman start -f Procfile.spec
  ```
  > Currently runs build configs options
  > - webpack.client.rails.build.config.js => .js & .css files to be imported in application.js & applicatio.css on Rails side
  > - webpack.server.rails.build.config.js => server-bundle.js to be used if 'prerender: true'



Developing new components
==========================

You need to register new React components (e.g. "ExampleApp") for react_on_rails gem to recognize it.
```js
ReactOnRails.register({ ExampleApp });
```
Add it to _sharetribe/client/app/startup/clientRegistration.jsx_ and _serverRegistration.jsx_. Read more from [react_on_rails repository](https://github.com/shakacode/react_on_rails) and check [their example app](https://github.com/shakacode/react_on_rails/tree/master/spec/dummy).

New React components can be included to HAML and ERB files with '_react_component_':
```erb
<%= react_component("ExampleApp", props: @app_props_server_render, prerender: true, trace: true) %>
```

_webpack.server.rails.build.config.js_ creates a _server-bundle.js_ file which is used by react_on_rails gem to create server-side rendering.

_webpack.client.rails.build.config.js_ defines how component specific styles are extracted using ExtractTextPlugin (if you have imported style.css file in your React component). These generated files (_app-bundle.js_, _vendor-bundle.js_, and _app-bundle.css_) and they are saved to _sharetribe/app/assets/webpack_ folder.

We are using [CSS Modules](https://github.com/css-modules/css-modules) and preprocessors like SASS-loader and [PostCSS](https://github.com/postcss/postcss) loader.
**N.B. we are likely to remove SASS loader quite soon and configure PostCSS better.**

Hot loading works in dev environment (see http://your-marketplace-ident.lvh.me:3000/styleguide), so you should add your components to styleguide too (folder: _sharetribe/app/views/styleguide/_).
Webpack hot loading server is configured by _webpack.client.rails.hot.config.js_ and _server-rails-hot.js_.

ESLint
==========================
The `.eslintrc` file is based on the AirBnb [eslintrc](https://github.com/airbnb/javascript/blob/master/linters/.eslintrc).

It also includes many eslint defaults that the AirBnb eslint does not include.

You can run the linting with:

    npm run eslint

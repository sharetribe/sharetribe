# Client-side translations

_This documentation describes how to use translations in the client-side JavaScript code. The document applied only to the new React based JavaScript code._

_The mechanism described in this document **does not work with marketplace specific translations.**_

## Usage

In the React component, you need to import `t` function from the `i18n` module. After that you can use all the translation keys from the `en.web.*` scope:

```js
// MyReactComponent.js

import { t } from '../../utils/i18n';

class MyReactComponent extends Component {
  render() {
    return span({className: "hello-world"}, t("web.hello_world"))
  }
}
```

The example above assumed that there's a `web.hello_world` key in the translation YML file, e.g.:

```yml

# en.yml

en:
  js:
    hello_world: "Hello JavaScript world!"
```

## Implementation details

### I18n-js

The client-side translations are powered by [i18n-js](https://github.com/fnando/i18n-js/) gem. The gem provides three important utilities:

* `rake i18n:js:export` task to export the translations to `.js` bundle
* `i18n-js` npm package, which helpers for translations, pluralizations, etc.
* `I18n::JS::Middleware` which compiles the `.js` bundle every request in development mode

## Client-side rendering

The translation bundle for all languages is big, so it makes sense to split it per language for client-side rendering purposes. In addition, the translation bundle can be cached because it doesn't change between deploys.

In production mode, you should see two `<script>` tags, one for the language bundle and one for the `application.js` with the fingerprint in the filename:

```html
<script src="https://your_cdn.com/assets/i18n/en-9b9ce41ada0d1b7ad028dda2c64c23d8.js"></script>
<script src="https://your_cdn.com/assets/application-6e9fbeebcaa14c12939b47fab1e53769.js"></script>
```

## Server-side rendering

When doing server-side rendering, the `all.js` file is bundled to the `server.js` bundle. The `utils/i18n.js` file takes care of loading the translation bundle `all.js`.

### Deployment to production

`rake i18n:js:export` task is configured so that it's always called before `rake assets:precompile`. So no extra steps are needed during the deployment.

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

### Fallbacks

Fallbacks use the same fallback mapping as the Rails server.

```yml
# YML
en:
  hello_world: "Hello world!"

fr:
  hello_world: ~
```

```javascript
# JS
I18n.locale = "fr";
I18n.t("hello_world") // => "Hello world!"
```

### Interpolation

```yml
# YML
en:
  click_here: "Click %{this_link} to read more."
  this_link: "this link"
  this_link_alt: "More useful information"
```

```javascript
# JS
I18n.t("click_here", {this_link: a({href: "http://example.com", alt: t("this_link_alt")}, t("this_link"))})
```

### Missing translations

In **development** mode a missing translation message is shown with an easy to notice red background

```javascript
I18n.t("missing_key"); // span({className: "missing-translation", style: {backgroundColor: "red !important"}}, "[missing 'missing_key' translation]";
```

In **production** mode we try to "guess" the translation from the key:

```javascript
I18n.translate("this_key_is_missing"); // => "This key is missing"
```

### Pluralization, date/time localization, number localization etc.

See [i18n-js documentation](https://github.com/fnando/i18n-js)

### Dynamic translation keys

Make sure that you always **type the translation key in its full form.**

```javascript
// BAD!
t("listing_field." + type);

// Good
t("listing_field.dropdown");
```

Sometimes it is convenient to use dynamic keys. In this case, make sure that the full form is written somewhere near (i.e. in the same file at least) the `t` function call:

```javascript
const listing_field = {
  title: "Brand",
  type: "dropdown",
  options: ["Nike", "Adidas", "Puma"],
};

// BAD!
t(listing_field.type);

// Good

const types = {
  checkbox: "listing_field.checkbox"
  dropdown: "listing_field.dropdown",
  number: "listing_field.number",
}

t(types[listing_field.type]);
```

Why? Because of greppability. If we ever decide to remove e.g. the checkbox type and we want to remove the translation for `listing_field.checkbox` we need to be able to search for `listing_field.checkbox` in order to know where it is used.

### Cleaning up

`assets:clobber` deletes all the compiled language bundles.

```bash
rake assets:clobber
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

When doing server-side rendering, the `client/i18n/all.js` file is bundled to the `server.js` bundle. The `utils/i18n.js` file takes care of requiring the `client/i18n/all.js`.

### Deployment to production

`rake i18n:js:export` task is configured so that it's always called before `rake assets:precompile`. So no extra steps are needed during the deployment.

## Troubleshooting

### Server rendered translations are out-of-date

Run `rake i18n:js:export`, wait until new `server-bundle.js` is compiled and refresh the browser.

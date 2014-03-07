# SCSS coding guidelines

## Directory structure

The aim of the defined directory structure is to:

* Split code in smaller modules
* Reduce SASS compilation time

```
app/assets/stylesheets/
|
|-- mixins/                     # Variables, mixins and extend "placeholder selectors" (%)
|   |-- _all.scss               # Rule: Files under this folder can NOT output CSS
|   |-- _customizations.scss
|   |-- _media-queries.scss
|   ...
|
|-- partials                    # CSS definitions that are used across multiple views
|   |-- _grid.scss              # Outputs CSS
|   |-- _map.scss
|   |...
|
|-- views                       # CSS definitions specific to one view
|   |-- _listings.scss
|   |-- _people.scss
|   |...
|
`-- index.scss                  # File that includes all the other SCSS files
                                # Use Sprocket `//= require` instead of `@import` to reduce
                                # compile time
```

Rules:

* Files under `mixins` folder should NEVER output any CSS (i.e. they can contain only variables, mixins etc.)
* Files under `partials` and `views` should NEVER `@import` files under `partials` and `views` (otherwise the CSS is compiled and written to the output twice)
* Files under `partials` and `views` can freely `@import` as many files under `mixins` as they want.
* Never `@import "compass"` instead, import the Compass mixins you need (e.g. `@import "compass/css3/border-radius"`)

Additional reading:

* [How to structure a Sass project](http://thesassway.com/beginner/how-to-structure-a-sass-project)
* [Lightning-Fast Sass Reloading in Rails 3.2](http://blog.55minutes.com/2013/01/lightning-fast-sass-reloading-in-rails-32/)

PS. The structure of SASS files in this project is currently not according to what is written here. However, we're working on it and improving step by step.
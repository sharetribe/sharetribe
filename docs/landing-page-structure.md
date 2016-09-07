# Landing page JSON structure

This section describes the landing page structure JSON format.

## Overview

The structure JSON represents an object with four top-level keys:

* `settings` contains general settings of the landing page, such as locale and marketplace ID
* `page` contains page level settings, e.g. title, meta-tags
* `sections` declares the sections that are used to build up the landing page, such as hero block, info block(s), footer, etc
* `composition` defines which sections and in which order are used to render the actual landing page
* `assets` defined all assets that can be referred to from within the sections

### Linking

Some values in the structure JSON are meant to refer to other objects, either defined in the structure JSON itself (e.g. sections or assets), or defined and interpreted externally (e.g. paths, translations, marketplace information, etc).

A link is represented as a JSON object with keys `type` and `id`. For example, to refer to a `section` with ID `hero` from `composition`, you have:

```json
...
    "composition": [
        {
            "section": {"type": "sections", "id": "hero"}
        },
        ...
    ],
...
```

## Example structure

See the [example JSON structure](../app/services/custom_landing_page/example_data.rb).

## Settings

The following values are set in `settings`:

* `marketplace_id` is the ID of the marketplace (community) in the database
* `locale` is the locale for the landing page
* `sitename` is the name of the landing page as chosen when created

Typically, you would only need to change the `locale` if the marketplace language is changed.

## Page

The following values are set in `page`:

* `twitter_handle` is used to render `twitter:site` and `twitter:creator` `meta` tags. By default this resolves to the `twitter_handle` of the marketplace in the database. Note that the `@` sign is automatically added as prefix, so it should be skipped if you override the `twitter_handle`.
* `twitter_image` is used to render `twitter:image` `meta` tag. Make sure it links to the correct hero image asset id or if you want to use a different asset, you can link to it.
* `facebook_image` is used to render `og:image` `meta` tag. Make sure it links to the correct hero image asset id.
* `title` is the page title. Defaults to marketplace name and slogan.
* `google_site_verification`is the value for meta tag for Google search console verification code. You need to edit the default value to the correct verification code code. If you don't have a google verification code you can remove this line from the structure. 

`page` includes a number of other SEO-related keys. They default to appropriate values for the marketplace, but can be overriden, if desired.

## Sections

Sections generally have several properties that are external links and do not necessarily need to be changed. The few ones that are set directly when editing the landing page are listed for each section kind below.

### Hero

Section `kind` is `hero`.

Values to set:

* `background_image`
* `background_image_variation` sets the amount of dimming applied to the image. Possible values are `dark` (default) and `light`.

Normally, the only keys that you need to modify in a `hero` section are the `background_image`, which links to an asset, and the `background_image_variation`, which sets the amount of darkening applied. For example:

```json
...
"sections": [
    {
        "id": "hero",
        "kind": "hero",
        "background_image": {"type": "assets", "id": "hero_bg"},
        "background_image_variation": "dark",
        ...
    }
]
...
```

All other keys generally link to values that are resolved externally.

The title and subtitle of the hero section default to linking to the corresponding marketplace `slogan` and `description`. You can override those, by replacing the link in the JSON with a JSON object with key `value` and the text as the value. The example below overrides the `description`, while leaving the `title` as the default link to the actual marketplace `slogan`:

```json
"title": {"type": "marketplace_data", "id": "slogan"},
"description": {"value": "Some description"}
```

### Info sections

Section `kind` is `info`.

Section `variation` is either `single_column` or `multi_column`.

#### Single column

Values to set:

* `title`
* `background_image`
* `background_image_variation` - possible values: `light` and `dark` (default)
* `paragraph`
* `button_title`
* `button_path`

#### Multi column

Values to set:

* `title`
* `columns` 2 or 3 columns of:
  * `icon`
  * `title`
  * `paragraph`
  * `button_title`
  * `button_path`

#### Available icons

* `quill`
* `piggy-bank`
* `globe-1`
* `marker-1`
* `marker-2`
* `dollar-bag`
* `hand-globe`
* `connection-2`
* `magnifier`
* `binocular`
* `chart-up`
* `business-chart-2`
* `house-1`
* `garage`
* `bubble-conversation-4`

Ask development team to add more when needed.

### Categories

Section `kind` is `categories`.

No `variation`.

There can be 3-7 categories.

Values to set:

* `categories`: a list of category links (i.e. `{ "type": "category", "id": 123 }`) (notice that the value of the `id` is NOT in quotes (`""`))
* `background_image`: a link to background image

### Featured listings

Section `kind` is `listings`.

No `variation`.

There MUST be 3 listings. Not more, not less.

Values to set:

* `title`
* `paragraph`
* `button_title`
* `button_path`
* `listings` (change the IDs)

### Videos

Section `kind` is `video`.

Available `variation`s:

* `youtube`

Values to set:

* `youtube_video_id`

  For example, if the link to the video is `https://www.youtube.com/watch?v=UffchBUUIoI`, the ID is `UffchBUUIoI`.

* `width`

  Go to the Youtube video, right-click the video and select "Stats for nerds" (yeah, nerds, that's us). If the **Dimensions** is e.g. `1280 x 720`, then `width` is `1280` and `height` is `720`.

* `height`

  See `width`

### Footer

Section `kind` is `footer`.

Values to set:

* `theme` can be either `light` or `dark`
* `links` is an array of internal (links via Rails path helper) or external (hardcoded URL)

  **Internal links** have the form of `{"label": "<link label>", "href": {"type": "path", "id": "<id of the path>"} }`. For example:

  ```json
  {"label": "Contact us!", "href": { "type": "path", "id": "contact_us"} }
  ```

  Available paths are:

  * `contact_us`: links to the marketplace's contact us page
  * `about`: links to the marketplace's about page
  * `search`: links to search page (the old homepage)
  * `signup`: signup page
  * `login`: login page
  * `post_a_new_listing`: post a new listing page
  * `all_categories`: search page with all categories selected
  * `how_to_use`
  * `terms`
  * `privacy`

  If you need to add new path, add the path to the hash that is returned by the `LandingPageController#build_paths` method.

  **External links** have the form of `{"label": "<link label>", "href": {"value": "<hard coded url>"} }`. For example:

  ```json
  {"label": "Blog", "href": {"value": "http://blog.mymarketplace.com"} }
  ```

* `social` is an array of social media links. Edit each `url` to be the correct profile URL for the marketplace.

  Available services are:

  * `facebook`
  * `instagram`
  * `twitter`
  * `youtube`
  * `googleplus`
  * `linkedin`
  * `pinterest`

* `copyright` copyright text

## Composition

The `composition` defines which sections and in what order are used to render the actual landing page. The landing page should have at least a `hero` and a `footer` sections:

```json
...
"composition": [
    {"section": {"type": "sections", "id": "hero"}},
    ...
    {"section": {"type": "sections", "id": "footer"}}
]
...
```

## Assets

`assets` defines the assets that can be referred to from the sections of the landing page. Each asset is described by an `id`, `src` and `content_type`. `id` is the name used to refer to the asset and `src` is the corresponding file name for the asset, as present in the site's assets directory `data/sites/NAME/assets/` and `content_type` should correspond to the file type. For JPEG files, the `content_type` is `image/jpeg` and for PNGs it is `image/png`.

For example, the following defines couple of images as assets:

```json
...
"assets": [
    {
        "id": "example_bg",
        "src": "bg_light.jpg",
        "content_type": "image/jpeg"
    },
    {
        "id": "some_image",
        "src": "some_image.png",
        "content_type": "image/png"
    }
]
...
```

# Landing page

_This is an experimental feature. The setup and configuration of the landing page needs manual code editing. There's no user interface in Admin panel to configure landing page._

This guide will help you to setup and configure landing page. When the landing page is enabled, it will be served to your users from the root URL of your marketplace. The old root search view will be found from `/s` path.

## Enabling landing page

To enable the landing page, change the `clp_static_enabled` to `true`

```yaml
# config.yml

clp_static_enabled: true
```

Run the following rake task to copy the default landing page template
```sh
bundle exec rake sharetribe:landing_page:install_static
```

The landing page template should now be available under `config/initializers/landing_page.rb`

Restart the server and go to the marketplace root URL. You should now see the landing page with the example content.

## Advanced configuration

### Caching

The landing page is heavily cached in order to make it lightning fast. There are two configurations that control caching:

- `clp_cache_time`: The time in seconds how often the cache is invalidated. Default: 900 seconds, i.e. 15 minutes
- `clp_static_released_version`: The current landing page version. The version number acts as a cache buster. The cache is in any case invalidated after `clp_cache_time`, but if you want to invalidate the cache sooner, increase the version number.

The landing page is also cached on the client-side by the browser. A `Cache-Control: max-age=#{clp_cache_time}` header is sent with the request. This makes the browser to cache the page and not even try to fetch the page if the page is cached in browser. That's why users may see the old version, even if the server-side cache is invalidated.

### Images

You can use your own images in several section in the landing page, e.g. hero section background, info section background and category background.

`clp_asset_url` configuration controls where the assets are loaded from.

#### Hosting the images in /public (Recommended)

Hosting the landing page image files in the `/public` directory is the recommended way. In addition to that, it's recommended to configure a CDN service, such as [Amazon CloudFront](https://aws.amazon.com/cloudfront/).

**Example:**

If you save the image files to `/public/landing_page/assets/`, you need to set the `clp_asset_url` configuration to:

```yaml
# config.yml

clp_asset_url: `https://your-cdn-service.com/landing_page/assets/`
```

#### Hosting the images in S3

Change the configuration to match the image location in your S3 bucket:

```yaml
# config.yml

clp_asset_url: `https://yourbucketnamehere.s3.amazonaws.com/landing_page/assets/`
```

Even if you use S3 to host the images, it's recommended to use CDN in front of the S3 bucket.

```yaml
# config.yml

clp_asset_url: `https://your-cdn-service.com/landing_page/assets/`
```

### Fonts

Landing page is designed to be used with Proxima Nova Soft font, which is not freely available. If you want to use Proxima Nova Soft font in the landing page, you need to buy the font.

`font_proximanovasoft_url` configuration controls the path where the font is loaded from.

#### Hosting the font file in /public (Recommended)

Hosting the Proxima Nova Soft font in the `/public` directory is the recommended way to host the font. In addition to that, it's recommended to configure a CDN service, such as [Amazon CloudFront](https://aws.amazon.com/cloudfront/).

**Example:**

If you save the font files to `/public/landing_page/fonts`, then you need to set the `font_proximanovasoft_url` configuration to:

```yaml
# config.yml

font_proximanovasoft_url: `https://your-cdn-service.com/landing_page/fonts/`
```

#### Hosting the font file in S3

Change the configuration to match the font location in your S3 bucket:

```yaml
# config.yml

font_proximanovasoft_url: `https://yourbucketnamehere.s3.amazonaws.com/landing_page/fonts/`
```

Even if you use S3 to host the font file, it's recommended to use CDN in front of the S3 bucket.

```yaml
# config.yml

font_proximanovasoft_url: `https://your-cdn-service.com/landing_page/fonts/`
```

## Modifying landing page content

After you have succesfully enabled and configured the landing page, it's time to edit the landing page content!

The content for the landing page is defined in [CustomLandingPage::ExampleData::DATA_STR](../app/services/custom_landing_page/example_data.rb). This template is copied over to `config/initializers/landing_page.rb` upon running the `sharetribe:landing_pages:install_static` task. To modify the landing page content, you should modify the initializer.

See [Landing page JSON structure](landing-page-structure.md) for documentation about the landing page data structure format.

When you modify the landing page, use the preview URL (http://lvh.me:3000/_lp_preview) instead of the root URL (http://lvh.me:3000). The root URL sends the `Cache-Control` header and thus you may not see your modifications immediately in the root URL.

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Add folder with webpack generated assets to assets.paths
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "webpack")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

Rails.application.config.assets.precompile += %w(
  server-bundle.js
  application.js
  application_reactpage.js
  application.css
  react_page/styles.css
  design.css
  email-v2.css
  admin2/admin.js
  admin2/admin.scss
  popper.min.js
  bootstrap.min.js
)

if Rails.env == 'test'
  Rails.application.config.assets.precompile += %w(test/timecop)
end

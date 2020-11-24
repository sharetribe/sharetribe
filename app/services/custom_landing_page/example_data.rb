module CustomLandingPage
  # rubocop:disable Metrics/ModuleLength
  module ExampleData

    # TODO Document the expected JSON structure here

    DATA_STR = <<JSON
{
  "settings": {
    "marketplace_id": 9999,
    "locale": "en",
    "sitename": "example"
  },

  "page": {
    "twitter_handle": {"type": "marketplace_data", "id": "twitter_handle"},
    "twitter_image": {"type": "assets", "id": "default_hero_background"},
    "facebook_image": {"type": "assets", "id": "default_hero_background"},
    "title": {"type": "marketplace_data", "id": "page_title"},
    "description": {"type": "marketplace_data", "id": "description"},
    "publisher": {"type": "marketplace_data", "id": "name"},
    "copyright": {"type": "marketplace_data", "id": "name"},
    "facebook_site_name": {"type": "marketplace_data", "id": "name"},
    "google_site_verification": {"value": "CHANGEME"}
  },

  "sections": [
    {
      "id": "hero",
      "kind": "hero",
      "variation": {"type": "marketplace_data", "id": "search_type"},
      "title": {"type": "marketplace_data", "id": "slogan"},
      "subtitle": {"type": "marketplace_data", "id": "description"},
      "background_image": {"type": "assets", "id": "default_hero_background"},
      "background_image_variation": "dark",
      "search_button": {"type": "translation", "id": "search_button"},
      "search_path": {"type": "path", "id": "search"},
      "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
      "search_location_with_keyword_placeholder": {"type": "marketplace_data", "id": "search_location_with_keyword_placeholder"},
      "signup_path": {"type": "path", "id": "signup"},
      "signup_button": {"type": "translation", "id": "signup_button"},
      "search_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "search_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "signup_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "signup_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"}
    },
    {
      "id": "video",
      "kind": "video",
      "variation": "youtube",
      "youtube_video_id": "UffchBUUIoI",
      "width": "1280",
      "height": "720",
      "text": "Video section can contain one Youtube video. Click to watch!"
    },
    {
      "id": "single_info_without_background_and_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section without background image and call to action button",
      "paragraph": "This is a single column info section without background image and call to action button."
    },
    {
      "id": "markdown_support",
      "kind": "info",
      "variation": "single_column",
      "title": "Limited Markdown support",
      "paragraph": "Text paragraphs can contain Markdown markup. Limited subset of Markdown syntax blocks are allowed. Allowed blocks are *italic*, **bold**, ***bold+italic***, ~~strike through~~, _underline_ and [links](https://www.sharetribe.com).  \\nLine breaks and...\\n\\n...new paragraphs are also supported"
    },
    {
      "id": "single_info_without_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section without call to action button",
      "paragraph": "This is a single column info section without background image and call to action button.",
      "background_image": {"type": "assets", "id": "default_hero_background"}
    },
    {
      "id": "single_info_with_background_and_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section with background image and call to action button",
      "paragraph": "This is a single column info section with background image and call to action button.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Go to sharetribe.com",
      "button_path": {"value": "https://www.sharetribe.com"},
      "background_image": {"type": "assets", "id": "default_hero_background"},
      "background_image_variation": "dark"
    },
    {
      "id": "single_info_with_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section with call to action button",
      "paragraph": "This is a single column info section with call to action button.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Contact us",
      "button_path": {"type": "path", "id": "contact_us"}
    },
    {
      "id": "single_info_with_background_color_and_cta",
      "kind": "info",
      "variation": "single_column",
      "title": "Single column info section with background color and call to action button",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "About",
      "button_path": {"type": "path", "id" :"about"},
      "background_color": [166, 76, 94]
    },
    {
      "id": "two_column_info_with_icons_and_buttons",
      "kind": "info",
      "variation": "multi_column",
      "title": "Two column info section with icons and buttons",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "grape",
          "title": "Column 1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.\\n\\nParagraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Go to sharetribe.com",
          "button_path": {"value": "https://www.sharetribe.com"}
        },
        {
          "icon": "watering-can",
          "title": "Column 2",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Go to sharetribe.com",
          "button_path": {"value": "https://www.sharetribe.com"}
        }
      ]
    },
    {
      "id": "two_column_info_without_icons_and_buttons",
      "kind": "info",
      "variation": "multi_column",
      "title": "Two column info section without icons and buttons",
      "columns": [
        {
          "title": "Column 1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.\\n\\nParagraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 2",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "three_column_info_with_icons_and_buttons",
      "kind": "info",
      "variation": "multi_column",
      "title": "Three column info with icons and buttons",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Column 1",
          "icon": "quill",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Go to sharetribe.com",
          "button_path": {"value": "https://www.sharetribe.com"}
        },
        {
          "title": "Column 2",
          "icon": "piggy-bank",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Go to sharetribe.com",
          "button_path": {"value": "https://www.sharetribe.com"}
        },
        {
          "title": "Column 3",
          "icon": "globe-1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Go to sharetribe.com",
          "button_path": {"value": "https://www.sharetribe.com"}
        }
      ]
    },
    {
      "id": "three_column_info_without_icons_and_buttons",
      "kind": "info",
      "variation": "multi_column",
      "title": "Three column info without icons and buttons",
      "columns": [
        {
          "title": "Column 1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 2",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 3",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "two_column_info_without_icons_and_buttons_with_sigle_button",
      "kind": "info",
      "variation": "multi_column",
      "title": "Two column info section without icons and buttons",
      "columns": [
        {
          "title": "Column 1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.\\n\\nParagraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 2",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ],
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Contact us",
      "button_path": {"type": "path", "id": "contact_us"}
    },
    {
      "id": "three_column_info_without_icons_and_buttons_with_sigle_button",
      "kind": "info",
      "variation": "multi_column",
      "title": "Three column info without icons and buttons",
      "columns": [
        {
          "title": "Column 1",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 2",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Column 3",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ],
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Contact us",
      "button_path": {"type": "path", "id": "contact_us"}
    },
    {
        "id": "categories",
        "kind": "categories",
        "title": "Categories section",
        "paragraph": "PLEASE NOTE: This section is NOT ENABLED by default. To enable this section, replace category IDs with real IDs and add the section to the 'composition'. Categories section can contain 3 to 7 featured categories. Each category should have a background image.",
        "button_color": {"type": "marketplace_data", "id": "primary_color"},
        "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
        "button_title": "All categories",
        "button_path": {"type": "path", "id": "all_categories"},
        "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
        "categories": [
            {
                "category": { "type": "category", "id": 99999 },
                "background_image": {"type": "assets", "id": "default_hero_background"}
            },
            {
                "category": { "type": "category", "id": 99999 },
                "background_image": {"type": "assets", "id": "default_hero_background"}
            },
            {
                "category": { "type": "category", "id": 99999 },
                "background_image": {"type": "assets", "id": "default_hero_background"}
            }
        ]
    },
    {
        "id": "listings",
        "kind": "listings",
        "title": "Featured listings section",
        "paragraph": "PLEASE NOTE: This section is NOT ENABLED by default. To enable this section, replace listing IDs with real IDs and add the section to the 'composition'. This section contains 3 featured listings",
        "button_color": {"type": "marketplace_data", "id": "primary_color"},
        "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
        "button_title": "Browse all listings",
        "button_path": {"type": "path", "id": "search"},
        "price_color": {"type": "marketplace_data", "id": "primary_color"},
        "no_listing_image_background_color": {"type": "marketplace_data", "id": "primary_color"},
        "no_listing_image_text": {"type": "translation", "id": "no_listing_image"},
        "author_name_color_hover": {"type": "marketplace_data", "id": "primary_color"},
        "listings": [
            {
                "listing": { "type": "listing", "id": 99999 }
            },
            {
                "listing": { "type": "listing", "id": 99999 }
            },
            {
                "listing": { "type": "listing", "id": 99999 }
            }
        ]
    },
    {
        "id": "locations",
        "kind": "locations",
        "title": "Locations section",
        "paragraph": "PLEASE NOTE: This section is NOT ENABLED by default. To enable this section add the section to the 'composition'. Locations section can contain 3 to 7 featured locations. Each location should have a background image.",
        "location_color_hover": {"type": "marketplace_data", "id": "primary_color"},
        "button_color": {"type": "marketplace_data", "id": "primary_color"},
        "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
        "button_title": "Browse all listings",
        "button_path": {"type": "path", "id": "search"},
        "locations": [
            {
                "title": "About",
                "location": { "type": "path", "id": "about" },
                "background_image": {"type": "assets", "id": "default_hero_background"}
            },
            {
                "title": "Contact Us",
                "location": { "type": "path", "id": "contact_us" },
                "background_image": {"type": "assets", "id": "default_hero_background"}
            },
            {
                "location": "https://bagshare.wordpress.com/",
                "background_image": {"type": "assets", "id": "default_hero_background"}
            }
        ]
    },
    {
      "id": "footer",
      "kind": "footer",
      "theme": "dark",
      "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "social_media_icon_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "links": [
        {"label": "About", "href": {"type": "path", "id": "about"}},
        {"label": "Contact us", "href": {"type": "path", "id": "contact_us"}},
        {"label": "How to use?", "href": {"type": "path", "id": "how_to_use"}},
        {"label": "Terms", "href": {"type": "path", "id": "terms"}},
        {"label": "Privary", "href": {"type": "path", "id": "privacy"}},
        {"label": "Invite new members", "href": {"type": "path", "id": "new_invitation"}},
        {"label": "Sharetribe", "href": {"value": "https://www.sharetribe.com"}}
      ],
      "social": [
        {"service": "facebook", "url": "https://www.facebook.com/Sharetribe/"},
        {"service": "twitter", "url": "https://twitter.com/sharetribe"},
        {"service": "instagram", "url": "https://www.instagram.com/"},
        {"service": "youtube", "url": "https://www.youtube.com/channel/UCtefWVq2uu4pHXaIsHlBFnw"},
        {"service": "googleplus", "url": "https://plus.google.com/114869130265262677354/"},
        {"service": "linkedin", "url": "https://www.linkedin.com/company/2626583"},
        {"service": "pinterest", "url": "https://www.pinterest.com/"},
        {"service": "soundcloud", "url": "https://soundcloud.com/"}
      ],
      "copyright": "Copyright Marketplace Ltd 2016"
    }
  ],

  "composition": [
    { "section": {"type": "sections", "id": "hero"}},
    { "section": {"type": "sections", "id": "markdown_support"}},
    { "section": {"type": "sections", "id": "single_info_without_background_and_cta"}},
    { "section": {"type": "sections", "id": "single_info_without_cta"}},
    { "section": {"type": "sections", "id": "single_info_with_cta"}},
    { "section": {"type": "sections", "id": "single_info_with_background_and_cta"}},
    { "section": {"type": "sections", "id": "single_info_with_background_color_and_cta"}},
    { "section": {"type": "sections", "id": "two_column_info_with_icons_and_buttons"}},
    { "section": {"type": "sections", "id": "two_column_info_without_icons_and_buttons"}},
    { "section": {"type": "sections", "id": "three_column_info_with_icons_and_buttons"}},
    { "section": {"type": "sections", "id": "three_column_info_without_icons_and_buttons"}},
    { "section": {"type": "sections", "id": "video"}},
    { "section": {"type": "sections", "id": "footer"}}
  ],

  "assets": [
    { "id": "default_hero_background", "src": "default_hero_background.jpg", "content_type": "image/jpeg" }
  ]
}
JSON

    TEMPLATE_STR = <<JSON
{
    "settings": {
        "marketplace_id": 1234,
        "locale": "en",
        "sitename": "example-com"
    },
    "page": {
      "twitter_handle": {"value": "@CHANGEME"},
      "twitter_image": {"type": "assets", "id": "hero_background_image"},
      "facebook_image": {"type": "assets", "id": "hero_background_image"},
      "title": {"type": "marketplace_data", "id": "page_title"},
      "description": {"type": "marketplace_data", "id": "description"},
      "publisher": {"type": "marketplace_data", "id": "name"},
      "copyright": {"type": "marketplace_data", "id": "name"},
      "facebook_site_name": {"type": "marketplace_data", "id": "name"},
      "google_site_verification": {"value": "CHANGEME"}
    },
    "sections": [
        {
            "id": "hero",
            "kind": "hero",
            "variation": {"type": "marketplace_data", "id": "search_type"},
            "title": {"type": "marketplace_data", "id": "slogan"},
            "subtitle": {"type": "marketplace_data", "id": "description"},
            "background_image": {"type": "assets", "id": "hero_background_image"},
            "background_image_variation": "dark",
            "search_button": {"type": "translation", "id": "search_button"},
            "search_path": {"type": "path", "id": "search"},
            "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
            "search_location_with_keyword_placeholder": {"type": "marketplace_data", "id": "search_location_with_keyword_placeholder"},
            "signup_path": {"type": "path", "id": "signup"},
            "signup_button": {"type": "translation", "id": "signup_button"},
            "search_button_color": {"type": "marketplace_data", "id": "primary_color"},
            "search_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "signup_button_color": {"type": "marketplace_data", "id": "primary_color"},
            "signup_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"}
        },
        {
            "id": "info-1-column",
            "kind": "info",
            "variation": "single_column",
            "title": "Section title goes here",
            "background_image": {"type": "assets", "id": "info_background_image"},
            "paragraph": "Section text goes here",
            "button_color": {"type": "marketplace_data", "id": "primary_color"},
            "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "button_title": "Button title",
            "button_path": {"type": "path", "id": "about"}
        },
        {
            "id": "info-2-columns",
            "kind": "info",
            "variation": "multi_column",
            "title": "Section title goes here",
            "button_color": {"type": "marketplace_data", "id": "primary_color"},
            "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "icon_color": {"type": "marketplace_data", "id": "primary_color"},
            "columns": [
                {
                    "icon": "piggy-bank",
                    "title": "Column title goes here",
                    "paragraph": "Column text goes here",
                    "button_title": "Button title",
                    "button_path": {"type": "path", "id": "about"}
                },
                {
                    "icon": "piggy-bank",
                    "title": "Column title goes here",
                    "paragraph": "Column text goes here",
                    "button_title": "Button title",
                    "button_path": {"type": "path", "id": "about"}
                }
            ]
        },
        {
            "id": "info-3-columns",
            "kind": "info",
            "variation": "multi_column",
            "title": "Section title goes here",
            "button_color": {"type": "marketplace_data", "id": "primary_color"},
            "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "icon_color": {"type": "marketplace_data", "id": "primary_color"},
            "columns": [
                {
                    "icon": "piggy-bank",
                    "title": "Column title goes here",
                    "paragraph": "Column text goes here",
                    "button_title": "Button title",
                    "button_path": {"type": "path", "id": "about"}
                },
                {
                    "icon": "piggy-bank",
                    "title": "Column title goes here",
                    "paragraph": "Column text goes here",
                    "button_title": "Button title",
                    "button_path": {"type": "path", "id": "about"}
                },
                {
                    "icon": "piggy-bank",
                    "title": "Column title goes here",
                    "paragraph": "Column text goes here",
                    "button_title": "Button title",
                    "button_path": {"type": "path", "id": "about"}
                }
            ]
        },
        {
            "id": "categories",
            "kind": "categories",
            "title": "Section title goes here",
            "paragraph": "Section paragraph goes here",
            "button_color": {"type": "marketplace_data", "id": "primary_color"},
            "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "button_title": "Section link",
            "button_path": {"value": "https://google.com"},
            "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
            "categories": [
                {
                    "category": { "type": "category", "id": 1 },
                    "background_image": {"type": "assets", "id": "category1_background_image"}
                },
                {
                    "category": { "type": "category", "id": 2 },
                    "background_image": {"type": "assets", "id": "category2_background_image"}
                },
                {
                    "category": { "type": "category", "id": 3 },
                    "background_image": {"type": "assets", "id": "category3_background_image"}
                }
            ]
        },
        {
            "id": "listings",
            "kind": "listings",
            "title": "Section title goes here",
            "paragraph": "Section paragraph goes here",
            "button_color": {"type": "marketplace_data", "id": "primary_color"},
            "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "button_title": "Section link",
            "button_path": {"value": "https://google.com"},
            "price_color": {"type": "marketplace_data", "id": "primary_color"},
            "no_listing_image_background_color": {"type": "marketplace_data", "id": "primary_color"},
            "no_listing_image_text": {"type": "translation", "id": "no_listing_image"},
            "author_name_color_hover": {"type": "marketplace_data", "id": "primary_color"},
            "listings": [
                {
                    "listing": { "type": "listing", "id": 99999 }
                },
                {
                    "listing": { "type": "listing", "id": 99999 }
                },
                {
                    "listing": { "type": "listing", "id": 99999 }
                }
            ]
        },
        {
            "id": "video",
            "kind": "video",
            "variation": "youtube",
            "youtube_video_id": "UffchBUUIoI",
            "width": "1280",
            "height": "720"
        },
        {
            "id": "footer",
            "kind": "footer",
            "theme": "dark",
            "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
            "social_media_icon_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
            "links": [
                {"label": "About", "href": {"type": "path", "id": "about"}},
                {"label": "Example Link", "href": {"value": "https://www.sharetribe.com"}},
                {"label": "Invite new members", "href": {"type": "path", "id": "new_invitation"}},
                {"label": "Contact us", "href": {"type": "path", "id": "contact_us"}}
            ],
            "social": [
                {"service": "facebook", "url": "https://www.facebook.com/CHANGEME"},
                {"service": "twitter", "url": "https://www.twitter.com/CHANGEME"},
                {"service": "instagram", "url": "https://www.instagram.com/CHANGEME"}
            ],
            "copyright": "This website is powered by Sharetribe marketplace platform."
        }
    ],
    "composition": [
        { "section": {"type": "sections", "id": "hero"}},
        { "section": {"type": "sections", "id": "info-1-column"}},
        { "section": {"type": "sections", "id": "info-2-columns"}},
        { "section": {"type": "sections", "id": "info-3-columns"}},
        { "section": {"type": "sections", "id": "categories"}},
        { "section": {"type": "sections", "id": "listings"}},
        { "section": {"type": "sections", "id": "footer"}}
    ],
    "assets": [
        {"id": "hero_background_image", "src": "example_bg_lighter.jpg", "content_type": "image/jpeg"},
        {"id": "info_background_image", "src": "example_bg_lighter.jpg", "content_type": "image/jpeg"},
        {"id": "category1_background_image", "src": "example_bg_lighter.jpg", "content_type": "image/jpeg"},
        {"id": "category2_background_image", "src": "example_bg_lighter.jpg", "content_type": "image/jpeg"},
        {"id": "category3_background_image", "src": "example_bg_lighter.jpg", "content_type": "image/jpeg"}
    ]
}

JSON

  end
  # rubocop:enable Metrics/ModuleLength
end

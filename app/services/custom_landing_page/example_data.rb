# rubocop:disable ModuleLength

module CustomLandingPage
  module ExampleData

    # TODO Document the expected JSON structure here

    DATA_STR = <<JSON
{
  "settings": {
    "marketplace_id": 9999,
    "locale": "en",
    "sitename": "turbobikes"
  },

  "page": {
    "twitter_handle": {"value": "@CHANGEME"},
    "twitter_image": {"type": "assets", "id": "hero_background_image"},
    "facebook_image": {"type": "assets", "id": "hero_background_image"},
    "title": {"type": "marketplace_data", "id": "page_title"},
    "description": {"type": "marketplace_data", "id": "description"},
    "publisher": {"type": "marketplace_data", "id": "name"},
    "copyright": {"type": "marketplace_data", "id": "name"},
    "facebook_site_name": {"type": "marketplace_data", "id": "name"}
  },

  "sections": [
    {
      "id": "myhero1",
      "kind": "hero",
      "variation": {"type": "marketplace_data", "id": "search_type"},
      "title": {"type": "marketplace_data", "id": "slogan"},
      "subtitle": {"type": "marketplace_data", "id": "description"},
      "background_image": {"type": "assets", "id": "myheroimage"},
      "search_button": {"type": "translation", "id": "search_button"},
      "search_path": {"type": "path", "id": "search"},
      "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
      "signup_path": {"type": "path", "id": "signup"},
      "signup_button": {"type": "translation", "id": "signup_button"},
      "search_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "search_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "signup_button_color": {"type": "marketplace_data", "id": "primary_color"},
      "signup_button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"}
    },
    {
      "id": "listings",
      "kind": "listings",
      "title": "Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here.",
      "paragraph": "Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. ",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Login",
      "button_path": {"type": "path", "id": "login"},
      "price_color": {"type": "marketplace_data", "id": "primary_color"},
      "no_listing_image_background_color": {"type": "marketplace_data", "id": "primary_color"},
      "no_listing_image_text": {"type": "translation", "id": "no_listing_image"},
      "author_name_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "listings": [
        {
          "listing": { "type": "listing", "id": 1 }
        },
        {
          "listing": { "type": "listing", "id": 2 }
        },
        {
          "listing": {
            "title": "Pelago San Sebastian, in very good condition in Kallio",
            "price": "$39",
            "author_name": "Mikko P.",
            "price_unit": "day",
            "author_avatar": "https://c5.staticflickr.com/1/727/20082134084_88e9691b84_h.jpg",
            "listing_image": "https://c4.staticflickr.com/2/1501/26646827091_e8a73c0c6c_h.jpg",
            "listing_path": "http://www.google.com"
          }
        }
      ]
    },
    {
      "id": "video2",
      "kind": "video",
      "variation": "youtube",
      "youtube_video_id": "UffchBUUIoI",
      "width": "1280",
      "height": "720",
      "text": "Watch the cool video!"
    },
    {
      "id": "categories7",
      "kind": "categories",
      "title": "Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here.",
      "paragraph": "Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. Section paragraph goes here. ",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "Mountain bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "type": "category",
            "id": 1
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "Parts",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories6",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "Mountain bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories5",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories4",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "categories3",
      "kind": "categories",
      "title": "Section title goes here",
      "paragraph": "Section paragraph goes here",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "All categories",
      "button_path": {"type": "path", "id": "all_categories"},
      "category_color_hover": {"type": "marketplace_data", "id": "primary_color"},
      "categories": [
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        },
        {
          "category": {
            "title": "City bikes",
            "path": "https://google.com"
          },
          "background_image": {"type": "assets", "id": "myheroimage"}
        }
      ]
    },
    {
      "id": "info1_v1",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V1]",
      "paragraph": ["Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.","Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero."],

      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Section link",
      "button_path": {"type": "path", "id": "post_a_new_listing"},
      "background_image": {"type": "assets", "id": "myinfoimage"}
    },
    {
      "id": "info1_v2",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V2]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "background_image": {"type": "assets", "id": "myinfoimage2"}
    },
    {
      "id": "info1_v3",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V3]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "button_title": "Section link",
      "button_path": {"value": "https://google.com"},
      "background_color": [255, 0, 255]
    },
    {
      "id": "info1_v4",
      "kind": "info",
      "variation": "single_column",
      "title": "Section title goes here [Info #1 - V4]",
      "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Donec ullamcorper nulla non metus auctor fringilla. Curabitur blandit tempus porttitor. Nulla vitae elit libero."
    },
    {
      "id": "info2_v1",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here. Section title goes here.",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "grape",
          "title": "Our mission",
          "paragraph": ["Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.","Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."],
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "watering-can",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "globe-1",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info2_v2",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V2]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info2_v3",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V3]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "icon": "globe-1",
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "info2_v4",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #2 - V4]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Curabitur blandit tempus porttitor. Nulla vitae elit libero, a pharetra augue. Vivamus sagittis lacus vel."
        }
      ]
    },
    {
      "id": "info3_v1",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V1]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info3_v2",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V2]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.",
          "button_title": "Section link",
          "button_path": {"value": "https://google.com"}
        }
      ]
    },
    {
      "id": "info3_v3",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V3]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "icon": "quill",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        },
        {
          "icon": "piggy-bank",
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        }
      ]
    },
    {
      "id": "info3_v4",
      "kind": "info",
      "variation": "multi_column",
      "title": "Section title goes here [Info #3 - V4]",
      "button_color": {"type": "marketplace_data", "id": "primary_color"},
      "button_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "columns": [
        {
          "title": "Our mission",
          "paragraph": ["Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.","Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus.","Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."]
        },
        {
          "title": "Our mission",
          "paragraph": "Paragraph. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Donec id elit non mi porta gravida at eget metus."
        }
      ]
    },
    {
      "id": "footer",
      "kind": "footer",
      "theme": "light",
      "social_media_icon_color": {"type": "marketplace_data", "id": "primary_color"},
      "social_media_icon_color_hover": {"type": "marketplace_data", "id": "primary_color_darken"},
      "links": [
        {"label": "About", "href": {"type": "path", "id": "about"}},
        {"label": "Contact us", "href": {"type": "path", "id": "contact_us"}},
        {"label": "How to use?", "href": {"type": "path", "id": "how_to_use"}},
        {"label": "Terms", "href": {"type": "path", "id": "terms"}},
        {"label": "Privary", "href": {"type": "path", "id": "privacy"}},
        {"label": "Sharetribe", "href": {"value": "https://www.sharetribe.com"}}
      ],
      "social": [
        {"service": "facebook", "url": "https://www.facebook.com"},
        {"service": "twitter", "url": "https://www.twitter.com"},
        {"service": "instagram", "url": "https://www.instagram.com"},
        {"service": "youtube", "url": "https://www.youtube.com/channel/UCtefWVq2uu4pHXaIsHlBFnw"},
        {"service": "googleplus", "url": "https://www.google.com"},
        {"service": "linkedin", "url": "https://www.google.com"}
      ],
      "copyright": "Copyright Marketplace Ltd 2016"
    },

    {
      "id": "thecategories",
      "kind": "categories",
      "slogan": "blaablaa",
      "category_ids": [123, 432, 131]
    }
  ],

  "composition": [
    { "section": {"type": "sections", "id": "myhero1"}},
    { "section": {"type": "sections", "id": "video2"}},
    { "section": {"type": "sections", "id": "info1_v1"}},
    { "section": {"type": "sections", "id": "info1_v2"}},
    { "section": {"type": "sections", "id": "info1_v3"}},
    { "section": {"type": "sections", "id": "info1_v4"}},
    { "section": {"type": "sections", "id": "info2_v1"}},
    { "section": {"type": "sections", "id": "info2_v2"}},
    { "section": {"type": "sections", "id": "info2_v3"}},
    { "section": {"type": "sections", "id": "info2_v4"}},
    { "section": {"type": "sections", "id": "info3_v1"}},
    { "section": {"type": "sections", "id": "info3_v2"}},
    { "section": {"type": "sections", "id": "info3_v3"}},
    { "section": {"type": "sections", "id": "info3_v4"}},
    { "section": {"type": "sections", "id": "footer"}}
  ],

  "assets": [
    { "id": "myheroimage", "src": "hero.jpg", "content_type": "image/jpeg" },
    { "id": "myinfoimage", "src": "info.jpg", "content_type": "image/jpeg" },
    { "id": "myinfoimage2", "src": "church.jpg", "content_type": "image/jpeg" }
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
      "facebook_site_name": {"type": "marketplace_data", "id": "name"}
    },
    "sections": [
        {
            "id": "hero",
            "kind": "hero",
            "variation": {"type": "marketplace_data", "id": "search_type"},
            "title": {"type": "marketplace_data", "id": "slogan"},
            "subtitle": {"type": "marketplace_data", "id": "description"},
            "background_image": {"type": "assets", "id": "hero_background_image"},
            "search_button": {"type": "translation", "id": "search_button"},
            "search_path": {"type": "path", "id": "search"},
            "search_placeholder": {"type": "marketplace_data", "id": "search_placeholder"},
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
end

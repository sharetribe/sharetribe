window.ST = window.ST || {};

(function(module) {
  /* global disable_submit_button */
  /* global set_textarea_maxlength */
  /* global auto_resize_text_areas */
  /* jshint eqeqeq: false */ // Some parts of the code in this file actually compares number that is string to a number

  // Update the state of the new listing form based on current status
  function update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes) {
    // Hide everything
    $('a.selected').addClass('hidden');
    $('a.option').addClass('hidden');

    // Display correct selected attributes
    $('.selected-group').each(function() {
      if (selected_attributes[$(this).attr('name')] != null) {
        $(this).find('a.selected[data-id=' + selected_attributes[$(this).attr('name')] + ']').removeClass('hidden');
      }
    });

    // Display correct attribute menus and their titles
    var title = "";
    var shouldLoadForm = false;
    if (should_show_menu_for("category", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["category"];
      display_option_group("category", selected_attributes, attribute_array);
    } else if (should_show_menu_for("subcategory", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["subcategory"];
      display_option_group("subcategory", selected_attributes, attribute_array);
    } else if (should_show_menu_for("listing_shape", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["listing_shape"];
      display_option_group("listing_shape", selected_attributes, attribute_array);
    } else {
      shouldLoadForm = true;
    }
    $('h2.listing-form-title').html(title);

    return shouldLoadForm;
  }



  // Return subcategories for given category.
  // Returns empty array if there are no subcategories.
  function get_subcategories_for(category_id, category_array) {
    return _.chain(category_array)
      .filter(function(category) {
        return category["id"] == category_id;
      })
      .filter(function(category) {
        return category["subcategories"] !== undefined;
      })
      .map(function(category) {
        return category["subcategories"];
      })
      .flatten()
      .value();
  }

  // Check if category has a certain subcategory
  function has_subcategory(category_id, subcategory_id, attribute_array) {
    var subcategories = get_subcategories_for(category_id, attribute_array);
    return _.any(subcategories, function(subcategory) {
      return subcategory['id'] == subcategory_id;
    });
  }

  // Returns true if given attribute has been selected
  function attribute_selected(attribute, selected_attributes) {
    return (selected_attributes[attribute] != null);
  }

  // Returns the object that has the given id
  // from an array of objects
  function find_by_id(id, array) {
    return _.find(array, function(item) {
      return item.id === id;
    });
  }

  // Return listing shapes of given category (expects
  // that this category does not have subcategories)
  function get_listing_shapes_for_category(category_id, category_array) {
    var category = find_by_id(Number(category_id), category_array);
    return category["listing_shapes"];
  }

  // Returns listing shape of given subcategory
  function get_listing_shapes_for_subcategory(category_id, subcategory_id, category_array) {
    var category = find_by_id(Number(category_id), category_array);
    var subcategory = find_by_id(Number(subcategory_id), category["subcategories"]);
    return subcategory["listing_shapes"];
  }

  // Return true if given menu should be displayed
  function should_show_menu_for(attribute, selected_attributes, attribute_array) {
    if (attribute_selected(attribute, selected_attributes)) {
      return false;
    } else if (attribute == "category") {
      if (attribute_array.length < 2) {
        // If there is exactly 1 category, it should be marked automatically as selected,
        // without showing the form.
        if (attribute_array.length == 1) {
          selected_attributes["category"] = attribute_array[0]["id"];
        }
        return false;
      } else {
        return true;
      }
    } else if (attribute == "subcategory") {
      if (should_show_menu_for("category", selected_attributes, attribute_array)) {
        return false;
      } else {
        var subcategories = get_subcategories_for(selected_attributes["category"], attribute_array);
        if (subcategories.length < 2) {
          // If there is exactly 1 subcategory, it should be marked automatically as selected,
          // without showing the form.
          if (subcategories.length == 1) {
            selected_attributes["subcategory"] = subcategories[0]["id"];
          }
          return false;
        } else {
          return true;
        }
      }
    } else if (attribute == "listing_shape") {
      if (should_show_menu_for("category", selected_attributes, attribute_array)) {
        return false;
      } else if (should_show_menu_for("subcategory", selected_attributes, attribute_array)) {
        return false;
      } else {
        var listing_shapes;
        if (attribute_selected("subcategory", selected_attributes)) {
          listing_shapes = get_listing_shapes_for_subcategory(selected_attributes["category"], selected_attributes["subcategory"], attribute_array);
        } else {
          listing_shapes = get_listing_shapes_for_category(selected_attributes["category"], attribute_array);
        }
        // If there is exactly 1 listing shape, it should be marked automatically as selected,
        // without showing the form
        if (listing_shapes.length === 1) {
          selected_attributes["listing_shape"] = listing_shapes[0]["id"];
        }
        return (listing_shapes.length > 1);
      }
    }
  }

  // Ajax call to display listing form after categories and
  // listing shape has been selected
  function display_new_listing_form(selected_attributes, locale) {
    var new_listing_path = '/' + locale + '/listings/new_form_content';
    $.get(new_listing_path, selected_attributes, function(data) {
      $('.js-form-fields').html(data);
      $('.js-form-fields').removeClass('hidden');
    });
  }

  function display_edit_listing_form(selected_attributes, locale, id) {
    var edit_listing_path = '/' + locale + '/listings/edit_form_content';
    var request_params = _.assign({}, selected_attributes, {id: id});
    $.get(edit_listing_path, request_params, function(data) {
      $('.js-form-fields').html(data);
      $('.js-form-fields').removeClass('hidden');
    });
  }

  // Check if selected category or subcategory has certain listing shape
  function has_listing_shape(selected_attributes, listing_shape_id, attribute_array) {
    // If subcategory is selected, loop through listing shapes of that subcategory
    var listing_shapes;
    if (attribute_selected("subcategory", selected_attributes)) {
      listing_shapes = get_listing_shapes_for_subcategory(selected_attributes["category"], selected_attributes["subcategory"],attribute_array);
      // If there's no subcategory, it means this top level category has no subcategories.
      // Thus, loop through listing_shapes of top level category.
    } else {
      listing_shapes = get_listing_shapes_for_category(selected_attributes["category"] ,attribute_array);
    }
    return _.any(listing_shapes, function(listing_shape) {
      return listing_shape['id'] == listing_shape_id;
    });
  }

  // Displays the given menu where category or listing shape can be selected
  function display_option_group(group_type, selected_attributes, attribute_array) {
    $('.option-group[name=' + group_type + ']').children().each(function() {
      if (group_type == "category") {
        $(this).removeClass('hidden');
      } else if (group_type == "subcategory") {
        if (has_subcategory(selected_attributes["category"], $(this).attr('data-id'), attribute_array)) {
          $(this).removeClass('hidden');
        }
      } else if (group_type == "listing_shape") {
        if (has_listing_shape(selected_attributes, $(this).attr('data-id'), attribute_array)) {
          $(this).removeClass('hidden');
        }
      }
    });
  }

  // Called when a link is clicked in the listing form attribute menus
  function select_listing_form_menu_link(link, locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes) {

    // Update selected attributes based on the selection that has been made
    if (link.hasClass('option')) {
      selected_attributes[link.parent().attr('name')] = link.attr('data-id');
    } else {
      selected_attributes[link.parent().attr('name')] = null;
      // Unselect also all sub-attributes if certain attribute is unselected
      // (for instance, unselect subcategory if category is unselected).
      var index_found = false;
      for (var i = 0; i < ordered_attributes.length; i++) {
        if (ordered_attributes[i] == link.parent().attr('name')) {
          index_found = true;
        }
        if (index_found === true) {
          selected_attributes[ordered_attributes[i]] = null;
        }
      }
    }

    // Update form view based on the selection that has been made
    var shouldLoadForm = update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

    return shouldLoadForm;
  }

  var setPushState = function(selectedAttributes) {
    if(window.history == null || window.history.pushState == null ) {
      return;
    }

    var url = window.location.origin + window.location.pathname;

    window.history.pushState(selectedAttributes, null, addQueryParams(url, selectedAttributes));
  };

  var addQueryParams = function(url, selectedAttributes) {
    var attrs = hashCompact(selectedAttributes);

    if(_.isEmpty(attrs)) {
      return url;
    } else {
      var q = _.map(attrs, function(val, key) {
        return key + "=" + val;
      }).join("&");

      return [url, q].join("?");
    }
  };

  var hashCompact = function(h) {
    return _.reduce(h, function(acc, val, key) {
      if(val != null) {
        acc[key] = val;
      }
      return acc;
    }, {});
  };

  var emptySelection = {"category": null, "subcategory": null, "listing_shape": null};

  var selectedAttributesFromQueryParams = function(search) {
    if(!search) {
      return {};
    }

    var without_q = search.replace(/^\?/, ''); // Remove the first char if it's question mark
    var attrsFromQuery = _.zipObject(without_q.split("&").map(function(keyValuePair) { return keyValuePair.split("="); }));

    return _.assign({}, emptySelection, attrsFromQuery);
  };

  // Initialize the listing type & category selection part of the form
  module.initialize_new_listing_form_selectors = function(locale, attribute_array, listing_form_menu_titles) {
    var ordered_attributes = ["category", "subcategory", "listing_shape"];
    var selected_attributes = selectedAttributesFromQueryParams(window.location.search);

    // Reset the view to initial state
    var shouldLoadForm = update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

    if(shouldLoadForm) {
      display_new_listing_form(selected_attributes, locale);
    }

    var menuStateChanged = function(shouldLoadForm) {
      if(shouldLoadForm) {
        display_new_listing_form(selected_attributes, locale);
      }
    };

    // Listen for back button click
    window.addEventListener('popstate', function(evt) {
      selected_attributes = evt.state || emptySelection;

      $('.js-form-fields').addClass('hidden');
      var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

      menuStateChanged(shouldLoadForm);
    });

    // Listener for attribute menu clicks
    $('.new-listing-form').find('a.select').click(
      function() {
        $('.js-form-fields').addClass('hidden');
        var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

        setPushState(selected_attributes);

        menuStateChanged(shouldLoadForm);
      }
    );
  };

  module.initialize_edit_listing_form_selectors = function(locale, attribute_array, listing_form_menu_titles, category, subcategory, listing_shape, id) {
    var ordered_attributes = ["category", "subcategory", "listing_shape"];

    // Selected values (string or null required)
    category = category ? "" + category : null;
    subcategory = subcategory ? "" + subcategory : null;
    listing_shape = listing_shape ? "" + listing_shape : null;

    var selected_attributes = {"category": category, "subcategory": subcategory, "listing_shape": listing_shape};
    var originalSelection = _.clone(selected_attributes);
    var current_attributes = _.clone(selected_attributes);

    // Reset the view to initial state
    var shouldShowForm = update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

    if(shouldShowForm) {
      $('.js-form-fields').removeClass('hidden');
    }

    var menuStateChanged = function(shouldLoadForm) {
      if(shouldLoadForm) {

        var loadNotNeeded = _.isEqual(selected_attributes, current_attributes);
        current_attributes = _.clone(selected_attributes);

        if(loadNotNeeded) {
          $('.js-form-fields').removeClass('hidden');
        } else {
          $('.js-form-fields').html("");
          display_edit_listing_form(selected_attributes, locale, id);
        }
      }

    };

    // Listen for back button click
    window.addEventListener('popstate', function(evt) {
      selected_attributes = evt.state || originalSelection;

      $('.js-form-fields').addClass('hidden');
      var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

      menuStateChanged(shouldLoadForm);
    });

    // Listener for attribute menu clicks
    $('.new-listing-form').find('a.select').click(
      function() {
        $('.js-form-fields').addClass('hidden');
        var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

        setPushState(selected_attributes);
        menuStateChanged(shouldLoadForm);
      }
    );

  };

  // Initialize the actual form fields
  module.initialize_new_listing_form = function(
    fileDefaultText,
    fileBtnText,
    locale,
    share_type_message,
    date_message,
    listing_id,
    price_required,
    price_message,
    minimum_price,
    subunit_to_unit,
    minimum_price_message,
    numeric_field_names,
    listingImages,
    listingImageOpts,
    imageLoadingInProgressConfirm) {

    $('#help_valid_until_link').click(function() { $('#help_valid_until').lightbox_me({centered: true, zIndex: 1000000}); });
    $('input.title_text_field:first').focus();

    var $shipping_price_container = $('.js-shipping-price-container');
    var $shipping_checkbox = $('#shipping-checkbox');
    $shipping_checkbox.click(function() { togglePrice(); });

    var togglePrice = function(){
      if($shipping_checkbox.is(":checked")) {
        $shipping_price_container.show();
      } else {
        $shipping_price_container.hide();
      }
    };
    togglePrice(); //initialize

    var $unit = $(".js-listing-unit");

    if ($unit.length) {
      var $additionalShipping = $(".js-shipping-price-additional");

      var toggleAdditional = function() {
        var kind = $unit.find(":selected").data("kind");

        if (kind === "quantity") {
          $additionalShipping.css({display: "table"});
        } else {
          $additionalShipping.hide();
        }
      };

      $unit.change(toggleAdditional);
      toggleAdditional(); // init
    }

    var form_id = (listing_id == "false") ? "#new_listing" : ("#edit_listing_" + listing_id);

    // Is price required?
    var pr = null;
    if (price_required == "true") {
      pr = true;
    } else {
      pr = false;
    }

    var numericRules = numeric_field_names.reduce(function(rules, name) {
      var el = module.utils.findElementByName(name);
      var min = el.data("min");
      var max = el.data("max");

      rules[name] = {number_min: min, number_max: max};

      return rules;
    }, {});

    module.listingForm = $(form_id).validate({
      errorPlacement: function(error, element) {
        if (element.attr("name") == "listing[valid_until(1i)]") {
          error.appendTo(element.parent());
        } else if (element.attr("name") == "listing[price]") {
          error.appendTo(element.parent());
        } else if ($(element).hasClass("custom_field_checkbox")) {
          var container = $(element).closest(".checkbox-group-container");
          error.insertAfter(container);
        } else if ($(element).hasClass("delivery-method-checkbox")) {
          error.insertAfter($(".delivery-options-container"));
        } else if (element.attr("name") == "listing[shipping_price]") {
          error.insertAfter($(".shipping-price-default"));
        } else if (element.attr("name") == "listing[shipping_price_additional]") {
          error.insertAfter($(".js-shipping-price-additional"));
        } else {
          error.insertAfter(element);
        }
      },
      debug: false,
      rules: _.extend(numericRules, {
        "listing[title]": {required: true, minlength: 2, maxlength: 60},
        "listing[origin]": {address_validator: true},
        "listing[price]": {required: pr, money: true, minimum_price_required: [minimum_price, subunit_to_unit]},
        "listing[shipping_price]": {money: true},
        "listing[shipping_price_additional]": {money: true},
        "listing[valid_until(1i)]": { min_date: true, max_date: true }
      }),
      messages: {
        "listing[valid_until(1i)]": { min_date: date_message, max_date: date_message },
        "listing[price]": { minimum_price_required: minimum_price_message }
      },
      // Run validations only when submitting the form.
      onkeyup: false,
      onclick: false,
      onfocusout: false,
      onsubmit: true
    });

    var status = window.ST.imageUploader(listingImages, listingImageOpts).log("status returned");

    status.onValue(function(stats) {

      $('.flash-notifications').click(function() {
        $('.flash-notifications').fadeOut('slow');
      });

      if(stats.loading === 0) {
        $(".js-listing-image-loading").hide();

        if(stats.processing === 0) {
          $(".js-listing-image-loading-done").hide();
        } else {
          $(".js-listing-image-loading-done").show();
        }
      } else {
        $(".js-listing-image-loading-done").hide();
        $(".js-listing-image-loading").show();
      }
    });

    var formSubmitted = $(form_id).asEventStream("submit");
    var validFormSubmitted = formSubmitted.filter(function() {
      return $(form_id).valid();
    });

    var isLoading = status.map(function(stats) { return stats.loading > 0; });

    // This handler is used only when Image uploader is loading
    validFormSubmitted.filter(isLoading).onValue(function(e) {
      var confirmed = window.confirm(imageLoadingInProgressConfirm);

      if(!confirmed) {
        e.preventDefault();

        // This will prevent the jQuery validation submitHandler from
        // executing. Please note that the order matters. This works
        // before it's called BEFORE the submitHandler
        e.stopImmediatePropagation();
      }
    });

    // This handler is used when Image uploader is not loading
    validFormSubmitted.filter(isLoading.not()).onValue(function(e) {
      window.ST.analytics.logEvent("listing", "created");
      disable_submit_button(form_id, locale);
    });

    set_textarea_maxlength();
    auto_resize_text_areas("listing_description_textarea");

    $(form_id).addClass("js-listing-form-ready");
  };

})(window.ST);

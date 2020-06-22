 window.ST = window.ST || {};

(function(module) {
  var toggleElements = function(selector, show) {
    var parentEl = $(selector),
      elements = parentEl.find('input, select');

    if(show) {
      elements.removeAttr("disabled").removeClass("disabled");
      parentEl.show();
    } else {
      elements.attr("disabled", true).addClass("disabled");
      parentEl.hide();
    }
  };

  var onBgStyleSelect = function(e) {
    var currentStyle = $("input.bg-style-selector:checked").val();

    toggleElements('.bg-style-image', currentStyle == "image");
    toggleElements('.bg-style-color', currentStyle == "color");
  };

  var onCtaSelect = function(e) {
    var cta_input = $("input.cta-select")[0];
    if (!cta_input) {
      return;
    }
    var elems = $(".cta-enabled *");
    if(cta_input.checked) {
      elems.removeAttr("disabled").removeClass("disabled");
    } else {
      elems.attr("disabled", true).addClass("disabled");
    }
  };

  var initForm = function(options) {
    $("input.bg-style-selector").on("change", onBgStyleSelect);
    $("input#section_cta_enabled").on("click", onCtaSelect);
    onBgStyleSelect();
    onCtaSelect();

    $(document).on("click", ".section-column-header-toggle", function(e) {
      e.preventDefault();
      $(this).parents(".collapsible").toggleClass("collapsed");
      return false;
    });

    $.validator.addMethod('count-validation', function(value, element, params) {
      var name = $(element).data("counter-name");
      var count = $(".menu-link-sortable:visible").size();
      var min = $(element).data("min");
      var max = $(element).data("max");
      if (max) {
        return count <= max;
      } else {
        return count >= min;
      }
    });

    // This uses already initialized validator from a ST.FooterMenu
    // Required calling ST.FooterMenu.init() before this!
    var validator = $("form.edit_section, form.new_section").validate();
    validator.settings.invalidHandler = function(event, validator) {
      var error_elements = $.map(validator.invalid, function(message, key) { return 'input[name="'+key+'"]'; });
      $(error_elements.join(", ")).parents(".collapsed").find(".section-column-header-toggle").click();
    };
    var setSortPriority = function(selector) {
      var index = 0;
      $(selector).each(function(){
        $(this).val(index);
        index++;
      });
    };
    validator.settings.submitHandler = function(form) {
      setSortPriority("#menu-links .sort-priority");
      setSortPriority("#social-links .sort-priority");
      form.submit();
    };
  };

  var initHero = function(options) {
    $('input[cta_button_type_radio]').on('change', function() {
      var value = $('input[cta_button_type_radio]:checked').val(),
        button = value == 'button',
        none = value == 'none',
        ctaButtonInfo = $('#cta-button-info'),
        ctaButtonText = $('#section_cta_button_text'),
        ctaButtonUrl = $('#section_cta_button_url');
      toggleElements(".cta-enabled", button);
      toggleElements(ctaButtonInfo, !button);
      toggleElements(".cta-default", !none);

      ctaButtonText.attr('required', button ? true : null);
      ctaButtonUrl.attr('required', button ? true : null);
    });
    $("form.edit_section, form.new_section").validate();
  };

  module.LandingPageSectionEditor = {
    initForm: initForm,
    initHero: initHero
  };
})(window.ST);

 window.ST = window.ST || {};

(function(module) {
  var onBgStyleSelect = function(e) {
    var currentStyle = $("input.bg-style-selector:checked").val(),
      elems_for_image = $(".bg-style-image *"),
      elems_for_color = $(".bg-style-color *");

    if(currentStyle != "image") {
      elems_for_image.attr("disabled", true).addClass("disabled");
    } else {
      elems_for_image.removeAttr("disabled").removeClass("disabled");
    }

    if(currentStyle != "color") {
      elems_for_color.attr("disabled", true).addClass("disabled");
    } else {
      elems_for_color.removeAttr("disabled").removeClass("disabled");
    }
  };

  var onCtaSelect = function(e) {
    var cta_input = $("input.cta-select")[0];
    var elems = $(".cta-enabled *");
    if(!cta_input.checked) {
      elems.attr("disabled", true).addClass("disabled");
    } else {
      elems.removeAttr("disabled").removeClass("disabled");
    }
  };

  var addExtraValidationRules = function() {
    $.validator.addMethod('total_categories_3', function(value, element, params) {
      var count = $('input[name^="section[categories_attributes]"][name$="[id]"]').size();
      return count >= 3;
    }, $("#total_categories_3").data('msg'));

    $.validator.addMethod('total_categories_7', function(value, element, params) {
      var count = $('input[name^="section[categories_attributes]"][name$="[id]"]').size();
      return count <= 7;
    }, $("#total_categories_7").data('msg'));

    $.validator.addClassRules('total_categories_3', {total_categories_3: true});
    $.validator.addClassRules('total_categories_7', {total_categories_7: true});
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

    addExtraValidationRules();

    $("form.edit_section, form.new_section").validate({
      ignore: 'input[type=hidden], input[disabled]',
      invalidHandler: function(event, validator) {
        var error_elements = $.map(validator.invalid, function(message, key) { return 'input[name="'+key+'"]'; });
        $(error_elements.join(", ")).parents(".collapsed").find(".section-column-header-toggle").click();
      }
    });
  };

  module.LandingPageSectionEditor = {
    initForm: initForm
  };
})(window.ST);

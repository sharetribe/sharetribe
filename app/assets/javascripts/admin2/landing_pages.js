function readURL(input, render_img) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            render_img.attr('src', e.target.result);
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function renderDeleteBlock(elem, caption, body) {
    var delete_block = elem.closest('.edit-category-content').next('.remove-category-content'),
        html_header = delete_block.find('.delete_header'),
        html_body = delete_block.find('.delete_body');

    html_header.html(caption);
    html_body.html(body);
}

function sortPriority() {
  $('.sort-priority').each(function (index) {
    $(this).val(index);
  });
}

function initCategory() {
    $(document).off('click', ".edit-dropdown-list-option-trigger");
    $(document).on('click', '.edit-dropdown-list-option-trigger', function (event) {
        var container = $(this).closest('.categories-list').next('.edit-category-content'),
            remove = $(this).closest('.categories-list').next('.edit-category-content').next('.remove-category-content');
        if (container.is(":visible")) {
            container.hide(200);
        } else {
            container.show(200);
            remove.hide(0);
        }
        return event.preventDefault();
    });

    $(document).off('change', '.category-image-render');
    $(document).on('change', '.category-image-render', function () {
        var empty_image = $(this).closest('.edit-category-content').prev('.categories-list').find('img');
        readURL(this, empty_image);
    });

    $(document).off('change', '.category-category');
    $(document).on('change', '.category-category', function () {
        var container = $(this).closest('.edit-category-content').prev('.categories-list').find('.category-name-lp'),
            value = $(this).find(":selected").text();
        container.text($.trim(value));

        var caption = I18n.translate("web.admin2.landing_page.category.remove", {'name': '"' + $.trim(value) + '"'}),
            body = I18n.translate("web.admin2.landing_page.category.remove_confirm", {'name': '"' + $.trim(value) + '"'});

        renderDeleteBlock($(this), caption, body);
    });

    $(document).off('change', '.location-url-render');
    $(document).on('change', '.location-url-render', function () {
        var container = $(this).closest('.edit-category-content').prev('.categories-list').find('.location-url-lp'),
            value = $(this).val();
        container.text(value);
    });

    $(document).off('change', '.location-title-render');
    $(document).on('change', '.location-title-render', function () {
        var container = $(this).closest('.edit-category-content').prev('.categories-list').find('.location-name-lp'),
            value = $(this).val();
        container.text(value);

        if (value.length) {
          value = '"' + value + '"';
        }

        var caption = I18n.translate("web.admin2.landing_page.location.remove", {'name': value}),
            body = I18n.translate("web.admin2.landing_page.location.remove_confirm", {'name': value});

        renderDeleteBlock($(this), caption, body);
    });

    $(document).off('click', ".edit-category-cancel");
    $(document).on('click', ".edit-category-cancel", function(){
        $(this).closest('.edit-category-content').hide(0);
    });

    $(document).on('click', '.remove-dropdown-list-option-trigger', function(event){
        var container = $(this).closest('.categories-list').next('.edit-category-content').next('.remove-category-content'),
            edit = $(this).closest('.categories-list').next('.edit-category-content');
        edit.hide(0);
        container.show(200);
        return event.preventDefault();
    });

    $(document).on('click', '.remove-category-cancel', function(){
        $(this).closest('.remove-category-content').hide(0);
    });

    $(document).on('click', '.remove-category-btn', function(event){
        var container = $(this).closest('.remove-category-content').prev('.edit-category-content').prev('.categories-list'),
            container_edit = $(this).closest('.remove-category-content').prev('.edit-category-content'),
            isNew = container.data('new');
        container.find('.destroy-record').val('1');
        if (isNew) {
            container_edit.remove();
            container.remove();
        } else {
            container_edit.find('input').removeClass('required');
            container.hide();
        }
        $(this).closest('.remove-category-content').hide();
        return event.preventDefault();
    });
}

function initFooter() {

    $(document).off('click', '#new-footerLink-trigger');
    $(document).on('click', '#new-footerLink-trigger', function(event) {
        var time = new Date().getTime(),
            regexp = new RegExp($(this).data('id'), 'g'),
            templateId = $(this).data('templateId'),
            entry = $($(templateId).html().replace(regexp, time));
        $('#footerlinks').append(entry);
        if (!$($(entry)[2]).hasClass('remove-footerLink-content')) {
          $($(entry)[2]).show(200);
        }
        sortPriority();
        return event.preventDefault();
    });

    $(document).on('click', '.remove-footer-link', function (event) {
        var container = $(this).closest('.remove-footerLink-content').prev('.footer-link-group'),
            isNew = container.data('new');
        container.find('.destroy-record').val('1');
        if (isNew) {
            container.remove();
        } else {
            container.hide();
        }
        $(this).closest('.remove-footerLink-content').hide();
        return event.preventDefault();
    });

    $(document).on('click', '.remove-footerLink-trigger', function(event) {
        var container = $(this).closest('.footer-link-group'),
            title = container.find('.form-title').val();

        if (title.length) {
          title = '"' + title + '"';
        }
        var caption = I18n.translate("web.admin2.landing_page.footer_menu_link.remove_title", {'name': title}),
            body = I18n.translate("web.admin2.landing_page.footer_menu_link.remove_body", {'name': title}),
            remove_message_div = container.next('.remove-footerLink-content');
        remove_message_div.find('.remove-title').html(caption);
        remove_message_div.find('.remove-body').html(body);
        remove_message_div.show(200);
        return event.preventDefault();
    });

    if ($('#footerlinks').length) {
        Sortable.create(footerlinks, {
            handle: '.handle-move',
            animation: 250,
            onEnd: function (/**Event*/evt) {
              sortPriority();
            }
        });
    }

  if ($('#footerSocialList').length) {
    Sortable.create(footerSocialList, {
      handle: '.handle-move',
      animation: 250,
      onEnd: function (/**Event*/evt) {
        $('.sort-priority-social').each(function (index) {
          $(this).val(index);
        });
      }
    });
  }

  $(document).on('click', ".remove-footerLink-cancel", function(){
        $(this).closest(".remove-footerLink-content").hide(0);
        return false;
    });
}

function checkedLandingPage(){
    var back_image = $('#info1ColBackgroundImageWrapper'),
        back_color = $('#info1ColBackgroundColorWrapper'),
        url = $('#info1ColCTALabelURLWrapper'),
        hero_btn = $('#heroCTAButtonLabelURLWrapper'),
        def_text = $('.default-text-label'),
        btn_text_label = $('#buttonTextLabel'),
        def_url = $('#heroCTADefaultTextWrapper');

    back_image.hide();
    back_color.hide();
    hero_btn.hide();
    url.hide();

    if ($('#section_cta_enabled').prop('checked')) {
        url.show();
    }
    if ($('#section_background_style_color').prop('checked')) {
        back_color.show();
    }
    if ($('#section_background_style_image').prop('checked')) {
        back_image.show();
    }
    if ($('#section_cta_button_type_default').prop('checked')) {
        hero_btn.show();
        def_text.show();
        btn_text_label.hide();
        def_url.hide();
    }
    if ($('#section_cta_button_type_button').prop('checked')) {
        hero_btn.show();
        def_text.hide();
        btn_text_label.show();
        def_url.show();
    }
}
function initLandingPage(edit){

    var id;

    if (edit) {
      id = '#landingPageEditModal';
    } else {
      id = '#landingPageAddModal';
    }

    $("#section_background_color_string").spectrum({
        showInput: true,
        preferredFormat: "hex",
        showPalette: true,
        showSelectionPalette: false,
        palette: [["#FFF", "#000", "#FF4E36", "#15778E", "#ff5a5f"]],
        appendTo: id
    });

    checkedLandingPage();
    initFooter();
    initCategory();

    $("form.section-form").validate({
        ignore: ":hidden:not(.custom-validation, .category-image-render, .location-url-render), .ignore-validation",
        messages: {
            "section[listing_1_id]": { valid_listing: I18n.translate("web.admin2.landing_page.listings.not_valid_id_error")},
            "section[listing_2_id]": { valid_listing: I18n.translate("web.admin2.landing_page.listings.not_valid_id_error")},
            "section[listing_3_id]": { valid_listing: I18n.translate("web.admin2.landing_page.listings.not_valid_id_error")}
        },
        invalidHandler: function(form, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                $.each(validator.errorList, function (index, value) {

                    var main_row =  $(value.element).closest('.edit-category-content').prev('.categories-list');
                    if (main_row.is(":visible"))
                    {
                        $(value.element).closest('.edit-category-content').show();
                    }

                });

            }
        }
    });
}
$(function() {

    $(document).on('click', '.remove-landing-page', function () {
        var caption = $(this).data('caption'),
            url = $(this).data('url');
        $('#delete-landing-page-form').attr('action', url);
        $('#landingPageDeleteModalTitle').html(caption);
        $('#landingPageDeleteModal').modal('show');
        return false;
    });

    $('#landingPageAddModal').on('show.bs.modal', function (e) {
        $('#section_kind option[value=""]').show();
        $('#section_kind').prop('selectedIndex', 0);
        $('#section_block').empty();
    });

    $(document).on('change', '.landing-page-section', function () {
        checkedLandingPage();
    });

    $('#section_kind').on('change', function(){
        var url = $(this).data('url'),
            id = $(this).val(),
            option = $(this).find('option:selected'),
            variation = option.data('variation'),
            multi_columns = option.data('multi-columns');

        $.get(url, {section: {kind: id, variation: variation, multi_columns: multi_columns}}, null, 'script');
    });

    if ($('#landingSection').length) {
        Sortable.create(landingSection, {
            handle: '.handle-move',
            animation: 250,
            onMove: function (/**Event*/evt, originalEvent) {
                if ($(evt.related).hasClass('allow_edit_false')) {
                    return false;
                }
            },
            onEnd: function (/**Event*/evt) {
                $('.hidden-position').each(function (index) {
                    $(this).val(index);
                });
                $('form.landing-page-form').submit();
            }
        });
    }
});

window.ST = window.ST || {};

window.ST.imageUploader = function(listings, containerSelector, uploadSelector, thumbnailSelector, createFromFilePath) {
  var $container = $(containerSelector);

  function renderUploader() {
    var uploadTmpl = _.template($(uploadSelector).html());

    $container.html(uploadTmpl);

    function processing() {
      $(".fileupload-text", $container).text(ST.t("listings.form.images.processing"));
      $(".fileupload-small-text", $container).text(ST.t("listings.form.images.this_may_take_a_while"));
    }

    function updatePreview(result, delay) {
      $.get(result.processedPollingUrl, function(images_result) {
        if(images_result.processing) {
          processing();
          _.delay(function() {
            updatePreview(result, delay + 500);
          }, delay + 500);
        } else {
          renderThumbnail({thumbnailUrl: images_result.thumb, removeUrl: result.removeUrl});
        }
      });
    }

    $(function() {
      $('#fileupload').fileupload({
        dataType: 'json',
        url: createFromFilePath,
        dropZone: $('#fileupload'),
        progress: function(e, data) {
          if(data.total === data.loaded) {
            processing();
          } else {
            var percentage = Math.round((data.loaded / data.total) * 100);
            $(".fileupload-text", $container).text(ST.t("listings.form.images.percentage_loaded", {percentage: percentage}));
            $(".fileupload-small-text", $container).empty();
          }
        },
        done: function (e, data) {
          var result = data.result;
          $('#listing-image-upload-status').text(result.filename);
          $("#listing-image-id").val(result.id);

          updatePreview(result, 2000);
        },
        fail: function() {
          $(".fileupload-text", $container).text(ST.t("listings.form.images.uploading_failed"));
          $(".fileupload-small-text", $container).empty();
        }
      }).on('dragenter', function() {
        $(this).addClass('hover');
      }).on('dragleave', function() {
        $(this).removeClass('hover');
      });
    });
  }

  function renderThumbnail(listing) {
    var $thumbnail = $(_.template($(thumbnailSelector).html(), {thumbnailUrl: listing.thumbnailUrl}));

    $('.fileupload-preview-remove-image', $thumbnail).click(function(e) {
      e.preventDefault();

      $(".fileupload-removing").show();

      $.ajax({
        url: listing.removeUrl,
        type: 'DELETE',
        success: function() {
          $container.empty();
          $(".fileupload-removing").hide();
          renderUploader();
        },
      });
    });

    $container.html($thumbnail);
  }

  if(listings.length === 0) {
    renderUploader();
  } else {
    listings.forEach(renderThumbnail);
  }
};
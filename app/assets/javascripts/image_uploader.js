window.ST = window.ST || {};

window.ST.imageUploader = function(listings, opts) {
  var $container = $("#image-uploader-container");
  var $upload = $("#new-image-tmpl");
  var $thumbnail = $("#thumbnail-image-tmpl");
  var directUploadToS3 = !!opts.s3;

  function renderUploader() {
    var fileInputName = directUploadToS3 ? "file" : "listing_image[image]";
    var uploadTmpl = _.template($upload.html(), {fileInputName: fileInputName});

    $container.html(uploadTmpl);

    function processing() {
      showMessage(ST.t("listings.form.images.processing"), ST.t("listings.form.images.this_may_take_a_while"))
    }

    function showMessage(normal, small) {
      $normalEl = $(".fileupload-text", $container);
      $smallEl = $(".fileupload-small-text", $container);

      if(normal) {
        $normalEl.text(normal);
      } else {
        $normalEl.empty();
      }

      if(small) {
        $smallEl.text(small);
      } else {
        $smallEl.empty();
      }
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

    function onProgress(e, data) {
      var percentage = Math.round((data.loaded / data.total) * 100);
      showMessage(ST.t("listings.form.images.percentage_loaded", {percentage: percentage}))
    }

    function s3uploadDone(data) {
      var key = data.formData.key;
      var filename = data.files[0].name;
      var s3ImageUrl = opts.s3.uploadPath + key.replace("${filename}", filename);
      
      $.ajax({
        type: "PUT",
        url: opts.saveFromUrl,
        data: {
          image_url: s3ImageUrl
        },
        success: function(result) {
          listingImageSavingDone(result);
        },
        fail: imageUploadingFailed
      });
    }

    function listingImageSavingDone(result) {
      $("#listing-image-id").val(result.id);

      updatePreview(result, 2000);
    }

    function imageUploadingFailed() {
      showMessage(ST.t("listings.form.images.uploading_failed"));
    }

    function imageUploadingDone(e, data) {
      if(directUploadToS3) {
        s3uploadDone(data);
      } else {
        listingImageSavingDone(data.result);
      }
    }

    $(function() {
      $('#fileupload').fileupload({
        dataType: 'json',
        url: directUploadToS3 ? opts.s3.uploadPath : opts.saveFromFile,
        dropZone: $('#fileupload'),
        progress: onProgress,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        imageMaxWidth: opts.originalImageWidth,
        imageMaxHeight: opts.originalImageHeight,
        loadImageMaxFileSize: opts.maxImageFilesize,
        messages: {
          acceptFileTypes: "acceptFileTypes",
          maxFileSize: "maxFileSize",
        },
        processfail: function (e, data) {
          var firstError = _(data.files).pluck('error').first();

          var error = "";

          // This is kind of a hack now, we should start moving these validation messages
          // to en.yml and use ST.t for all translated strings
          if(firstError === "acceptFileTypes") {
            error = jQuery.validator.messages.accept
          }
          if(firstError === "maxFileSize") {
            error = ST.t("listings.form.images.file_too_large")
          }

          showMessage(null, error);
        },
        // Enable image resizing, except for Android and Opera,
        // which actually support image resizing, but fail to
        // send Blob objects via XHR requests:
        disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
        submit: function(e, data) {
          if(directUploadToS3) {
            data.formData = _.extend(opts.s3.options, {
              "Content-Type": data.files[0].type
            });
          }
        },
        done: imageUploadingDone,
        fail: imageUploadingFailed
      }).on('dragenter', function() {
        $(this).addClass('hover');
      }).on('dragleave', function() {
        $(this).removeClass('hover');
      });
    });
  }

  function renderThumbnail(listing) {
    var $thumbnailElement = $(_.template($thumbnail.html(), {thumbnailUrl: listing.thumbnailUrl}));

    $('.fileupload-preview-remove-image', $thumbnailElement).click(function(e) {
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

    $container.html($thumbnailElement);
  }

  if(listings.length === 0) {
    renderUploader();
  } else {
    listings.forEach(renderThumbnail);
  }
};
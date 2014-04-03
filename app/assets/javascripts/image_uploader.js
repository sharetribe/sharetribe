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
      showMessage(ST.t("listings.form.images.processing"), ST.t("listings.form.images.this_may_take_a_while"));
    }

    function showMessage(normal, small) {
      var $normalEl = $(".fileupload-text", $container);
      var $smallEl = $(".fileupload-small-text", $container);

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
      showMessage(ST.t("listings.form.images.percentage_loaded", {percentage: percentage}));
    }

    /**
      In IE, formData is an array of objects containing name and value
      In browsers, formData is a plain object
    */
    function valueFromFormData(formData, key) {
      if (_.isArray(formData)) {
        return _.find(formData, function(nameValue) {
          return nameValue.name === key;
        }).value;
      } else {
        return formData[key];
      }
    }

    function s3uploadDone(data) {
      var path = opts.s3.uploadPath + valueFromFormData(data.formData, "key");
      var filename = data.files[0].name;

      $.ajax({
        type: "PUT",
        url: opts.saveFromUrl,
        data: {
          filename: filename,
          path: path
        },
        success: function(result) {
          listingImageSavingDone(result);
        },
        fail: imageUploadingFailed
      });
    }

    function listingImageSavingDone(result) {
      result = JSON.parse(result);
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
        dataType: 'text', // Browsers without XHR fileupload support do not support other dataTypes than text
        url: directUploadToS3 ? opts.s3.uploadPath : opts.saveFromFile,
        dropZone: $('#fileupload'),
        progress: onProgress,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        imageMaxWidth: opts.originalImageWidth,
        imageMaxHeight: opts.originalImageHeight,
        loadImageMaxFileSize: opts.maxImageFilesize,
        messages: {
          acceptFileTypes: ST.t("listings.form.images.accepted_formats"),
          maxFileSize: ST.t("listings.form.images.file_too_large"),
        },
        processfail: function (e, data) {
          var firstError = _(data.files).pluck('error').first();
          showMessage(null, firstError);
        },
        // Enable image resizing, except for Android and Opera,
        // which actually support image resizing, but fail to
        // send Blob objects via XHR requests:
        disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
        submit: function(e, data) {
          var extraFormData = {
            "Content-Type": ST.utils.contentTypeByFilename(data.files[0].name)
          };

          if(directUploadToS3) {
            extraFormData = _.extend(extraFormData, opts.s3.options);
          }

          data.formData = extraFormData;
        },
        done: imageUploadingDone,
        fail: imageUploadingFailed
      }).on('fileuploadadd', function() {
        showMessage(ST.t("listings.form.images.loading_image"));
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

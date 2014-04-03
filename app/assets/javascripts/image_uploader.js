window.ST = window.ST || {};

/**
  Returns a new element for image uploading/preview
*/
window.ST.renderImagePlaceholder = function(type) {
  var template = $("#new-image-tmpl").html();
  var element = $(template);
  var previewImage = $("img", element).hide();
  var removeLink = $('.fileupload-preview-remove-image', element);
  var fileupload = $('.fileupload', element).hide();
  var texts = $('.fileupload-text-container', element);
  var textsOriginalDisplay = texts.css('display');
  var normalText = $(".fileupload-text", element);
  var smallText = $(".fileupload-small-text", element);
  var listingId = $(".listing-image-id", element);

  function showMessage(normal, small) {
    if(normal) {
      normalText.text(normal);
    } else {
      normalText.empty();
    }

    if(small) {
      smallText.text(small);
    } else {
      smallText.empty();
    }

    showTexts();
  }

  function hideTexts() {
    texts.css('display', 'none');
  }

  function showTexts() {
    texts.css('display', textsOriginalDisplay);
  }

  function showPreview(src) {
    previewImage.show().attr('src', src);
  }

  function setListingId(id) {
    listingId.val(id);
  }

  function showRemove() {
    element.addClass("fileupload-remove-hover");
  }

  function hideRemove() {
    element.removeClass("fileupload-remove-hover");
  }

  hideTexts();
  hideRemove();

  return {
    uniqueId: _.uniqueId('image_element_'),
    container: element,
    showMessage: showMessage,
    hideTexts: hideTexts,
    fileupload: fileupload,
    showPreview: showPreview,
    removeLink: removeLink,
    showRemove: showRemove,
    hideRemove: hideRemove,
    setListingId: setListingId,
    type: type
  };
};

window.ST.imageUploadElementManager = function($container) {
  var empties = [];
  var uploadings = [];
  var previews = [];

  function addPreview(element) {
    var last = _.last(previews);

    if (last) {
      element.insertAfter(last);
    } else {
      $container.prepend(element);
    }

    previews.push(element);

  }

  function removePreview(element) {
    element.remove();
    previews = _.without(previews, element);
  }

  function addUploading(element) {
    var lastUploadings = _.last(uploadings);
    var lastPreviews = _.last(previews);

    if (lastUploadings) {
      element.insertAfter(lastUploadings);
    } else if (lastPreviews) {
      element.insertAfter(lastPreviews);
    } else {
      $container.prepend(element);
    }

    uploadings.push(element);
  }

  function removeUploading(element) {
    element.remove();
    uploadings = _.without(uploadings, element);
  }

  function addEmpty(element) {
    $container.append(element);
    empties.push(element);
  }

  function removeEmpty() {
    empties.pop().remove();
  }

  return {
    addEmpty: addEmpty,
    addUploading: addUploading,
    addPreview: addPreview,
    removeEmpty: removeEmpty,
    removeUploading: removeUploading,
    removePreview: removePreview
  };
};

window.ST.imageUploader = function(listings, opts) {
  var elementManager = ST.imageUploadElementManager($("#image-uploader-container"));
  var directUploadToS3 = !!opts.s3Fields && !!opts.s3UploadPath;

  var extraPlaceholders = 2;

  var extraPlaceholdersNeeded = listings.length < extraPlaceholders ? extraPlaceholders - listings.length : 0;
  var imageSelected = _().range(extraPlaceholdersNeeded + 1).map(function() {
    return directUploadToS3 ? renderS3Uploader() : renderLocalUploader();
  }).each(function(rendered) {
    elementManager.addEmpty(rendered.element.container);
  }).map(function(rendered) {
    return rendered.stream;
  }).reduce(function(a, b) {
    return a.merge(b);
  });

  var uploadingRendered = imageSelected.map(function(data) {
    return renderUploading(data);
  });

  uploadingRendered.onValue(function(rendered) {
    elementManager.addUploading(rendered.element.container);
  });

  var imageUploaded = uploadingRendered.flatMap(function(rendered) {
    return rendered.stream;
  });

  var previewRemoved = _(listings).map(function(listing) {
    return renderPreview(listing);
  }).each(function(rendered) {
    elementManager.addPreview(rendered.element.container);
  }).map(function(rendered) {
    return rendered.stream;
  }).reduce(function(a, b) {
    return a.merge(b);
  });

  var newPreviewRendered = imageUploaded.map(function(listing) {
    return renderPreview(listing);
  });

  newPreviewRendered.onValue(function(rendered) {
    elementManager.addPreview(rendered.element.container);
  });

  var newPreviewRemoved = newPreviewRendered.flatMap(function(rendered) {
    return rendered.stream;
  });

  var imageRemoved = previewRemoved ? newPreviewRemoved.merge(previewRemoved) : newPreviewRemoved;

  function value(v) {
    return function() {
      return v;
    };
  }

  function add(x, y) { return x + y; }

  var count = imageSelected.map(value(1)).merge(imageRemoved.map(value(-1))).scan(listings.length, add);

  var maybeNeedsAddPlaceholder = count.map(function(c) { return c < extraPlaceholders; });
  var maybeNeedsRemovePlaceholder = count.map(function(c) { return c <= extraPlaceholders; });

  imageRemoved.filter(maybeNeedsAddPlaceholder).onValue(function() {
    var rendered = directUploadToS3 ? renderS3Uploader() : renderLocalUploader();
    elementManager.addEmpty(rendered.element.container);
  });

  imageSelected.filter(maybeNeedsRemovePlaceholder).onValue(function() {
    elementManager.removeEmpty();
  });

  function renderS3Uploader() {
    var s3Options = {
      url: opts.s3UploadPath,
      paramName: "file",
      submit: function(e, data) {
        data.formData = _.extend(opts.s3Fields, { "Content-Type": ST.utils.contentTypeByFilename(data.files[0].name) } );
      }
    };

    return renderUpload(s3Options);
  }

  function renderLocalUploader() {
    var localOptions = {
      paramName: "listing_image[image]",
      url: opts.saveFromFile,
      submit: function(e, data) {
        data.formData = { "Content-Type": ST.utils.contentTypeByFilename(data.files[0].name) };
      }
    };

    return renderUpload(localOptions);
  }

  function renderUpload(additionalOptions) {
    var $element = window.ST.renderImagePlaceholder("empty");

    $element.showMessage(ST.t("listings.form.images.select_file"));
    $element.fileupload.show();

    var fileuploadDefaultOptions = {
      dataType: 'text', // Browsers without XHR fileupload support do not support other dataTypes than text
      dropZone: $element.container,
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
      imageMaxWidth: opts.originalImageWidth,
      imageMaxHeight: opts.originalImageHeight,
      loadImageMaxFileSize: opts.maxImageFilesize,
      autoUpload: false, // We want to control this ourself
      messages: {
        acceptFileTypes: ST.t("listings.form.images.accepted_formats"),
        maxFileSize: ST.t("listings.form.images.file_too_large"),
      },
      // Enable image resizing, except for Android and Opera,
      // which actually support image resizing, but fail to
      // send Blob objects via XHR requests:
      disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent)
    };

    var fileuploadOptions = _.extend(fileuploadDefaultOptions, additionalOptions);

    $element.fileupload.fileupload(fileuploadOptions).on('dragenter', function() {
      $(this).addClass('hover');
    }).on('dragleave', function() {
      $(this).removeClass('hover');
    });

    var fileAdded = $element.fileupload.asEventStream('fileuploadadd', function(e, data) { return data; });
    return {element: $element, stream: fileAdded};
  }

  function renderUploading(data) {
    var $element = window.ST.renderImagePlaceholder("uploading");

    $element.container.addClass("fileupload-uploading");

    var filePreprocessed = Bacon.fromPromise(data.process());

    var fileSubmitted = filePreprocessed.flatMap(function(fileinputData) {

      var submit = fileinputData.submit();

      Bacon.fromPoll(100, function() {
        var progress = fileinputData.progress();
        var percentage = Math.floor((progress.loaded / progress.total) * 100) + "%";
        var events = [new Bacon.Next(percentage)];

        if (progress.loaded === progress.total) {
          events.push(new Bacon.End());
        }

        return events;

      }).onValue(function(percentageLoaded) {
        $element.showMessage(percentageLoaded);
      });

      return Bacon.fromBinder(function(sink) {
        submit.done(function(result) {
          sink(new Bacon.Next([fileinputData, result]));
        }).fail(function() {
          sink(new Bacon.Error());
        }).always(function() {
          sink(new Bacon.End());
        });

        return function() {
           // unsub functionality here, this one's a no-op
        };
      });
    });

    var fileSubmittedS3 = fileSubmitted.filter(function() { return directUploadToS3; });
    var fileSubmittedLocal = fileSubmitted.filter(function() { return !directUploadToS3; });

    // File is saved at the same time it's submitted to local server
    var fileSavedLocal = fileSubmittedLocal.map(function(values) {
      return _.last(values);
    });

    var fileSavedS3 = fileSubmittedS3.flatMap(function(values) {
      return Bacon.once(s3ImageOptions(_.first(values))).ajax();
    });

    var fileSaved = Bacon.mergeAll(fileSavedLocal, fileSavedS3).map(JSON.parse);

    function imageUploadingFailed() {
      $element.showMessage(ST.t("listings.form.images.uploading_failed"));
    }

    fileSaved.onError(imageUploadingFailed);

    fileSaved.onValue(function(result) {
      $element.showMessage(ST.t("listings.form.images.processing"), ST.t("listings.form.images.this_may_take_a_while"));
      $element.setListingId(result.id);
    });

    var filePostprocessed = fileSaved.flatMap(function(result) {
      return ST.utils.baconStreamFromAjaxPolling({url: result.urls.status}, function(pollingResult) {
        return !pollingResult.processing && pollingResult.downloaded;
      });
    });

    filePreprocessed.onError(imageUploadingFailed);

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

    function s3ImageOptions(data) {
      var path = opts.s3UploadPath + valueFromFormData(data.formData, "key");
      var filename = data.files[0].name;

      return {
        type: "PUT",
        url: opts.saveFromUrl,
        data: {
          filename: filename,
          path: path
        }
      };
    }

    filePostprocessed.onValue(function() {
      elementManager.removeUploading($element.container);
    });

    return {element: $element, stream: filePostprocessed};
  }

  function renderPreview(listing) {
    var $element = window.ST.renderImagePlaceholder("preview");
    $element.setListingId(listing.id);

    $element.showPreview(listing.images.thumb);
    $element.showRemove();

    $element.container.addClass("fileupload-preview");

    var removeClicked = $element.removeLink.asEventStream('click').doAction(".preventDefault");

    removeClicked.onValue(function() {
      $element.hideRemove();
      $element.showMessage(ST.t("listings.form.images.removing"));
    });

    var ajaxRequest = removeClicked.map(function() {
      return {
        url: listing.urls.remove,
        type: 'DELETE'
      };
    });

    var ajaxResponse = ajaxRequest.ajax();

    ajaxResponse.onValue(function() {
      elementManager.removePreview($element.container);
    });

    return {element: $element, stream: ajaxResponse};
  }
};

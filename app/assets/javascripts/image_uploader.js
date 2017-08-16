window.ST = window.ST || {};

/**
  Returns a new element for image uploading/preview
*/
window.ST.renderImagePlaceholder = function() {
  var template = $("#new-image-tmpl").html();
  var element = $(template);
  var previewImage = $("img", element).hide();
  var removeLink = $('.fileupload-preview-remove-image', element);
  var fileupload = $('.fileupload', element);
  var texts = $('.fileupload-text-container', element);
  var textsOriginalDisplay = texts.css('display');
  var normalText = $(".fileupload-text", element);
  var smallText = $(".fileupload-small-text", element);
  var listingId = $(".listing-image-id", element);
  var errorText = $(".fileupload-error-text", element);

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

  function showError(msg) {
    normalText.hide();
    smallText.hide();
    errorText.show();
    errorText.text(msg);
  }

  function hideError() {
    errorText.hide();
    normalText.show();
    smallText.show();
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
    showError: showError,
    hideError: hideError
  };
};

/**
  Element manager manages the order of the elements in the
  image uploading component.

  Since it's the only component that is aware of the element
  position in the component, it also ensures that the last
  empty element shows text "Add more"
*/
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

  function changeStateToProcessing(uploadingElement, processingElement) {
    function swap(ref, replacement, input) {
      return (ref === input) ? replacement : input;
    }

    uploadings = _.map(uploadings, _.partial(swap, uploadingElement, processingElement));
    uploadingElement.after(processingElement);
    uploadingElement.remove();
  }

  function removeUploading(element) {
    element.remove();
    uploadings = _.without(uploadings, element);
  }

  // Notice! Unlike the other functions, this one takes the
  // whole element, not only the DOM element (container)
  function addEmpty(element) {
    var last = _.last(empties);
    if(last) {
      last.showMessage(ST.t("listings.form.images.select_file"));
    }
    element.showMessage(ST.t("listings.form.images.add_more"));
    $container.append(element.container);
    empties.push(element);
  }

  function removeEmpty() {
    var elementToRemove = empties.pop();
    elementToRemove.container.remove();
    _.last(empties).showMessage(ST.t("listings.form.images.add_more"));
  }

  return {
    addEmpty: addEmpty,
    addUploading: addUploading,
    addPreview: addPreview,
    removeEmpty: removeEmpty,
    removeUploading: removeUploading,
    removePreview: removePreview,
    changeStateToProcessing: changeStateToProcessing
  };
};

window.ST.imageUploader = function(listings, opts) {
  var elementManager = ST.imageUploadElementManager($("#image-uploader-container"));
  var directUploadToS3 = !!opts.s3Fields && !!opts.s3UploadPath;

  var extraPlaceholders = 2;

  var renderS3Uploader = (function() {
    var i = 0;
    return function() {
      var s3Options = {
        url: opts.s3UploadPath,
        paramName: "file",
        submit: function(e, data) {
          var filename = ST.utils.filenameToURLSafe(data.files[0].name);
          data.formData = _.extend({}, opts.s3Fields, {
            "Content-Type": ST.utils.contentTypeByFilename(data.files[0].name),
            key: opts.s3Fields.key.replace("${index}", i++).replace("${filename}", filename)
          });
        }
      };

      return renderUpload(s3Options);
    };
  })();

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

  var extraPlaceholdersNeeded = listings.length < extraPlaceholders ? extraPlaceholders - listings.length : 0;
  var imageSelected = _().range(extraPlaceholdersNeeded + 1).map(function() {
    return directUploadToS3 ? renderS3Uploader() : renderLocalUploader();
  }).each(function(rendered) {
    elementManager.addEmpty(rendered.element);
  }).map(function(rendered) {
    return rendered.stream;
  }).reduce(function(a, b) {
    return a.merge(b);
  });

  var uploadingRendered = imageSelected.map(function(data) {
    return renderUploading(data);
  });

  var processingRendered = uploadingRendered.flatMap(function(rendered) {
    var processingRenderedResult = rendered.stream.map(renderProcessing);

    processingRenderedResult.onValue(function(renderResult) {
      elementManager.changeStateToProcessing(rendered.element.container, renderResult.element.container);
    });

    return processingRenderedResult;
  });

  uploadingRendered.onValue(function(rendered) {
    elementManager.addUploading(rendered.element.container);
  });

  var newImageProcessingDone = processingRendered.flatMap(function(rendered) {
    return rendered.stream;
  });

  var processingListings = _.filter(listings, function(listing) { return !listing.ready; });
  var readyListings = _.filter(listings, function(listing) { return listing.ready; });

  var processingDone = _(processingListings).map(function(listing) {
    return renderProcessing(listing);
  }).each(function(rendered) {
    elementManager.addUploading(rendered.element.container);
  }).map(function(rendered) {
    return rendered.stream;
  }).reduce(function(a, b) {
    return a.merge(b);
  });

  var previewRemoved = _(readyListings).map(function(listing) {
    return renderPreview(listing);
  }).each(function(rendered) {
    elementManager.addPreview(rendered.element.container);
  }).map(function(rendered) {
    return rendered.stream;
  }).reduce(function(a, b) {
    return a.merge(b);
  });

  var imageUploaded = processingDone ? newImageProcessingDone.merge(processingDone) : newImageProcessingDone;

  var numberOfProcessingImages = imageUploaded.map(function() { return -1; })
        .merge(processingRendered.map(function() { return 1; }))
        .scan(processingListings.length, function(a, b) { return a + b; });

  var numberOfLoadingImages = uploadingRendered.map(function() { return 1; })
        .merge(processingRendered.map(function() { return -1; }))
        .scan(0, function(a, b) { return a + b; });

  var status = Bacon.combineTemplate(
    {loading: numberOfLoadingImages, processing: numberOfProcessingImages });

  var successfullyUploaded = imageUploaded.filter(function(value) {
    return value.ready && !value.errored;
  });

  var newPreviewRendered = successfullyUploaded.map(function(listing) {
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
    elementManager.addEmpty(rendered.element);
  });

  imageSelected.filter(maybeNeedsRemovePlaceholder).onValue(function() {
    elementManager.removeEmpty();
  });

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

    var fileAdded = $element.fileupload.asEventStream('fileuploadadd', function(e, data) {
      return [$(this), data];
    });
    var fileValidated = fileAdded.flatMap(function(inputAndData) {
      var input = inputAndData[0];
      var data = inputAndData[1];

      return Bacon.fromPromise(input.fileupload('process', data));
    });

    fileValidated.onError(function(data) {
      $element.showError(data.files[0].error);
    });

    fileValidated.onValue(function() {
      $element.hideError();
    });

    return {element: $element, stream: fileValidated};
  }

  function renderUploading(data) {
    var $element = window.ST.renderImagePlaceholder();
    $element.fileupload.remove();

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

    var fileSavedS3 = fileSubmittedS3.flatMap(function(values) {
      return Bacon.once(s3ImageOptions(_.first(values))).ajax();
    });

    var fileSaved = Bacon.mergeAll(fileSavedLocal, fileSavedS3).map(JSON.parse);

    function imageUploadingFailed() {
      $element.showMessage(ST.t("listings.form.images.uploading_failed"));
    }

    fileSaved.onError(imageUploadingFailed);

    filePreprocessed.onError(imageUploadingFailed);

    return {element: $element, stream: fileSaved};
  }

  function renderProcessing(listing) {
    var $element = window.ST.renderImagePlaceholder();
    $element.fileupload.remove();

    $element.container.addClass("fileupload-uploading");

    $element.showMessage(ST.t("listings.form.images.processing"), ST.t("listings.form.images.this_may_take_a_while"));
    $element.setListingId(listing.id);

    var filePostprocessingDone = ST.utils.baconStreamFromAjaxPolling({url: listing.urls.status}, function(pollingResult) {
      return pollingResult.ready || pollingResult.errored;
    });

    var filePostprocessingSuccessful = filePostprocessingDone.filter(function(value) {
      return value.ready && !value.errored;
    });

    var filePostprocessingError = filePostprocessingDone.filter(function(value) {
      return value.errored;
    });

    filePostprocessingSuccessful.onValue(function() {
      elementManager.removeUploading($element.container);
    });

    filePostprocessingError.onValue(function() {
      $element.showMessage(ST.t("listings.form.images.image_processing_failed"));
    });

    return {element: $element, stream: filePostprocessingDone};
  }

  function renderPreview(listing) {
    var $element = window.ST.renderImagePlaceholder();
    $element.fileupload.remove();

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

  function reorderImages() {
    var ordered = [];
    $(".listing-images .listing-image-id").each(function(){
      if(this.value) {
        ordered.push(this.value);
      }
    });
    $.ajax({type: "PUT", url:  opts.reorderUrl, data: {ordered_ids: ordered.join(",")} });
  }

  function localReorderImages() {
    var ordered = [];
    $(".listing-images .listing-image-id").each(function(){
      if(this.value) {
        ordered.push(this.value);
      }
    });
    $("#listing_ordered_images").val(ordered.join(","));
  }

  function unfocusMe() {
    $(":text").blur();
  }
  if (opts.reorderUrl) {
    $(".listing-images").sortable({start: unfocusMe, stop: reorderImages, items: '.fileinput-button:not(:last-child)' });
  } else {
    $(".listing-images").sortable({start: unfocusMe, stop: localReorderImages, items: '.fileinput-button:not(:last-child)'});
  }

  return status;
};

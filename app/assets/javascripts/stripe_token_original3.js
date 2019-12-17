// contains async-await
var stripeUploadFiles = function(options) {
  var uploadFiles = async function() {
    var fileData = {};
    for (var itemKey in options.fileElements) {
      fileElement = options.fileElements[itemKey];
      var fileForm = new FormData();
      var additionalFileForm = new FormData(), additionalFileData = null;
      fileForm.append('file', fileElement);
      fileForm.append('purpose', 'identity_document');
      var fileResult = await fetch('https://uploads.stripe.com/v1/files', {
        method: 'POST',
        headers: {'Authorization': 'Bearer ' + stripeApi._apiKey},
        body: fileForm,
      });
      fileData[itemKey] = await fileResult.json();
    }
    return fileData;
  }

  uploadFiles().then(function(data) {
    options.fileCallback(data);
  });
}

var stripeToken = async function(options) {
  var result = await stripeApi.createToken('account', omitNullDeep(options.data));
  if (result.token) {
    options.success(result.token);
  }
  if (result.error) {
    options.error(result.error);
  }
}


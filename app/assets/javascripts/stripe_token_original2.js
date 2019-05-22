// contains async-await
var stripeToken = async function(options) {
  if (options.verify) {
    var fileForm = new FormData();
    fileForm.append('file', options.fileElement);
    fileForm.append('purpose', 'identity_document');
    var fileResult = await fetch('https://uploads.stripe.com/v1/files', {
      method: 'POST',
      headers: {'Authorization': 'Bearer ' + stripeApi._apiKey},
      body: fileForm,
    });
    var fileData = await fileResult.json();
    if (fileData.id) {
      options.fileCallback(fileData);
    }
  }
  var result = await stripeApi.createToken('account', omitNullDeep(options.data));
  if (result.token) {
    options.success(result.token);
  }
  if (result.error) {
    options.error(result.error);
  }
}


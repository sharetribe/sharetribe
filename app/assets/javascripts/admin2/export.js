function initializeExportPolling(options) {
    var element = $('#export-as-csv');
    var oldHtml = $(element).html();
    element.html(options.loading);

    function check_status(options) {
        $.get(options.pollingUrl, function(data) {
            if (data.status === 'finished') {
                element.html(oldHtml);
                clearInterval(timerId);
                downloadURI(data.url, 'export.csv');
            } else if (data.status === 'error') {
                element.html(oldHtml);
                clearInterval(timerId);
            }
        });
    }

    var timerId = setInterval(function() { check_status(options); }, 1000);

    var downloadURI = function (uri, name) {
        var link = document.createElement('a');
        link.download = name;
        link.href = uri;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        link = null;
    };
}

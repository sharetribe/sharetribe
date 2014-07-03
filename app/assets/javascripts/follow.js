$(document).ready(
    function() {
        $("body").on(
            "ajax:complete", function(event, xhr) {
                var target = $(event.target);
                if (target.hasClass("follow-button")) {
                    var new_button_container = $(xhr.responseText);

                    // Work around "Unfollow" showing up too soon
                    $(".button-hoverable", new_button_container).addClass("button-disable-hover");
                    new_button_container.on(
                        "mouseout", function() { 
                            setTimeout(
                                function() { 
                                    $(".button-disable-hover", new_button_container).removeClass("button-disable-hover"); 
                                }, 500); 
                        });

                    target.parents(".follow-button-container:first").replaceWith(new_button_container);
                }
            }
        );
    }
);
$(function() {
    $(document).on('change', '.change-status-filter-transaction', function () {
        $(this).parents('form').submit();
    });

    $('#buyer .breakdown-detailed, #buyer .breakdown-trigger-hide').hide();

    $("#buyer .breakdown-trigger-show").click(function(){
        $("#buyer .breakdown-detailed, #buyer .breakdown-trigger-hide").show();
        $("#buyer .breakdown-trigger-show, #buyer .breakdown-overview .breakdown-total-price").hide();
    });

    $("#buyer .breakdown-trigger-hide").click(function(){
        $("#buyer .breakdown-detailed, #buyer .breakdown-trigger-hide").hide();
        $("#buyer .breakdown-trigger-show, #buyer .breakdown-overview .breakdown-total-price").show();
    });

    $('#seller .breakdown-detailed, #seller .breakdown-trigger-hide').hide();

    $("#seller .breakdown-trigger-show").click(function(){
        $("#seller .breakdown-detailed, #seller .breakdown-trigger-hide").show();
        $("#seller .breakdown-trigger-show, #seller .breakdown-overview .breakdown-total-price").hide();
    });

    $("#seller .breakdown-trigger-hide").click(function(){
        $("#seller .breakdown-detailed, #seller .breakdown-trigger-hide").hide();
        $("#seller .breakdown-trigger-show, #seller .breakdown-overview .breakdown-total-price").show();
    });

    $('#marketplace .breakdown-detailed, #marketplace .breakdown-trigger-hide').hide();

    $("#marketplace .breakdown-trigger-show").click(function(){
        $("#marketplace .breakdown-detailed, #marketplace .breakdown-trigger-hide").show();
        $("#marketplace .breakdown-trigger-show, #marketplace .breakdown-overview .breakdown-total-price").hide();
    });

    $("#marketplace .breakdown-trigger-hide").click(function(){
        $("#marketplace .breakdown-detailed, #marketplace .breakdown-trigger-hide").hide();
        $("#marketplace .breakdown-trigger-show, #marketplace .breakdown-overview .breakdown-total-price").show();
    });
});

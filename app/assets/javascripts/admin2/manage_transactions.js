$(function() {
    $(document).on('change', '.change-status-filter-transaction', function () {
        $(this).parents('form').submit();
    });

    $('#buyer .breakdown-detailed, #buyer .breakdown-trigger-hide').hide();

    $("#buyer .breakdown-overview").click(function(){
        $('#buyer .breakdown-detailed').slideToggle(200);
        $("p", this).toggleClass("breakdown-trigger-show breakdown-trigger-hide");
    });

    $('#seller .breakdown-detailed, #seller .breakdown-trigger-hide').hide();

    $("#seller .breakdown-overview").click(function(){
        $('#seller .breakdown-detailed').slideToggle(200);
        $("p", this).toggleClass("breakdown-trigger-show breakdown-trigger-hide");
    });

    $('#marketplace .breakdown-detailed, #marketplace .breakdown-trigger-hide').hide();

    $("#marketplace .breakdown-overview").click(function(){
        $('#marketplace .breakdown-detailed').slideToggle(200);
        $("p", this).toggleClass("breakdown-trigger-show breakdown-trigger-hide");
    });
});

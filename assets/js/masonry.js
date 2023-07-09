$(window).on("load", function () {
    $('.grid').masonry({
        itemSelector: ".grid-item",
        columnWidth: ".grid-sizer",
        percentPosition: true
        });
});

$('.grid').on('layoutComplete', function (event, laidOutItems) {
    var grid = $(this);
    $(this).find('.grid-item-notes').each(function () {
        imgHeight = grid.find('.grid-item-carousel').height();
        proHeight = grid.find('.grid-item-profile').height();

        if (imgHeight > proHeight) {
            $(this).css('width', '100%');
        }

    });
});

$(window).on("resize", function () {
    $('.grid').masonry.layout();
});

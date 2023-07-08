$(window).on("load", function () {
    $('.grid').masonry({
        itemSelector: ".grid-item",
        columnWidth: ".grid-sizer",
        percentPosition: true
        });
});
$(window).on("load", function () {
  var $grid = $(".isogrid").isotope({
    itemSelector: '.element-item',
    layoutMode: 'fitRows',
    filter: '.metal'
  });
  $grid.css("height", "auto");


  $('.filter-btn').on( 'click', function() {
    var filterValue = $(this).attr('data-filter');
    console.log(filterValue);
    $grid.isotope({ filter: filterValue });
    $grid.css("height", "auto");
  });
});

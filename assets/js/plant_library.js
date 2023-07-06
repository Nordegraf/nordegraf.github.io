$(document).ready(function(){
    $("#plant-content").load("/plants/all");

    $(".country-button").click(function(){
    var country = $(this).attr("id");
      $("#plant-content").load("/plants/" + country);
      $(".location-button:not(." + country + ")").hide();
      $(".location-button." + country).show();
      $(".country-button").removeClass("clicked");
      $(this).addClass("clicked");
    });


    $(".location-button").addClass("clicked");
    $(".location-button").click(function(){
      var location = $(this).attr("id");
      showContent(location, this);
    });
});

function showContent(filename, button) {
  $("#plant-content").load("/plants/" + filename);
  $(".location-button").removeClass("clicked");
  $(button).addClass("clicked");
}

function hideContent(filename, button) {
  $("#plant-content").load("/plants/" + filename);
  $(".location-button").removeClass("clicked");
  $(button).addClass("clicked");
}
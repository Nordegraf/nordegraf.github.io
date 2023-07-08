---
---

// variables
$.getJSON("{{ "/plants/data.json" | relative_url }}", function(plants) {
  console.log(plants);

  var numPlants = plants.length;
  var first = true;
  var sorted_by = "name";

  $(document).ready(function(){
    // add all plants to page
    var promises = [];
    $.each(plants, function(i, plant) {
      promises[i] = addPlant(i);
    })

    $.when.apply($, promises).done(function() {
      sortByAttr(sorted_by, plants);
    });

    $(".filter-button").click(function(){
        var id = $(this).attr('id');
        var attr = id.split(";")[0];
        var value = id.split(";")[1];

        if (first) {
          $("#plant-content").empty();
          first = false;
        }

        if ($(this).hasClass("clicked")) {
          // hide filters for removed plants
          $(".filter-button."+value).hide();
          $(this).show();

          removePlants(value);
          $(this).removeClass("clicked");

        } else {
          $(this).addClass("clicked");

          // show filters for added plants
          $(".filter-button."+value).show();
          filterrank = parseInt($(this).attr("data-rank"));

          // hide all other filters except those with lower rank clicked first
          thisrank = parseInt($(this).attr("data-rank"));
          clicked = [];
          samerank = 0;
          $(".filter-button.clicked").filter(function() {
            filterrank = parseInt($(this).attr("data-rank"));
            if (filterrank == thisrank) {
              samerank++;
            }
            return filterrank <= thisrank;
          }).each(function() {
            clicked.push($(this).attr("id").split(";")[1]);
          });

          // hide all plants if no filters of same rank are clicked
          if (samerank == 1) {
            $(".plant").hide();
          }

          query = ".filter-button:not(."+clicked.join("):not(.")+")";
            $(query).filter(function() {
              thisrank = parseInt($(this).attr("data-rank"));
              return thisrank > filterrank;
            }).hide();


          value = value.replace(/_/g, " ");
          var promises = addPlants(attr, value, plants);
          $.when.apply($, promises).done(function() {
            sortByAttr(sorted_by, plants);
          });
        }
    });

    $(".sort-button").click(function(){
      sorted_by = $(this).attr("id");
      sortByAttr(sorted_by, plants);
    });
  });
});

function sortByAttr(attr, plants) {
  // sort by attr with jquery
  $("#plant-content .plant").sort(function(a, b) {
    var ida = $(a).attr("id");
    var idb = $(b).attr("id");

    return plants[ida][attr].localeCompare(plants[idb][attr]);
  }
  ).each(function() {
    var elem = $(this);
    elem.remove();
    $(elem).appendTo("#plant-content");
  });
}


function removePlants(attr) {
  $(".plant").each(function() {
    if ($(this).hasClass(attr)) {
      $(this).remove();
    }
  });
}

function addPlants(attr, value, plants) {
    // search through data for plants with attr
    // add them and wait for them to be added
    var promises = [];

    for (var i = 0; i < plants.length; i++) {
      if (plants[i][attr].includes(value)) {
        // check if hidden
        if (plants[i]["hide"]) {
          continue;
        }
        promises.push(addPlant(i));
      }
    }

    return promises;
}

function addPlant(id) {
  return $.get("/plants/"+id+".html", function(data) {
    $("#plant-content").append(data);
  }).promise();
}

function switchButtonStyle(button) {
  if (button.hasClass("clicked"))
    button.removeClass("clicked");
  else
    button.addClass("clicked");
}
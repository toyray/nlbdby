var BooksController = Paloma.controller('Books');

BooksController.prototype.index = function() {
  $("tbody").on("rated", ".responsive-rater", function(e){
    var id = $(this).data("rater-id"); 
    var rating = $(this).data("rater-value");

    $.post('/books/' + id + '/rate.json', { rating: rating });
  });

  $("#js-queue-all").on("click", function() {
    $(".js-queue").click();
  });
};

BooksController.prototype.show = function() {
  $(".responsive-rater").on("rated", function(e){
    var id = $(this).data("rater-id");
    var rating = $(this).data("rater-value");

    $.post('/books/' + id + '/rate.json', { rating: rating });
  });
};


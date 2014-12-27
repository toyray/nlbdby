var BooksController = Paloma.controller('Books');

BooksController.prototype.index = function() {
  $(".responsive-rater").on("rated", function(e){
    var id = $(this).data("rater-id"); 
    var rating = $(this).data("rater-value");

    $.post('/books/' + id + '/rate.json', { rating: rating });
  });
};

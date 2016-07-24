$(document)
  .one('focus.textarea', '.autoExpand', function(){
    var savedValue = this.value;
    this.value = '';
    this.baseScrollHeight = this.scrollHeight;
    this.value = savedValue;
  })
  .on('input.textarea', '.autoExpand', function(){
    var minRows = this.getAttribute('data-min-rows')|0,
      rows;
    this.rows = minRows;
    rows = Math.ceil((this.scrollHeight - this.baseScrollHeight) / 16);
    this.rows = minRows + rows;
  });

$("#bastardize").click(function() {
  $("#loader").removeClass("hidden");
  $("#result").addClass("hidden");
  $("#result").removeClass("flipped");
  $.ajax({
    url: "/bastardize",
    data: {sentence: $("#sentence").val()}
  }).done(function(data) {
    $("#loader").addClass("hidden");
    $("#result").text(data);
    $("#result").removeClass("hidden");
    if (Math.random() < 0.2) {
      $("#result").addClass("flipped");
    }
  });
});

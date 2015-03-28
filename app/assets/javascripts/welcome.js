$(function () {
  
  // Send user to chosen repository page
  $('#select-repo button').on('click', function(e) {
    window.location.href = '/repositories/' + $(e.currentTarget).prev('select').val();
  });
});
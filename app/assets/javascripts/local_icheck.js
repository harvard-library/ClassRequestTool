$(function () {
  var style_checkboxes = function() {
    $('.checkbox input').iCheck({
      checkboxClass: 'icheckbox_square-blue',
      increaseArea: '20%'
    });
  };
  
  $('.checkbox input').iCheck({
    checkboxClass: 'icheckbox_square-blue',
    increaseArea: '20%'
  });
  $('body').on('click', '.add_fields', function() {
      setTimeout(function() {
        style_checkboxes();
      }, 50);
  });
  $(document).ajaxSuccess(style_checkboxes());
});

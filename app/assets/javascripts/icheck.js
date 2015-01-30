$(function () {
  $('.checkbox input').iCheck({
    checkboxClass: 'icheckbox_flat',
    increaseArea: '20%'
  });
  $(document).ajaxSuccess(function() {
    $('.checkbox input').iCheck({
      checkboxClass: 'icheckbox_flat',
      increaseArea: '20%'
    });
  });
});

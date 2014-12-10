$(function () {
  $('.toggle-notification-status').click(function(e) {
    $.get('/admin/notifications/toggle', null, function(status) {
      console.log(status)
      $('span.notification-status').text(status);
    });
  });
});
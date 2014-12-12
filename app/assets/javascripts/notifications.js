$(function () {
  $('.toggle-notification-status').click(function(e) {
    $.get('/admin/notifications/toggle', null, function(status) {
      $('div.notifications-status').removeClass('ON OFF').addClass(status);
      $('div.notifications-status b').text(status);
    });
  });
});
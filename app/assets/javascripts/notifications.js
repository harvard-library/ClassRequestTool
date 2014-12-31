$(function () {
  $('.toggle-notification-status').click(function(e) {
    $.get('/admin/notifications/toggle', null, function(status) {
      $('div.notifications-status').removeClass('ON OFF').addClass(status);
      $('div.notifications-status b').text(status);
      if (status == 'ON') {
        $('button.toggle-notification-status').removeClass('btn-warning').addClass('btn-danger').text('Turn notifications OFF');
      } else {
        $('button.toggle-notification-status').removeClass('btn-danger').addClass('btn-warning').text('Turn notifications ON');
      }
    });
  });
});
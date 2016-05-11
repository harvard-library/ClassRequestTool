$(function () {
  $('.toggle-notification-status').click(function(e) {
    $.get('/admin/notifications/toggle', null, function(status) {
      $('div.notifications-status').removeClass('ON OFF').addClass(status.class);
      $('div.notifications-status b').text(status.label);
      if (status.class == 'ON') {
        $('button.toggle-notification-status').removeClass('btn-warning').addClass('btn-danger').text('GO TO TEST MODE');
      } else {
        $('button.toggle-notification-status').removeClass('btn-danger').addClass('btn-warning').text('SEND NORMALLY');
      }
    });
  });
});
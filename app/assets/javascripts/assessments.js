$(function () {
  $('#assessment-table-current button[data-toggle="popover"]').popover();
  $('#assessment-table-current').on('click', 'button[data-toggle="popover"]', function (e) {
    $('#assessment-table-current button[data-toggle="popover"]').not(e.target).popover('hide');
  })
});

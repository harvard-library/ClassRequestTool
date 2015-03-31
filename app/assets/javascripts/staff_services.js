$(function () {
  $('#staff_service_global').on('ifChecked', function(e) {
    $('#staff_service_repositories_input input').iCheck('check');
  });
  $('#staff_service_global').on('ifUnchecked', function(e) {
    $('#staff_service_repositories_input input').iCheck('uncheck');
  });
});
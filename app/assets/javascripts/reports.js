$(function() {
  $('.datepicker').datepicker();
  $('.highcharts-graph').each(function() {
    var graph = { id: $(this).attr('id') }
    $.getJSON('/admin/create-graph', graph, function(data) {
        if (typeof data.series === undefined) {
          $('#' + data.id).highcharts(data.options)
        } else {
          $('#' + data.id).text("(NO DATA)");
        }
    });
  });
  
  $('.report-toggle').change(function() {
    if (this.checked) {
      $('input.include-report').prop('checked', this.checked);
    } else {
      $('input.include-report').prop('checked', false);
    }
  });
});
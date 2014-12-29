$(function() {
  $('.highcharts-graph').each(function() {
    var graph = { id: $(this).attr('id') }
    $.getJSON('/admin/create-graph', graph, function(data) {
        $('#' + data.id).highcharts(data.options)
    });
  });
});
$(function() {
  var crimson = '#A51C30';
  var ink = '#1E1E1E';
  var mortar = '#8C8179';
  var parchment = '#F3F3F1';
  var slate = '#8996A0';
  var shade = '#BAC5C6';
  var indigo = '#293352';
  var bluebonnet = '#4E84C4';
  var ivy = '#52854C';
  var pear = '#C3D7A4';
  var saffron = '#D16103';
  var creme = '#F4EDCA';
  var gold = '#C4961A';
  var lemon = '#FFDB6D';
  var options = { "colors": [crimson, saffron, pear, bluebonnet, parchment] }
  $('.datepicker').datepicker();
  $('.highcharts-graph').each(function() {
    var graph = { id: $(this).attr('id') }
    $.getJSON('/admin/create-graph', graph, function(data) {
        console.log(typeof data.options.series)
        if (typeof data.options.series === undefined) {
          $('#' + data.id).text("(NO DATA)");
        } else {
          $('#' + data.id).highcharts($.extend({},data.options, options))
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
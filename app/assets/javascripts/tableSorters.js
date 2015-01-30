$(document).ready(function(){    
  var $tables = $('table.sortable')
 
  var tablesorterDefaults = {
    theme: 'bootstrap',
    widgets: ['uitheme', 'filter'],
    icons: 'glyphicon glyphicon-{name}',
    headerTemplate: "{content} {icon}",
    widthFixed: true,
    widgetOptions: {
      uitheme: 'bootstrap',
      filter_columnFilters: true,
      filter_placeholder: { search: 'Filter...' }
     }
  };
  
  var pagerDefaults = {
    removeRows: false, 
    output: "page {page} of {filteredPages}", 
    pagesize: 10
  }
  
  $.each($tables, function(i) {
    var tableId = $(this).attr('id');
    
    // Add text extraction for first meeting date columns
    var textExtractions = {}
    var col = $('table').find('th').index($('th.first-class-meeting'));
    if (col) {
      textExtractions[col] = function(node) {
        return $(node).find('.time').text().replace('@', ' ');
      }
      var ts_options = $.extend(true, tablesorterDefaults, { textExtraction: textExtractions });
    }
    var pg_options = $.extend(true, pagerDefaults, { container: $('.pager-' + tableId) })

    if ($(this).hasClass('2-up')) {
      pg_options = $.extend(true, pagerDefaults, { positionFixed: false });
    }

    $(this).tablesorter(ts_options);
    $(this).tablesorterPager(pg_options);
  });
});
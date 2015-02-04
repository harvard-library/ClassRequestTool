$(document).ready(function(){    
  var $tables = $('table.sortable')
 
  var tablesorterOptions = {
    theme: 'bootstrap',
    widgets: ['uitheme', 'filter'],
    icons: 'glyphicon glyphicon-{name}',
    headerTemplate: "{content} {icon}",
    widthFixed: true,
    widgetOptions: {
      uitheme: 'bootstrap',
      filter_placeholder: { 
        search: 'Filter...',
        from: 'From...',
        to: 'To...'
      }
     }
  };
  
  var pagerOptions = {
    removeRows: false, 
    output: "page {page} of {filteredPages}", 
    pagesize: 10
  }
  
  $.each($tables, function(i) {
    var tableId = $(this).attr('id');
    
    // Add text extraction for first meeting date columns
    var textExtractions = {}
    var filterFormatters = {}
    var col = $(this).find('th').index($('th.first-class-meeting'));
    if (col) {
      textExtractions[col] = function(node) {
        return $(node).find('.time').text().replace('@', ' ').replace('(unscheduled)', '');
      }
      tablesorterOptions = $.extend(true, tablesorterOptions, 
        { 
          widgetOptions: {
            textExtraction: textExtractions, 
          }
        }
      );
    }
    
    //Add range filter for all date columns
    filterFormatters = {}
    $(this).find('th').each(function(i) {
      if ($(this).hasClass('date')) {
        filterFormatters[i] = function($cell, indx) {
          return $.tablesorter.filterFormatter.uiDatepicker( $cell, indx, {
            textFrom: 'From:',
            textTo: 'To:',
            changeMonth: true,
            changeYear: true
          });
        }
      }
    });
    
    tablesorterOptions = $.extend(true, tablesorterOptions, 
      {
        widgetOptions: {
          filter_formatter: filterFormatters
        }
    });
            
    pagerOptions = $.extend(true, pagerOptions, { container: $('.pager-' + tableId) });

    if ($(this).hasClass('2-up')) {
      pagerOptions = $.extend(true, pagerOptions, { positionFixed: false });
    }

    $(this).tablesorter(tablesorterOptions);
    $(this).tablesorterPager(pagerOptions);
  });
});

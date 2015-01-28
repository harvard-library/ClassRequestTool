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
    output: "Page {page}/{filteredPages} (filtered) (Unfiltered: {totalPages})", 
    pagesize: 10
  }
  
  var tsOptions = options.tablesorter || {}
  var pagerOptions = options.pager || {}
  
  $.each($tables, function(i) {
    var tableId = $(this).attr('id');
    var headerControls = {};
    $(this).find('th').each(function(i) {
      if ($(this).hasClass('no-controls')) {
        headerControls[i] = { sorter: false, filter: false };
      }
    });
    var ts_options = $.extend(true, tablesorterDefaults, { headers: headerControls });
//     widgetOptions: {
//        filter_external: '#search-' + tableId,
//     }

    var pg_options = $.extend(pagerDefaults, { container: $('.pager-' + tableId) })
    if ($(this).hasClass('2-up')) {
      pg_options = $.extend(pagerDefaults, { positionFixed: false });
    }
    $(this).tablesorter(ts_options);
    $(this).tablesorterPager(pg_options);
//    $(this).before('Search: <input id="search-' + tableId + '" type="search" class="search" data-column="all" />');
  });
});
    
//   var prepTablesorter = function(name, opts, pg_opts) {
//     var id = '#' + name;
//     var pg_id = '#pager-' + name;
//     var search_id = name + '_search';
// 
//     var ts_defaults = {widgets:['filter'], widgetOptions: {filter_external: '#' + search_id, filter_external: '#' + search_id,}}
//     var pg_defaults = {container: $(pg_id), removeRows: false, output: "{page}/{filteredPages} pages ({totalPages} total)", size: 20}
// 
//     // Create search field
//     $(id).before('<input id="' + search_id + '" type="search" class="search" data-column="all" placeholder="Search" />');
// 
//     $(id).tablesorter($.extend(ts_defaults, opts))
//       .tablesorterPager($.extend(pg_defaults, pg_opts));
//   }
// 
// //   prepTablesorter('course-table-current');
// //   prepTablesorter('course-table-past');
// //   prepTablesorter('course-table-all');
// //   prepTablesorter('attributes-table');
// //   prepTablesorter('repositories-table');
// //   prepTablesorter('rooms-table');
// //   prepTablesorter('users-table');
// //   prepTablesorter('involvement-table');
// //   prepTablesorter('your-unscheduled-table', {}, {positionFixed: false});
// //   prepTablesorter('your-upcoming-table', {}, {positionFixed:false});
// //   prepTablesorter('your-past-table', {}, {positionFixed: false});
// //   prepTablesorter('homeless-table', {}, {positionFixed: false});
// //   prepTablesorter('unassigned-table', {}, {positionFixed: false});
// //   prepTablesorter('roomless-table', {}, {positionFixed: false});
// //   prepTablesorter('your-repo-courses-table', {}, {positionFixed: false});
// //   prepTablesorter('your-to-close-table', {}, {positionFixed: false});
// 
// //   $("#course-table").tablesorter();
// //   $('#assessment-table-current').tablesorter();
// 
//   var tablesorterOptions = {
//     theme: 'bootstrap',
//     widgets: ['uitheme'],
//     icons: 'glyphicon glyphicon-{name}',
//     headerTemplate: "{content} {icon}",
//     widgetOptions: {
//       uitheme: 'bootstrap'
//     }
//   };
//   var pagerOptions = {
//     container: '.pager',
//     size: 10
//   };
//   $('table#course-table-current').tablesorter(tablesorterOptions).tablesorterPager(pagerOptions);
// });

$(document).ready(function(){
  var prepTablesorter = function(name, opts, pg_opts) {
    var id = '#' + name;
    var pg_id = '#pager-' + name;
    var search_id = name + '_search';

    var ts_defaults = {widgets:['filter'], widgetOptions: {filter_external: '#' + search_id, filter_columnFilters: false}}
    var pg_defaults = {container: $(pg_id), removeRows: false, output: "{page}/{filteredPages} pages ({totalPages} total)", size: 20}

    // Create search field
    $(id).before('<input id="' + search_id + '" type="search" class="search" data-column="all" placeholder="Search" />');

    $(id).tablesorter($.extend(ts_defaults, opts))
      .tablesorterPager($.extend(pg_defaults, pg_opts));
  }

  prepTablesorter('course-table-current');
  prepTablesorter('course-table-past');
  prepTablesorter('course-table-all');
  prepTablesorter('attributes-table');
  prepTablesorter('repositories-table');
  prepTablesorter('rooms-table');
  prepTablesorter('users-table');
  prepTablesorter('involvement-table');
  prepTablesorter('your-unscheduled-table', {}, {positionFixed: false});
  prepTablesorter('your-upcoming-table', {}, {positionFixed:false});
  prepTablesorter('your-past-table', {}, {positionFixed: false});
  prepTablesorter('homeless-table', {}, {positionFixed: false});
  prepTablesorter('unassigned-table', {}, {positionFixed: false});
  prepTablesorter('roomless-table', {}, {positionFixed: false});
  prepTablesorter('your-repo-courses-table', {}, {positionFixed: false});
  prepTablesorter('your-to-close-table', {}, {positionFixed: false});

  $("#course-table").tablesorter();
  $('#assessment-table-current').tablesorter();

});

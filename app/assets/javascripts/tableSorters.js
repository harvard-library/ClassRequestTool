$(document).ready(function(){
  var prepTablesorter = function(name, opts, pg_opts) {
    var id = '#' + name;
    var pg_id = '#pager-' + name;

    $(id).tablesorter($.extend({widgets:['filter']}, opts))
      .tablesorterPager($.extend({container: $(pg_id), removeRows: false}, pg_opts));
  }

  prepTablesorter('course-table-current');
  prepTablesorter('course-table-past');
  prepTablesorter('course-table-all');
  prepTablesorter('attributes-table');
  prepTablesorter('locations-table');
  prepTablesorter('repositories-table');
  prepTablesorter('rooms-table');
  prepTablesorter('users-table', {}, {size: 40});
  prepTablesorter('involvement-table');
  prepTablesorter('your-unscheduled-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('your-unscheduled-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('your-upcoming-table', {}, {size: 5, positionFixed:false});
  prepTablesorter('your-past-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('homeless-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('unassigned-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('roomless-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('your-repo-courses-table', {}, {size: 5, positionFixed: false});
  prepTablesorter('your-to-close-table', {}, {size: 5, positionFixed: false});

  $("#course-table").tablesorter();
  $('#assessment-table-current').tablesorter();

});

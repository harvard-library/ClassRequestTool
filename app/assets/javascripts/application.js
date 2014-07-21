// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery-tablesorter/jquery.metadata
//= require jquery-tablesorter/jquery.tablesorter
//= require jquery-tablesorter/jquery.tablesorter.widgets
//= require jquery-tablesorter/addons/pager/jquery.tablesorter.pager
//= require bootstrap
//= require ckeditor/init
//= require_tree .

$(document).ready(function(){
  $("#course-table")
    .tablesorter()
  ;

  $("#course-table-current")
    .tablesorter()
	.tablesorterPager({container: $("#pager-course-table-current")})
  ;
  $("#course-table-past")
    .tablesorter()
	.tablesorterPager({container: $("#pager-course-table-past")})
  ;
  $("#course-table-all")
    .tablesorter()
	.tablesorterPager({container: $("#pager-course-table-all")})
  ;
  $("#attributes-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-attributes-table")})
  ;
  $("#locations-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-locations-table")})
  ;
  $("#repositories-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-repositories-table")})
  ;
  $("#rooms-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-rooms-table")})
  ;
  $("#users-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-users-table"), size: 40})
  ;
  $("#involvement-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-involvement-table")})
  ;


  $("#your-unscheduled-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-unscheduled-table"), size: 5, positionFixed: false})
  ;
  $("#your-upcoming-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-upcoming-table"), size: 5, positionFixed: false})
  ;
  $("#your-past-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-past-table"), size: 5, positionFixed: false})
  ;
  $("#homeless-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-homeless-table"), size: 5, positionFixed: false})
  ;
  $("#unassigned-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-unassigned-table"), size: 5, positionFixed: false})
  ;
  $("#roomless-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-roomless-table"), size: 5, positionFixed: false})
  ;
  $("#your-repo-courses-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-repo-courses-table"), size: 5, positionFixed: false})
  ;
  $("#your-to-close-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-to-close-table"), size: 5, positionFixed: false})
  ;
  $('#assessment-table-current').tablesorter()
});

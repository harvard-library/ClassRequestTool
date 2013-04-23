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
//= require jquery-ui
//= require jquery.ui.datepicker
//= require jquery-tablesorter
//= require_tree .

$(document).ready(function(){
  $('#course_time_choice_1').datetimepicker({
	timeFormat: "hh:mm tt"
  });
  $('#course_time_choice_2').datetimepicker({
	timeFormat: "hh:mm tt"
  });
  $('#course_time_choice_3').datetimepicker({
	timeFormat: "hh:mm tt"
  });	
  $('#course_timeframe').datetimepicker({
	timeFormat: "hh:mm tt"
  });
  $('#course_pre_class_appt').datetimepicker({
	timeFormat: "hh:mm tt"
  });

  $('#course_session_count_input').hide();

  $("#course-table").tablesorter();
  $("#attributes-table").tablesorter();
  $("#locations-table").tablesorter();
  $("#repositories-table").tablesorter();
  $("#rooms-table").tablesorter();
  $("#users-table").tablesorter();

  $("#your-repos-table").tablesorter();
  $("#your-upcoming-table").tablesorter();
  $("#your-past-table").tablesorter();
  $("#homeless-table").tablesorter();
  $("#unassigned-table").tablesorter();
  $("#roomless-table").tablesorter();

});
jQuery(function(){

  $('#course_course_sessions_single_session').change(function() {
	$('#course_session_count_input').hide();
   });
  $('#course_course_sessions_multiple_sessions_same_materials').change(function() {
    $('#course_session_count_input').show();
   });
  $('#course_course_sessions_multiple_sessions_different_materials').change(function() {
    $('#course_session_count_input').show();
   });
});

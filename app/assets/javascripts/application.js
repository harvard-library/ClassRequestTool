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
//= require ckeditor/init
//= require_tree .

$(document).ready(function(){
  $('#your-past').hide();	
	
  $('#course_time_choice_1').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_time_choice_2').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_time_choice_3').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_time_choice_4').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_pre_class_appt_choice_1').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_pre_class_appt_choice_2').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
  $('#course_pre_class_appt_choice_3').datetimepicker({
	timeFormat: "hh:mm tt",
	minDate: 3
  });
	
  $('#course_timeframe').datetimepicker({
	timeFormat: "hh:mm tt"
  });
  $('#course_pre_class_appt').datetimepicker({
	timeFormat: "hh:mm tt"
  });

  $('#course_session_count_input').hide();
  $('#course_time_choice_4_input').hide();
  $('#multiple').hide();
  $('#single').hide();

  $('#course_info_partial').show();
  $('#requester_info_partial').hide();
  $('#involvement_info_partial').hide();
  $('#scheduling_info_partial').hide();
  $('#staff_actions_partial').show();
  $('#submit_course').hide();

  $("#course-table").tablesorter();
  $("#attributes-table").tablesorter();
  $("#locations-table").tablesorter();
  $("#repositories-table").tablesorter();
  $("#rooms-table").tablesorter();
  $("#users-table").tablesorter();
  $("#involvement-table").tablesorter();

  $("#your-repos-table").tablesorter();
  $("#your-unscheduled-table").tablesorter();
  $("#your-upcoming-table").tablesorter();
  $("#your-past-table").tablesorter();
  $("#homeless-table").tablesorter();
  $("#unassigned-table").tablesorter();
  $("#roomless-table").tablesorter();

});
jQuery(function(){
  $('#collapsable').click(function() {
	$('#your-past').toggle(400);
  }).next().hide();

  $('#your-past-header').click(function() {
	$('#your-past').show();
  });	

  $('#course_course_sessions_single_session').change(function() {
	$('#course_session_count_input').hide();
	$('#course_time_choice_4_input').hide();
	$('#multiple').hide();
	$('#single').show();
   });
  $('#course_course_sessions_multiple_sessions_same_materials').change(function() {
    $('#course_session_count_input').show();
	$('#course_time_choice_4_input').show();
	$('#multiple').show();
	$('#single').hide();
   });
  $('#course_course_sessions_multiple_sessions_different_materials').change(function() {
    $('#course_session_count_input').show();
	$('#course_time_choice_4_input').show();
	$('#multiple').show();
	$('#single').hide();
   });

  $('#next_section_1').click(function() {
	$('#course_info_partial').hide();
	$('#requester_info_partial').show();
   });
  $('#next_section_2').click(function() {
	$('#requester_info_partial').hide();
	$('#involvement_info_partial').show();
   });
  $('#next_section_3').click(function() {
	$('#involvement_info_partial').hide();
	$('#scheduling_info_partial').show();
	$('#submit_course').show();
   });
  $('#next_section_4').click(function() {
	$('#scheduling_info_partial').hide();
	$('#staff_actions_partial').show();
	$('#submit_course').show();
   });

  $('#back_section_1').click(function() {
	$('#course_info_partial').show();
	$('#requester_info_partial').hide();
   });
  $('#back_section_2').click(function() {
	$('#requester_info_partial').show();
	$('#involvement_info_partial').hide();
   });
  $('#back_section_3').click(function() {
	$('#involvement_info_partial').show();
	$('#scheduling_info_partial').hide();
	$('#submit_course').hide();
   });
  $('#back_section_4').click(function() {
	$('#scheduling_info_partial').show();
	$('#staff_actions_partial').show();
	$('#submit_course').hide();
   });

  $('#view_section_1').click(function() {
	$('#course_info_partial').show();
	$('#requester_info_partial').hide();
	$('#involvement_info_partial').hide();
	$('#scheduling_info_partial').hide();
	$('#staff_actions_partial').show();
   });
  $('#view_section_2').click(function() {
	$('#requester_info_partial').hide();
	$('#course_info_partial').hide();
	$('#involvement_info_partial').hide();
	$('#scheduling_info_partial').hide();
	$('#staff_actions_partial').show();
   });
  $('#view_section_3').click(function() {
	$('#involvement_info_partial').show();
	$('#course_info_partial').hide();
	$('#requester_info_partial').hide();
	$('#scheduling_info_partial').hide();
	$('#staff_actions_partial').show();
   });
  $('#view_section_4').click(function() {
	$('#scheduling_info_partial').show();
	$('#course_info_partial').show();
	$('#requester_info_partial').hide();
	$('#involvement_info_partial').hide();
	$('#staff_actions_partial').show();
	$('#submit_course').show();
   });

  $('#view_all').click(function() {
	$('#staff_actions_partial').show();
	$('#course_info_partial').show();
	$('#requester_info_partial').show();
	$('#involvement_info_partial').show();
	$('#scheduling_info_partial').show();
	$('#submit_course').show();
   });
});

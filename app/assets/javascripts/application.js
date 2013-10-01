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
//= require jquery-tablesorter/jquery.metadata
//= require jquery-tablesorter/jquery.tablesorter
//= require jquery-tablesorter/jquery.tablesorter.widgets
//= require jquery-tablesorter/addons/pager/jquery.tablesorter.pager
//= require bootstrap
//= require ckeditor/init
//= require_tree .

$(document).ready(function(){	
	
  $('#course_time_choice_1').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_time_choice_2').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_time_choice_3').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_time_choice_4').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_pre_class_appt_choice_1').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_pre_class_appt_choice_2').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
  $('#course_pre_class_appt_choice_3').datetimepicker({
	timeFormat: "hh:mm tt",
	stepMinute: 15,
	hourMin: 9,
	hourMax: 17,
	beforeShowDay: $.datepicker.noWeekends,
	minDate: 3,
	numberOfMonths: 2
  });
	
  $('#course_timeframe').datetimepicker({
	timeFormat: "hh:mm tt",
	numberOfMonths: 2
  });
  $('#course_timeframe_2').datetimepicker({
	timeFormat: "hh:mm tt",
	numberOfMonths: 2
  });
  $('#course_timeframe_3').datetimepicker({
	timeFormat: "hh:mm tt",
	numberOfMonths: 2
  });
  $('#course_timeframe_4').datetimepicker({
	timeFormat: "hh:mm tt",
	numberOfMonths: 2
  });
  $('#course_pre_class_appt').datetimepicker({
	timeFormat: "hh:mm tt",
	numberOfMonths: 2
  });

  $('#course_session_count_input').hide();
  $('#course_time_choice_4_input').hide();
  $('#course_timeframe_2_input').hide();
  $('#course_timeframe_3_input').hide();
  $('#course_timeframe_4_input').hide();
  $('#multiple').hide();
  $('#single').hide();
  $('#multiple_label_1').hide();
  $('#multiple_label_2').hide();
  $('#multiple_label_3').hide();
  $('#multiple_label_4').hide();
  $('#single_label_1').show();
  $('#single_label_2').show();
  $('#single_label_3').show();

  $('#course_info_partial').show();
  $('#requester_info_partial').hide();
  $('#involvement_info_partial').hide();
  $('#scheduling_info_partial').hide();
  $('#staff_actions_partial').show();
  $('#submit_course').hide();

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
	.tablesorterPager({container: $("#pager-users-table")})
  ;
  $("#involvement-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-involvement-table")})
  ;

  $("#your-repos-table").tablesorter()
    .tablesorter()
	.tablesorterPager({container: $("#pager-your-repos-table"), size: 5, positionFixed: false})
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
    $('#multiple_label_1').hide();
    $('#multiple_label_2').hide();
    $('#multiple_label_3').hide();
    $('#multiple_label_4').hide();
    $('#single_label_1').show();
    $('#single_label_2').show();
    $('#single_label_3').show();
   });
  $('#course_course_sessions_multiple_sessions_same_materials').change(function() {
    $('#course_session_count_input').show();
	$('#course_time_choice_4_input').show();
	$('#course_timeframe_2_input').show();
	$('#course_timeframe_3_input').show();
	$('#course_timeframe_4_input').show();
	$('#multiple').show();
	$('#single').hide();
    $('#multiple_label_1').show();
    $('#multiple_label_2').show();
    $('#multiple_label_3').show();
    $('#multiple_label_4').show();
    $('#single_label_1').hide();
    $('#single_label_2').hide();
    $('#single_label_3').hide();
   });
  $('#course_course_sessions_multiple_sessions_different_materials').change(function() {
    $('#course_session_count_input').show();
	$('#course_time_choice_4_input').show();
	$('#course_timeframe_2_input').show();
	$('#course_timeframe_3_input').show();
	$('#course_timeframe_4_input').show();
	$('#multiple').show();
	$('#single').hide();
    $('#multiple_label_1').show();
    $('#multiple_label_2').show();
    $('#multiple_label_3').show();
    $('#multiple_label_4').show();
    $('#single_label_1').hide();
    $('#single_label_2').hide();
    $('#single_label_3').hide();
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


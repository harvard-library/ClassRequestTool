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
});
$(function () {
  $('body').on('click', '[type=datetime-local]:not(.hasDatepicker)', function (e) {
    $(this).datetimepicker({
	    dateFormat: 'yy-mm-dd',
	    timeFormat: "hh:mm tt",
	    buttonImage: "/assets/calendar_icon.png",
	    stepMinute: 15,
	    hourMin: 9,
	    hourMax: 17,
	    beforeShowDay: $.datepicker.noWeekends,
	    minDate: 3,
	    numberOfMonths: 2
    });
    $(this).datetimepicker('show');
  });
});

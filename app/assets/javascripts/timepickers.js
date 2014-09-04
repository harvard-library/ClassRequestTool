$(function () {
  /* Set up global namespace */
  crt = window['crt'] || {}

  crt.setup_datetimepicker = function (input) {
    var $input = $(input);
    var actual = $input.hasClass('actual-date')

    $input.datetimepicker({
      controlType: 'select',
	    dateFormat: 'yy-mm-dd',
	    timeFormat: "hh:mm tt",
	    buttonImage: "/assets/calendar_icon.png",
	    stepMinute: 15,
	    hourMin: 9,
	    hourMax: 17,
	    beforeShowDay: $.datepicker.noWeekends,
	    minDate: (actual ? null : 3),
	    numberOfMonths: 2
    });
  }

  $('body').on('click', 'input.date:not(.hasDatepicker)', function (e) {
    crt.setup_datetimepicker(this);
    $(this).datetimepicker('show');
  });
});

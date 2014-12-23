$(function () {
  /* Set up global namespace */
  crt = window['crt'] || {}

  
  
  crt.setup_datetimepicker = function (input, options) {
    var $input = $(input);
    var actual = $input.hasClass('actual-date')

    $input.datetimepicker(options);
  }

  crt.setup_datepicker = function (input, options) {
    var $input = $(input);
    $input.datepicker(options);
  }

  $('body.c_courses').on('click', ' input.date:not(.hasDatepicker)', function (e) {
    var options = {
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
    }
    crt.setup_datetimepicker(this, options);
    $(this).datetimepicker('show');
  });

  $('body.a_build_report').on('click', ' input.date:not(.hasDatepicker)', function (e) {
    var options = {
      controlType: 'select',
      dateFormat: 'yy-mm-dd',
      buttonImage: "/assets/calendar_icon.png"
    }
    crt.setup_datepicker(this, options);
    $(this).datepicker('show');
  });
});

$(function () {
  /* Set up global namespace */
  crt = window['crt'] || {}

  $('body.c_courses').on('click', ' input.date:not(.hasDatepicker)', function (e) {
    console.log('GOT HERE!');
    var options = {
      controlType: 'select',
      dateFormat: 'yy-mm-dd',
      timeFormat: "hh:mm tt",
      buttonImage: "/assets/calendar_icon.png",
      stepMinute: 15,
      hourMin: 9,
      hourMax: 17,
      beforeShowDay: $.datepicker.noWeekends,
      minDate: ($(this).hasClass('actual-date') ? null : 3),
      numberOfMonths: 2
    }
    $(this).datepicker(options);
    $(this).datetimepicker('show');
  });

  $('body.a_build_report').on('click', ' input.date:not(.hasDatepicker)', function (e) {
    var options = {
      controlType: 'select',
      dateFormat: 'yy-mm-dd',
      buttonImage: "/assets/calendar_icon.png"
    }
    $(this).datepicker(options);
    $(this).datepicker('show');
  });
});

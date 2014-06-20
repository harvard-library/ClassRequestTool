$(function () {
  /* courses#(new|edit) */
  if (window.location.href.match(/courses\/(\d+\/)?(new|edit)(?:\?.+)?/)){
    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
      e.preventDefault();
    });
  }
});

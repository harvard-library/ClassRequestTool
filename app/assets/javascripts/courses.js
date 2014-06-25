$(function () {
  /* courses#(new|edit) */
  if (window.location.href.match(/courses\/(\d+\/)?(new|edit)(?:\?.+)?/)){
    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
      e.preventDefault();
    });

    /* Dynamically add sessions to form */
    $('body').on('click', 'button.add_session', function (e) {
      var index = +$('.session').last().attr('class').match(/session-(\d+)/)[1] + 1;
      var section_index = +$('.section').last().attr('class').match(/section-(\d+)/)[1] + 1;
      e.preventDefault();
      $.get('/courses/session_block',
            {index: index,
             section_index: section_index})
        .done(function (data, status, jqXHR) {
          $('.sessions').append(data);
        });
    });
    $('body').on('click', 'button.add_section', function (e) {
      e.preventDefault();
      var $this_session = $(e.currentTarget).closest('.session')
      var session_i = +$this_session.find('.session_val').val();
      var display_section = 1 + +$this_session.find('.section').last().find('h5').text().match(/\d+/)[0]
      var section_index = 1 + +$('.section').last().attr('class').match(/section-(\d+)/)[1]
      $.get('/courses/section_block', {session_i: session_i, display_section:display_section, section_index:section_index})
        .done(function (data) {
          $this_session.append(data);
        });
    });
  }
});

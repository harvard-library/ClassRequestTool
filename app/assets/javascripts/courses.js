$(function () {
  /* courses#(new|edit) */
  if (window.location.href.match(/courses\/(\d+\/)?(new|edit)(?:\?.+)?/)){
    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      e.preventDefault();

      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
    });

    /* Add sessions to form */
    $('body').on('click', 'button.add_session', function (e) {
      e.preventDefault();

      // Make SURE it can't end up with the same number
      var index = +$('.session').last().attr('class').match(/session-(\d+)/)[1] + 1;
      var section_index = +$('.section').last().attr('class').match(/section-(\d+)/)[1] + 1;

      $.get('/courses/session_block',
            {index: index,
             section_index: section_index})
        .done(function (data, status, jqXHR) {
          $('.sessions').append(data);
        });
    });

    /* Add sections to session in form */
    $('body').on('click', 'button.add_section', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');
      var session_i = +$this_session.find('.session_val').val();
      var display_section = 1 + +$this_session.find('.section').last().find('h5').text().match(/\d+/)[0];
      var section_index = 1 + +$('.section').last().attr('class').match(/section-(\d+)/)[1];

      $.get('/courses/section_block', {session_i: session_i, display_section:display_section, section_index:section_index})
        .done(function (data) {
          $(e.currentTarget).before(data);
        });
    });

    /* Delete sessions, either by adding _destroy input to all sections (for sessions in DB) *
     *   or by deleting session from the page if not.                                        *
     * Always leaves at least one session on the page.                                       */
    $('body').on('click', '.session:not(.deleted) button.delete_session', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');
      var persisted = $this_session.find('.id_val').length;
      var last = ($('.session:not(.deleted)').length == 1)

      if (!last) {
        if (persisted) {
          $this_session.addClass('deleted');
          $this_session.find('button.delete_session').text('+');
          $this_session.find('.section input.id_val').each(function (i, el) {
            var name = $(el).attr('name').replace(/\[id\]$/, '[_destroy]');
            $(el).closest('.section').append('<input type="hidden" class="destroy" name="' + name + '" value="1">');
          });
        }
        else {
          if ($('.session').length > 1) {
            $this_session.remove();
          }
        }
      }
      else {
        alert("Cannot delete last session on page");
      }
    });

    /* Undelete session */
    $('body').on('click', '.session.deleted button.delete_session', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');

      $this_session.find('input.destroy').remove();
      $this_session.removeClass('deleted');
      $this_session.find('button.delete_session').text('-');
    })


    /* Delete sections, either by adding _destroy input (for sections in DB) *
     *   or by deleting section from the page if not.                        *
     * Always leaves at least one section in the session.                    */
    $('body').on('click', '.section:not(.deleted) button.delete_section', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');
      var $section = $(e.currentTarget).closest('.section');

      var persisted = $section.find('.id_val').length;
      var last = ($this_session.find('.section:not(.deleted)').length == 1)
      var name = $section.find('input.id_val').attr('name').replace(/\[id\]$/, '[_destroy]');

      if (!last) {
        if (persisted) {
          $section.addClass('deleted');
          $section.find('button.delete_section').text('+');
          $section.append('<input type="hidden" class="destroy" name="' + name + '" value="1">');
        }
        else {
          $section.remove();
        }
      }
      else {
        alert("Cannot delete last section from session");
      }
    });

    /* Undelete section */
    $('body').on('click', '.section.deleted button.delete_section', function (e) {
      e.preventDefault();

      var $section = $(e.currentTarget).closest('.section');

      $section.find('input.destroy').remove();
      $section.removeClass('deleted');
      $section.find('button.delete_section').text('-');
    });
  }
});

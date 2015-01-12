$(function () {
  var today = new Date();

  /* courses#(new|edit) */
  if ($('body').hasClass('c_courses') &&  ($('body').hasClass('a_edit') || $('body').hasClass('a_new'))) {

    var courseId = $('#info-left').attr('class').replace('course_', '');

    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      e.preventDefault();

      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
    });

    /* Add sessions to form */
    $('body').on('click', 'button.add_session', function (e) {
      e.preventDefault();

      // Make SURE it can't end up with the same number
      var nextSession = parseInt($('.session').last().data('session_index')) + 1;

      $.get('/courses/section_session_block', { to_render: 'session', course_id: courseId, session_index: nextSession}, 
        function (data) {
          $('.sessions').append(data);
        }
      );
    });
    
    /* Add sections to session in form */
    $('body').on('click', 'button.add_section', function (e) {
      e.preventDefault();

      var $thisSession = $(e.currentTarget).closest('.session');
      var nextSection = parseInt($thisSession.find('.section').last().attr('class').match(/section-(.*\d+)/)[1]) + 1
      var session_index = $thisSession.data('session_index');

      $thisSession.find('.section-header').removeClass('hidden');

      $.get('/courses/section_session_block', { to_render: 'section', course_id: courseId, session_index: session_index, section_index: nextSection}, function (data) {
          $thisSession.find('.sections').append(data);
          
          // Set duration of added section to that of first section in this session
          $sessionDurations = $thisSession.find('.session_duration_val');
          $sessionDurations.last().val($sessionDurations.first().val());
        }
      );
    });

    /* Delete sections, either by adding _destroy input (for sections in DB) *
     *   or by deleting section from the page if not.                        *
     * If this is the last section in a session, and that session is not the *
     *   last section on the page, delete that.                    */
    $('body').on('click', '.section:not(.deleted) button.delete', function (e) {
      e.preventDefault();
      
      var deleting = $(this).data('to_delete');
      
      var $thisSession = $(e.currentTarget).closest('.session');
      var $thisSection = $(e.currentTarget).closest('.section');
      
      var persisted;
      if (deleting == 'session') {
        persisted = $thisSession.find('.id_val').length > 0;
      } else {
        persisted = $thisSection.find('.id_val').length > 0;
      }
      
      var numSections = $thisSession.find('.section').length;
      var name;

      // If a session to delete is persisted (i.e. has at least one section in the database), mark all sections for that session for deletion
      // If a section to delete is persisted, mark that section for deletion
      if (persisted) {
        $thisSession.find('.id_val').each(function(i) {
          $section = $(this).closest('.section');
          if ( deleting == 'session' || (deleting == 'section' && $section.data('section_index') == $thisSection.data('section_index'))) {
            name = $section.find('input.id_val').attr('name').replace(/\[id\]$/, '[_destroy]');
            $section.addClass('deleted'); 
            $section.append('<input type="hidden" class="destroy" name="' + name + '" value="1">');
            $section.find('button.delete').text('Restore');
          }
        }); 
      }
      else {
        if (deleting == 'session') {
          $thisSession.remove();
        } else {
          $thisSection.remove();
        }
       }
    });

    /* Undelete section */
    $('body').on('click', '.section.deleted button.delete', function (e) {
      e.preventDefault();

      var undeleting = $(this).data('to_delete');

      var $thisSession = $(e.currentTarget).closest('.session');
      var $thisSection = $(e.currentTarget).closest('.section');
      
      $thisSession.find('input.destroy').each(function(i) {
        $section = $(this).closest('.section');
        if ( undeleting == 'session' || (undeleting == 'section' && $section.data('section_index') == $thisSection.data('section_index'))) {
          $section.find('input.destroy').remove();
          $section.removeClass('deleted');
          $section.find('button.delete').text('Remove');
        }
      });
    });


    /* Prompt user for submission if both backdated and post-dated actual_dates exist, *
     *   deletions excepted.                                                           */
    $('body').on('submit', 'form.formtastic.course', function (e) {
      var backdated = []; var postdated = [];
      var confstring = "You have actual dates in both the past and future, is this correct?\n\n";

      /* We need the datetimepickers definitely set up, so we can call the API function on them
      $('.actual-date:not(.hasDatepicker)').each(function (i, el) { crt.setup_datetimepicker(el) });
      */

      $('.datetime_picker .actual-date')
        .filter(function (i,el) { return $(el).parents('.deleted').length == 0})
        .each(function (i,el) {
          var date = $(el).datetimepicker('getDate');

          if (date < today) {
            backdated.push(date.toString());
          }
          else {
            postdated.push(date.toString());
          }
        });

      if (backdated.length > 0 && postdated.length > 0) {
        confstring += "Past Dates:\n\t" + backdated.join("\n\t") + "\n\n";
        confstring += "Future Dates:\n\t" + postdated.join("\n\t") + "\n";
        if (!confirm(confstring)) {
          e.preventDefault();
        }
      }
    });
  }
  
  /* On index display next section date and make hoverable to show all */
  var indigo = '#293352';
  var normalTextColor = '#434A54';
  $('.section-times ul').each(function() {
    if ($(this).children('li').length > 1) {
      $(this).parent().addClass('multiple');
    }
  });
  $('.section-times.multiple li').hide();
  $('.section-times.multiple ul').each(function() {
    $(this).children('li.future:first').show();
  });
  $('.section-times.multiple').append('<span class="glyphicon glyphicon-th-list"></span>');
  $('.section-times.multiple .glyphicon').mouseenter(
    function() { $(this).siblings().children().slideDown(); $(this).siblings().children('.future').css({'font-weight':'bold', 'color': indigo}); }
  );
  $('.section-times.multiple').mouseleave(
    function() { $(this).children('ul').children('li').not('li.future:first').slideUp(); $(this).children('ul').children('li').css({'font-weight':'normal', 'color':normalTextColor}); }
  );
  
  /* Handle affiliation code on course request form */
  $('#affiliation .affiliation_field').hide();
  $('#affiliation input[type=radio]:checked').val();
  $('#local_' + $('#affiliation input[type=radio]:checked').val()).show();
  if ($('#other_affiliation').val() != '') {
    $('#local_no_or_other').show();
  }
  $('#affiliation input[type=radio]').change(function(e) {
    var selected = $('#affiliation input[type=radio]:checked').val();
    if (selected == 'yes') {
      $('#local_yes').slideDown();
      $('#local_no_or_other').slideUp();
    } else {
      $('#local_yes').slideUp();
      $('#local_no_or_other').slideDown();
      $('#local_affiliation').val(null);
    }
  });
  $('body').delegate('#local_affiliation', 'change', function() {
    if ($(this).val() == 'Other') {
      $('#local_no_or_other').slideDown();
    } else {
      $('#local_no_or_other').slideUp();
      $('#other_affiliation').val('')    
    }
  });
  
  /* Update additional staff list on assigning primary staff contact to course */
  $('#course_primary_contact_id').on('change', function(e) {
    var userId = $(this).val()
    $('input#course_user_ids_' + userId).attr('checked', false).parent().removeClass('checked');
    $('#course_users_input .checkbox').show();
    $('.checkbox input#course_user_ids_' + userId).parent().parent().parent().hide();
  });
});

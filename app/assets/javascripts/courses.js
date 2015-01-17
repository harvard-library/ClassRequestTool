$(function () {

  nextSectionIndex = function() {
    return $('#scheduling_info .section').length;
  }
  thisSessionCount = function() {
    return $('#scheduling_info .session').length
  }
  nextSessionCount = function() {
    return thisSessionCount() + 1;
  }
  
  $thisSession = function(target) {
    return $(target).closest('.session');
  }
  $thisSection = function(target) {
    return $(target).closest('.section');
  }

  var today = new Date();

  /* Set up required content warnings */
  $('.required input').each(function(i) {
    $('#missing-fields').append('<div class="alert alert-danger" id="warning_' + $(this).attr('id') + '">Missing field: ' + $(this).closest('.required').find('label').text().replace(': *','') + '</div>');
    if ($(this).val()) {
      $('#missing-fields #warning_' + $(this).attr('id')).hide();
    }
  });

  /* courses#(new|edit) */
  if ($('body').hasClass('c_courses') &&  ($('body').hasClass('a_edit') || $('body').hasClass('a_new'))) {


    var courseId = $('#info-left').data('course_id');

    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      e.preventDefault();

      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
    });

    /* Add sessions to form */
    $('body').on('click', 'button.add_session', function (e) {
      e.preventDefault();
      
      $.get('/courses/new_section_or_session_block', { to_render: 'session', course_id: courseId, session_count: nextSessionCount(), section_index: nextSectionIndex()}, 
        function (data) {
          $('.sessions').append(data);
        }
      );
    });
    
    /* Add sections to session in form */
    $('body').on('click', 'button.add_section', function (e) {
      e.preventDefault();
      
      console.log('GOT HERE');
      
      var target = e.currentTarget

      var nextSectionCount = $thisSession(target).find('.section').length + 1

      $.get('/courses/new_section_or_session_block', { to_render: 'section', course_id: courseId, session_count: thisSessionCount(), section_count: nextSectionCount, section_index: nextSectionIndex() }, function (data) {
          $thisSession(target).find('.sections').append(data);
          
          // Set duration of added section to that of first section in this session
          $sessionDurations = $thisSession(target).find('.session_duration_val');
          $sessionDurations.last().val($sessionDurations.first().val());
        }
      );
    });

    /* Delete sections, either by adding _destroy input (for sections in DB) *
     *   or by deleting section from the page if not.                        *
     * If this is the last section in a session, and that session is not the *
     *   last section on the page, delete that.                    */
    $('body').on('click', '.section:not(.to_be_deleted) > .panel-heading button.delete, .session:not(.to_be_deleted) > .panel-heading button.delete', function (e) {
      e.preventDefault();
            
      var target = e.currentTarget            
      var toDelete = $(this).data('to_delete');

      var persisted;
      if (toDelete == 'session') {
        persisted = $thisSession(target).find('.id_val').length > 0;
      } else {
        persisted = $thisSection(target).find('.id_val').length > 0;
      }
      
      var name;

      // If a session to delete is persisted (i.e. has at least one section in the database), mark all sections for that session for deletion
      // If a section to delete is persisted, mark that section for deletion
      if (persisted) {
        $(target).text('Restore');
        if (toDelete == 'session') {
          $thisSession(target).addClass('to_be_deleted');
        }
        $thisSession(target).find('.id_val').each(function(i) {
          $section = $(this).closest('.section');
          if ( toDelete == 'session' || (toDelete == 'section' && $section.data('section_index') == $thisSection(target).data('section_index'))) {
            name = $section.find('input.id_val').attr('name').replace(/\[id\]$/, '[_destroy]');
            $section.addClass('to_be_deleted'); 
            $section.append('<input type="hidden" class="destroy" name="' + name + '" value="1">');
          }
        });
       } else {
        if (toDelete == 'session') {
          $thisSession(target).remove();
        } else {
          $thisSection(target).remove();
        }
       }
    });

    /* Undelete section */
    $('body').on('click', '.section.to_be_deleted > .panel-heading button.delete, .session.to_be_deleted > .panel-heading button.delete', function (e) {
      e.preventDefault();

      var target = e.currentTarget
      var toUndelete = $(this).data('to_delete');
      $(target).text('Remove');
      
      if (toUndelete == 'session') {
        $thisSession(target).removeClass('to_be_deleted');
      }
      
      $thisSession(target).find('input.destroy').each(function(i) {
        $section = $(this).closest('.section');
        if ( toUndelete == 'session' || (toUndelete == 'section' && $section.data('section_index') == $thisSection.data('section_index'))) {
          $section.find('input.destroy').remove();
          $section.removeClass('to_be_deleted');
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
        .filter(function (i,el) { return $(el).parents('.to_be_deleted').length == 0})
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
  
  /* Check required fields to make sure they have something in them */
  $('body').on('change', '.required input', function(e) {
    $input = $(e.currentTarget);
    console.log(e.currentTarget);
    if ($input.val()) {
      $('#missing-fields #warning_' + $input.attr('id')).hide();
    } else {
      $('#missing-fields #warning_' + $input.attr('id')).show();  
    }
  });
  
  /* Update additional staff list on assigning primary staff contact to course */
  $('#course_primary_contact_id').on('change', function(e) {
    var userId = $(this).val()
    $('input#course_user_ids_' + userId).attr('checked', false).parent().removeClass('checked');
    $('#course_users_input .checkbox').show();
    $('.checkbox input#course_user_ids_' + userId).parent().parent().parent().hide();
  });
  
  /* qtip for classes with multiple sections */
  var tooltips = $('.section-times .glyphicon-th-list').each (function() {
    var html = $(this).data('section_list');
    $(this).qtip({
      content: {
        title: '<b>All scheduled sections<b>',
        text: html
      },
      style: {
        classes: 'qtip-bootstrap'
      }
    });
  });
});

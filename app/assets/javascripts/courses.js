/* Extract data for tablesorts */
var firstClassDateExtraction = function(node) {
  return node.childNodes[0].innerHTML;
};
$(function () {
  var style_checkboxes = function() {
    $('.checkbox input').iCheck({
      checkboxClass: 'icheckbox_square-blue',
      increaseArea: '20%'
    });
  };

  updateSectionHeader = function() {
    $('.session').each(function(i) {
      if ($(this).find('.section').length == 1) {
        $(this).find('span.section-count').hide();
      } else {
        $(this).find('span.section-count').show();
      }
    });
  };

  nextSectionIndex = function() {
    return $('#scheduling_info .section').length;
  };
  thisSessionCount = function() {
    return $('#scheduling_info .session').length;
  };
  nextSessionCount = function() {
    return thisSessionCount() + 1;
  };
  
  $thisSession = function(target) {
    return $(target).closest('.session');
  };
  $thisSection = function(target) {
    return $(target).closest('.section');
  };

  var today = new Date();
  
  updateSectionHeader();
  

  /* Set up required content warnings */
  /* NOTE: This does not include ckeditor text areas - that's a more complicated problem */
  $('.required input, .required select').each(function(i) {
    $('#missing-fields').append('<div class="alert alert-danger" id="warning_' + $(this).attr('id') + '">Missing field: ' + $(this).closest('.required').find('label').text().replace(': *','') + '</div>');
    if ($(this).selector.match(/ckeditor/)) {
      var has_content = $($(this).selector + ' iframe').contents().find("body").text();
    } else {
      has_content = $(this).val();
    }
    if (has_content) {
      $('#missing-fields #warning_' + $(this).attr('id')).hide();
    }
  });
  
  /* Check required fields to make sure they have something in them */
  $('body').on('change', '.required input, .required select', function(e) {
    $input = $(e.currentTarget);
    if ($input.val()) {
      $('#missing-fields #warning_' + $input.attr('id')).hide();
    } else {
      $('#missing-fields #warning_' + $input.attr('id')).show();  
    }
  });
        
    
  $('body').on('blur', '.ckeditor.required iframe', function(e) {
    console.log('FIRED');
    $input = $(this).closest('.ckeditor.required');
    if ($this.contents().find("body").text()) {
      $('#missing-fields #warning_' + $input.attr('id')).hide();
    } else {
      $('#missing-fields #warning_' + $input.attr('id')).show();  
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
      
      var target = e.currentTarget;

      var nextSectionCount = $thisSession(target).find('.section').length + 1;

      $.get('/courses/new_section_or_session_block', { to_render: 'section', course_id: courseId, session_count: thisSessionCount(), section_count: nextSectionCount, section_index: nextSectionIndex() }, function (data) {
          $thisSession(target).find('.sections').append(data);
          
          // Set duration of added section to that of first section in this session
          $sessionDurations = $thisSession(target).find('.session_duration_val');
          $sessionDurations.last().val($sessionDurations.first().val());
          
          updateSectionHeader();
          
        }
      );
    });

    /* Delete sections, either by adding _destroy input (for sections in DB) *
     *   or by deleting section from the page if not.                        *
     * If this is the last section in a session, and that session is not the *
     *   last section on the page, delete that.                    */
    $('body').on('click', '.section:not(.to_be_deleted) > .panel-heading button.delete, .session:not(.to_be_deleted) > .panel-heading button.delete', function (e) {
      e.preventDefault();
            
      var target = e.currentTarget;            
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
          updateSectionHeader();
        }
       }
    });

    /* Undelete section */
    $('body').on('click', '.section.to_be_deleted > .panel-heading button.delete, .session.to_be_deleted > .panel-heading button.delete', function (e) {
      e.preventDefault();

      var target = e.currentTarget;
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

      $('.datetime_picker .actual-date').filter(function (i,el) { 
        return $(el).parents('.to_be_deleted').length === 0;}).each(function (i,el) {
          var date = $(el).datetimepicker('getDate');

          if (date < today) {
            backdated.push(date.toString());
          } else {
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
    
  /* Handle affiliation code on course request form */
  $('#affiliation .affiliation_field').hide();
  $('#affiliation input[type=radio]:checked').val();
  $('#local_' + $('#affiliation input[type=radio]:checked').val()).show();
  if ($('#other_affiliation').val() !== '') {
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
      $('#other_affiliation').val('') ;   
    }
  });
  
  /* Update additional staff list on assigning primary staff contact to course */
  $('#course_primary_contact_id').on('change', function(e) {
    var userId = $(this).val();
    $('input#course_user_ids_' + userId).attr('checked', false).parent().removeClass('checked');
    $('#course_users_input .checkbox').show();
    console.log($('.checkbox input#course_user_ids_' + userId).parent().parent().parent());
    $('.checkbox input#course_user_ids_' + userId).parent().parent().parent().hide();
  });
  
  /* Update staff services and repository staff and remove primary contact when changing repositories */
  $('#course_repository_id_input select').on('change', function(e) {
  
    var repoId = $(e.currentTarget).val();
    
    //Staff change
    $.get('/repository/staff/', 'id=' + repoId + '&form=true&for=course_course[user_ids][]', function(html) {
    
      //Update the checkboxes
      $('#course_users_input').html(html);
      style_checkboxes();
      
      //Update the primary contact select
      var options = '<option value = ""></option>';
      $(html).find('label.choice').each(function(i) {
        options += '<option value="' + $(this).find('input').val() + '">' + $(this).find('.staff').text() + "</option>\n";
      });
      
      $('select#course_primary_contact_id').html(options);
    });
    
    //Service change
    $.get('/repository/staff_services/', 'id=' + repoId, function(html) {
      $('#course_staff_services_input').html(html);
      style_checkboxes();
    })
    
    //Technology change
    $.get('/repository/technologies/', 'id=' + repoId, function(html) {
      $('#course_technologies_input').html(html);
      style_checkboxes();
    })  });
  
  /* Enable/disable note posting button depending on text in the note field */
  $('.c_courses.a_show').on('keyup', '#note_note_text', function(e) {
    $('#note_submit_action').prop('disabled', $(this).val() === '');
  });
    
  
  /* qtip for classes with multiple sections */
  var tooltips = $('.section-times .glyphicon-th-list').each (function() {
    var html = $(this).data('section_list');
    $(this).qtip({
      content: {
        title: '<b>All scheduled meetings<b>',
        text: html
      },
      style: {
        classes: 'qtip-bootstrap'
      }
    });
  });
  
  //Hide auto-generated notes
  $('.autogen').hide();
  
  $('body').on('click', '.note-toggle', function() {
    var id = $(this).attr('id');
    $('.' + id).toggle();
  });
  
  /* Collaboration logic: if repo is nil, can't collaborate */
  if ( $('#course_assisting_repository_id').val() >=1 ) {
      $('.nature-of-collaboration').slideDown();
  }    
  $('body').on('change', '#course_assisting_repository_id', function(e) {
    if ($(this).val() >= 1) {
      $('.nature-of-collaboration').slideDown();
    } else {
      $('.nature-of-collaboration').slideUp();
      $('.nature-of-collaboration input').iCheck('uncheck');
    } 
  });
  
  /* Closing classes - with option to unclose */
  $('body').on('click', "td[id*='close'] button", function(e) {
    var $clicked = $(this);
    var action = $clicked.attr('class').match(/(un){0,1}close-class/)[0];
    var $notClicked = $(this).parent().siblings().children();
    var id = $clicked.parent().parent().attr('id').substr(6);
    $.get('/courses/' + id + '/close', 'class_action=' + action, function(data) {
      $clicked.attr('disabled', true).removeClass('btn-warning').addClass('btn-info');
      $notClicked.attr('disabled', false).removeClass('btn-info').addClass('btn-warning');
    });
  });
});

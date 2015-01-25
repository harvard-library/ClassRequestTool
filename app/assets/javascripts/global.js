$(function () {
  $('nav.navbar li').each(function (i, el) {
    var $el = $(el)
    if ($el.find('a').attr('href') === location.pathname.replace(/\/\d+(\/.+)?$/, '')){
      $el.addClass('active');
      $el.parentsUntil('nav.navbar', 'li').addClass('active');
    }
  });
  
  // Dealing with modal confirm dialog - override $.rails.allowAction 
  // (see http://lesseverything.com/blog/archives/2012/07/18/customizing-confirmation-dialog-in-rails/ ) 
  $.rails.allowAction = function(link) {
    if (!link.attr('data-confirm')) {
      return true;
    }
    $.rails.showConfirmDialog(link);
  }
  
  false;

  $.rails.confirmed = function(link) {
    link.removeAttr('data-confirm');
    link.trigger('click.rails');
  }
  
  // Now configure the dialog
  $.rails.showConfirmDialog = function(link) {
    var html;
    html = "<div id=\"dialog-confirm\" title=\"Are you sure?\">\n  <p>This will be permanently deleted and cannot be recovered.</p>\n</div>";
    return $(html).dialog({
      resizable: false,
      modal: true,
      buttons: {
        YES: function() {
          $.rails.confirmed(link);
          return $(this).dialog("close");
        },
        No: function() {
          return $(this).dialog("close");
        }
      }
    });
  };
  
  //Information qtips
  $('[data-help_info]').qtip({
      content: {
      attr: 'data-help_info'
    },
    style: {
      classes: 'qtip-bootstrap'
    }
  });
});

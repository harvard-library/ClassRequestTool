// Configure CKEditor
// Remove unwanted buttons
CKEDITOR.config.removeButtons = 'Image,Flash';

// Remove "Upload" tab from link dialogue
CKEDITOR.on( 'dialogDefinition', function( ev )
   {
      // Take the dialog name and its definition from the event data.
      var dialogName = ev.data.name;
      var dialogDefinition = ev.data.definition;

      // Check if the definition is from the dialog we're interested on (the Link dialog).
      if ( dialogName == 'link')
      {
         // remove Upload tab
         dialogDefinition.removeContents( 'upload' );
      }
   });

$(function () {
  $('#nav.navbar li').each(function (i, el) {
    var $el = $(el);
    if ($el.find('a').attr('href') === location.pathname.replace(/\/\d+(\/.+)?$/, '')){
      $el.addClass('active');
      $el.parentsUntil('#nav.navbar', 'li').addClass('active');
    }
  });
  
  // Dealing with modal confirm dialog - override $.rails.allowAction 
  // (see http://lesseverything.com/blog/archives/2012/07/18/customizing-confirmation-dialog-in-rails/ ) 
  // FOX ADDS:  this only seems to work if a data-method is defined in the link (e.g.: "get" or "delete")
  $.rails.allowAction = function(link) {
    if (!link.attr('data-confirm')) {
      return true;
    }
    $.rails.showConfirmDialog(link);
    return false;
  };
  

  $.rails.confirmed = function(link) {
    link.removeAttr('data-confirm');
    link.trigger('click.rails');
  };
  
  // Now configure the dialog
  $.rails.showConfirmDialog = function(link) {
    var html  = "<div id=\"dialog-confirm\" title=\"Are you sure?\">\n<p>";
    var method = $(link).attr("data-method");
    method = method?method:"";
    if (method ==="delete") {
	html = html + "This will be permanently deleted and cannot be recovered.</p>\n";
    }
    else {
	var conf = $(link).attr("data-confirm");
	html = html + ((conf !== "Are you sure?")? conf:"");
    }
    html = html + "</p></div>";
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

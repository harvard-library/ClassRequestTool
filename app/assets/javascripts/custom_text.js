

$(function() {
  
  var data_prep = function($tr) {
      var  data = { custom_text: {} };
      var key_val = $tr.children(".field").children(".key").val();
      var text_id = $tr.children(".field").children(".ckeditor").attr("id");
      var text = CKEDITOR.instances[text_id].getData();
      data.custom_text["key"] = key_val;
      data.custom_text["text"] = text;
      return data;
    }
 
var show_success = function($tr) {
     $tr.css({'background-color': '#c3d7a4;'})
     $tr.animate({'background-color': 'transparent'}, 800);
    }
  
  $('body').on('click', '#new_custom_text button', function(e) {
    var data = data_prep($('#new_custom_text'));
    if (data.custom_text.key != '' && data.custom_text.key != null) {
      $.post('/admin/custom_texts', data, function(newText) {
	  $('#new_custom_text').before(newText);
	  var $tr = $('#new_custom_text').prev()
	  var ckid = $tr.find("*.ckeditor").attr("id")
	  CKEDITOR.replace(ckid);
	  $('#new_custom_text').find("#key").val("");
	  $('#new_custom_text').find("#text").val("");
	  CKEDITOR.instances["text"].destroy(true);
	  CKEDITOR.replace("text");
	  show_success($tr);
      });
    }
  });
  
  $('body').on('click', '#custom_texts .update', function(e) {
      var $tr = $(e.currentTarget).parent().parent().parent();
      var data = data_prep($tr);
      var id = $tr.attr('class').replace('custom-text-', '');
      $.ajax('/admin/custom_texts/' + id, { 
	  method: 'PUT',
	  data: data,
	  success: function() {
              show_success($tr);
	  }
      });  
  });
    
  $('body').on('click', '#custom_texts .delete', function(e) {
    var $tr = $(e.currentTarget).parent().parent().parent();
    var id = $tr.attr('class').replace('custom-text-', '');
    $.ajax('/admin/custom_texts/' + id, { 
      method: 'DELETE',
      success: function() {
        $tr.remove();
      }
    });
  });
});

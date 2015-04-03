$(function() {
  
  $('body').on('click', '#new_custom_text button', function(e) {
    var data = { custom_text: {} };
    $('#new_custom_text .field').each(function() {
      var key = $(this).children().attr('id');
      var customText = $(this).children().val();
      data.custom_text[key] = customText;
    });
    
    if (data.custom_text.key != '' && data.custom_text.key != null) {
      $.post('/admin/custom_texts', data, function(newText) {
       $('#new_custom_text').before(
         '<tr class="custom-text-' + newText.id + '">' + 
         '  <td><a href="#" name="custom_text[key]" data-type="text" data-pk="' + newText.id + '" data-url="/admin/custom_texts/' + newText.id + '", class="editable">' + newText.key + '</a></td>' +
         '  <td><a href="#" name="custom_text[text]" data-type="wysihtml5" data-pk="' + newText.id + '" data-url="/admin/custom_texts/' + newText.id + '", class="editable">' + newText.text + '</a></td>' +
         '</tr>');
      });
    }
  });
  
  $('body').on('click', '#custom_texts .update', function(e) {
    var $tr = $(e.currentTarget).parent().parent().parent();
    var id = $tr.attr('class').replace('custom-text-', '');
    var data = { custom_text: {} };
    $tr.children('.field').each(function() {
      var key = $(this).children().attr('id');
      var customText = $(this).children().val();
      data.custom_text[key] = customText;
    });
    $.ajax('/admin/custom_texts/' + id, { 
      method: 'PUT',
      data: data,
      success: function() {
        $tr.css({'background-color': '#c3d7a4;'})
        $tr.animate({'background-color': 'transparent'}, 800);
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
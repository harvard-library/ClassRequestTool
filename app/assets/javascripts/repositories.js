var fileFieldHtml = function(i, pictureType, pictureId) {
  var pictype = pictureType.toLowerCase()
  var pictureClass = pictype + '_attached_images_attributes'
  var output = '<tr class="new">';
  output += '  <fieldset class="inputs">';
  output += '    <td class="hidden">';
  output += '      <div class="hidden input optional form-group" id="' + pictureClass + '_' + i + '_picture_id_input"><label class="  control-label" for="' + pictureClass + '_' + i + '_picture_id">Picture</label><span class="form-wrapper"><input id="' + pictureClass + '_' + i + '_picture_id" name="' + pictype + '[attached_images_attributes][' + i + '][picture_id]" type="hidden" value="' + pictureId + '" /></span></div>';
  output += '      <div class="hidden input optional form-group" id="' + pictureClass + '_' + i + '_pictureType_input"><label class="  control-label" for="' + pictureClass + '_' + i + '_pictureType">Picture type</label><span class="form-wrapper"><input id="' + pictureClass + '_' + i + '_pictureType" name="' + pictype + '[attached_images_attributes][' + i + '][picture_type]" type="hidden" value="' + pictureType + '" /></span></div>';
  output += '      <div class="hidden input optional form-group" id="' + pictureClass + '_' + i + '_image_cache_input"><label class="  control-label" for="' + pictureClass + '_' + i + '_image_cache">Image cache</label><span class="form-wrapper"><input id="' + pictureClass + '_' + i + '_image_cache" name="' + pictype + '[attached_images_attributes][' + i + '][image_cache]" type="hidden" /></span></div>';
  output += '    </td>';
  output += '    <td>';
  output += '      <div class="file input required form-group" id="' + pictureClass + '_' + i + '_image_input"><label class="  control-label" for="' + pictureClass + '_' + i + '_image">Add image</label><span class="form-wrapper"><input id="' + pictureClass + '_' + i + '_image" name="' + pictype + '[attached_images_attributes][' + i + '][image]" class="image-browser" type="file" /></span></div>';
  output += '    </td>';
  output += '    <td>';
  output += '      <div class="string input optional stringish form-group" id="' + pictureClass + '_' + i + '_caption_input"><label class="  control-label" for="' + pictureClass + '_' + i + '_caption">Caption</label><span class="form-wrapper"><input class="form-control" id="' + pictureClass + '_' + i + '_caption" maxlength="255" name="' + pictype + '[attached_images_attributes][' + i + '][caption]" type="text" value="" /></span></div>';
  output += '    </td>';
  output += '  </fieldset>';
  output += '</trt>';
  return output;
};
$(function () {
  
  /* Add file browser for repository images (limited to 6 images) */
  var n = $('table.repo-images tr').length
  if (n < 6) {
    var pictureType = "Repository"
    var pictureId = $('#repository_attached_images_attributes_0_picture_id').val()
    $('table.repo-images').append( fileFieldHtml(n, pictureType, pictureId) );
  }
  
  /* Add a new filebrowser whenever a new image is selected */
  $('body').delegate('input[type=file].image-browser', 'change', function() {
    var pictureType = "Repository"
    var pictureId = $('#repository_attached_images_attributes_0_picture_id').val()
    var n = $('table.repo-images tr').length
    $('table.repo-images').append( fileFieldHtml(n, pictureType, pictureId) );
  });
  
  /* Delete an image */
  $('body').delegate('button.delete', 'click', function(e) {
    e.preventDefault();
    console.log('Responded to click')
    var id = $(this).attr('id').replace('delete-pic_id-','')
    $.ajax({
      url:      '/attached_images/' + id,
      type:     'DELETE',
      success:  function() {
        $('tr.pic_id-' + id).slideUp(800);
      }
    });
  });
});
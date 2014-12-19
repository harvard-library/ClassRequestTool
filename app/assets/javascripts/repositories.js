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
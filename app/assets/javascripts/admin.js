$(function() {
  $('body').delegate('.affiliates a', 'click', function(e) {
    e.preventDefault();
    var $affiliate = $(this)
    var affiliate_name = $affiliate.parent().prev().children('input').val();
    var action, object, id;
    var temp = $(this).attr('id').split('-');
    action  = temp[0]; 
    object  = temp[1];
    id      = temp[2]; 
    var url = '/admin/affiliates/' + id;
    switch (action) {
      case 'update':
        $.ajax( '/admin/affiliates/' + id, 
          {
            type: 'PUT',
            data: { affiliate: { name: affiliate_name } },
            success: function(data) {
              $input = $affiliate.parent().prev().children('input')
              $input.val(data.name);
              $input.css({ 'background-color': '#9f9' });
              $input.animate({ 'background-color': '#fff' }, 1000);
            }
          }
        );
        break;
      case 'delete':
        $.ajax('/admin/affiliates/' + id, 
          {
            type: 'DELETE',
            success: function(data) {
              $affiliate.parent().parent().remove();
            }
          }
        );
        break;
      case 'save':
        data = { name: affiliate_name };
        $.ajax('/admin/affiliates',
          {
            type: 'POST',
            data: { affiliate: { name: affiliate_name } },
            success: function(data) {
              output =  "<tr id='affiliate-" + data.id + "'>\n"
              output += "  <td><input class='form-control' id='name' name='name' type='text' value='" + data.name + "' /></td>\n"
              output += "  <td><a href='#' id='update-affiliate-" + data.id + "' class='btn btn-xs btn-default'>Update</a> | <a href='#' id='delete-affiliate-" + data.id + "' class='btn btn-xs btn-danger'>Delete</a>\n"
              output += "</tr>"
              $(output).insertBefore('table.affiliates tr.new-affiliate');
              $('tr.new-affiliate input').val('');
            }
          }
        );
        break;
    } 
  });
  $('body').on('click', '#clear-mail-queue', function(e) {
    e.preventDefault();
    $.get('/admin/clear_mail_queue', function(data) {
      if (data.ok) {
        $('#mail-queue-info').fadeOut(function() {
          $('#mail-queue-info').html('<p>There are no jobs in the mail queue.</p>').fadeIn();
        });
      }
    });
  }); 
});
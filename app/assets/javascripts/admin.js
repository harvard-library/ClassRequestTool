$(function() {
  $('body').delegate('.affiliates a', 'click', function(e) {
    e.preventDefault();
    var $affiliate = $(this)
    var affiliate_name = $affiliate.parent().prev().children('input').val();
    console.log(affiliate_name);
    var action, object, id;
    [action, object, id] = $(this).attr('id').split('-');
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
});
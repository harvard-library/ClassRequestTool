$(function () {
  options = {
    handle: '.glyphicon-sort',
    axis: 'y',
    items: 'tr.existing-affiliate',
    helper: 'clone',
    cursor: 'move',
    opacity: 0.75,
    
    stop: function( event, ui) {
      var sortedIDs = $('table.affiliates tbody').sortable('toArray');
      var positions = { affiliates:{} }
      for (i in sortedIDs) {
        positions.affiliates[sortedIDs[i]] = i;
      }
      $.post('/admin/affiliates/update_positions', positions, function(data) {
        $('.sort-info').text(data.msg);
        if (data.status == 'success') {
          $('.sort-info').addClass('success')
        } else {
          $('.sort-info').addClass('danger')
        }
        $('.sort-info').fadeIn(200, function() {
          $('.sort-info').fadeOut(3000, function() {
            $('.sort-info').removeClass('success danger')
          });
        });
      });
    }
  };
  $('table.affiliates tbody').sortable(options);
});

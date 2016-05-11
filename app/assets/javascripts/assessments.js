$(function () {
  // qTips for assessment values
  $('table#assessment-current button').qtip({
    show: 'click',
    position: {
      my: 'right center',
      at: 'left center'
    }, 
    style: {
      classes: 'qtip-bootstrap'
    },
    content: {
      text: function(event, api) {
        return $(this).data('content');
      }
    }
  });
});
  
  
// UI convenience function - ensures one popover open at a time,
//      and that they close when user clicks elsewhere
//   var popover_sel = '#assessment-table-current button[data-toggle="popover"]';
// assessments#index
//   if (window.location.href.match(/assessments($|\?.+$)/)) {
//     $(popover_sel).popover();
// 
//     $('#assessment-table-current').on('click', 'button[data-toggle="popover"]', function (e) {
//       $(document).off('click.clearPopUps');
//       $(popover_sel).not(e.target).popover('hide');
//       $(document).one('click.clearPopUps', function (e) {
//         $(popover_sel).popover('hide');
//       });
//       e.stopPropagation(); /* stops at table
//     });
// 
//     /* Stop click events on the popup from bubbling (and triggering clear)
//     $('body').on('click', '.popover', function (e) {
//       e.stopPropagation();
//     });
//   }
// });

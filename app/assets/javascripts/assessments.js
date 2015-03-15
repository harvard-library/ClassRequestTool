$(function () {
  /* UI convenience function - ensures one popover open at a time,
     and that they close when user clicks elsewhere */
  var popover_sel = '#assessment-table-current button[data-toggle="popover"]';
  /* assessments#index */
  if (window.location.href.match(/assessments($|\?.+$)/)) {
    $(popover_sel).popover();

    $('#assessment-table-current').on('click', 'button[data-toggle="popover"]', function (e) {
      $(document).off('click.clearPopUps');
      $(popover_sel).not(e.target).popover('hide');
      $(document).one('click.clearPopUps', function (e) {
        $(popover_sel).popover('hide');
      });
      e.stopPropagation(); /* stops at table */
    });

    /* Stop click events on the popup from bubbling (and triggering clear) */
    $('body').on('click', '.popover', function (e) {
      e.stopPropagation();
    });
  }
});

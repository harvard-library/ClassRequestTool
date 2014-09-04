$(function () {
  $('nav.navbar li').each(function (i, el) {
    var $el = $(el)
    if ($el.find('a').attr('href') === location.pathname.replace(/\/\d+(\/.+)?$/, '')){
      $el.addClass('active');
      $el.parentsUntil('nav.navbar', 'li').addClass('active');
    }
  });
});

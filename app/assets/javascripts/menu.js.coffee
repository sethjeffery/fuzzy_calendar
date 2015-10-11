$(document).on 'click', '[data-toggle="hamburger-menu"]', (e) ->
  e.preventDefault()
  unless $('#hamburger-menu').hasClass('showing')
    $('#hamburger-menu').addClass('showing')
    setTimeout (-> $('#hamburger-menu').toggleClass('in')), 50
    $('#navbar').toggleClass('navbar-dark').toggleClass('navbar-light')
    setTimeout (-> $('#hamburger-menu').removeClass('showing')), 300

$(window).on 'scroll', ->
  $('#navbar').toggleClass('navbar-bg', $(document).scrollTop() > 5)

$.fn.disableSelection = ->
  @.attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false)

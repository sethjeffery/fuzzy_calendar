$(document).on 'shown.bs.modal', '.modal[data-autofocus]', ->
  $(@).find(@.dataset.autofocus).focus().select()

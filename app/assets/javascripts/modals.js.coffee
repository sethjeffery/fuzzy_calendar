$(document).on 'shown.bs.modal', '.modal[data-autofocus]', ->
  $(@).find($(@).data('autofocus')).focus().select()

$(document).on 'show.bs.modal', '#login-modal', (e) ->
  href = $(e.relatedTarget).attr('href')
  $(@).find('a').each ->
    loginHref = $(@).attr('href').replace(/\?.*$/, '')
    $(@).attr('href', loginHref + '?redirect_after_login=' + encodeURIComponent(href))

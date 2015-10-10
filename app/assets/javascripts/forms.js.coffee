$(document).on 'ready page:load', ->
  autosize $('textarea')

$(document).on 'click', '#change_password', ->
  $('#change_password').prop(hidden: true)
  $('#change_password_fields').prop(hidden: false).find('input[type=password]').first().focus()

$(document).on 'change', '#user_avatar', ->
  file = @files?[0]
  $('label.btn[for="user_avatar"] span').text(file.name) if file

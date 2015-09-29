
$(document).on 'click', 'input[name="event[specificity]"]', (e) ->
  $('#event_date_range').picker(specificity: $(@).val(), dates: {})

$(document).on 'ready page:load', ->
  $('#event-rsvp-modal').modal('show') if /rsvp=true/.test(location.search)
  $('#event_name').focus()

$(document).on 'wizard.moving', '#wizard-rsvp', (e, data) ->
  # Populate picker-rsvp-favorites dates with picker-rsvp-available
  pickerFavorites = $('#picker-rsvp-favorites').data('picker')
  pickerAvailable = $('#picker-rsvp-available').data('picker')

  if pickerFavorites and pickerAvailable
    _.defaults pickerFavorites.favorites, pickerAvailable.dates
    pickerFavorites.favorites = _(pickerFavorites.favorites).filter((f) -> _.contains pickerAvailable.dates, f)
    pickerFavorites.render()


$(document).on 'click', 'input[name="event[specificity]"]', (e) ->
  $('#event_date_range').picker(specificity: $(@).val(), dates: {})

$(document).on 'ready page:load', ->
  $('#event-rsvp-modal').modal('show') if /rsvp=true/.test(location.search)
  $('#event_name').focus()

  $('#event-rsvp-modal').modal('show') if location.hash == '#rsvp'
  $('#event-share-modal').modal('show') if location.hash == '#share'

$(document).on 'wizard.moving', '#wizard-rsvp', (e, data) ->
  # Populate picker-rsvp-favorites dates with picker-rsvp-available
  pickerFavorites = $('#picker-rsvp-favorites').data('picker')
  pickerAvailable = $('#picker-rsvp-available').data('picker')

  if pickerFavorites and pickerAvailable
    _.defaults pickerFavorites.dates, pickerAvailable.dates
    for own k, v of pickerFavorites.dates
      delete pickerFavorites.dates[k] unless pickerAvailable.dates[k]
    pickerFavorites.render()

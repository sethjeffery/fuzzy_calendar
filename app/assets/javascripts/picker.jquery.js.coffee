#= require month_picker
#= require day_picker
#= require picker

$.fn.picker = (opts = {}) ->
  @.each ->
    pickerOpts =
      specificity: 'day'
      dates: {}
      favorites: {}
      columns: 1

    _.extend pickerOpts, $(@).data(), opts

    picker = switch pickerOpts.specificity
      when 'day' then new DayPicker($(@), pickerOpts)
      when 'week' then new WeekPicker($(@), pickerOpts)
      when 'month' then new MonthPicker($(@), pickerOpts)

    $(@).data(picker: picker)

$(document).on 'ready page:load', ->
  $('.picker').picker()

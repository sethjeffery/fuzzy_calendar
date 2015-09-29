#= require day_picker
#= require templates/month_picker

class @MonthPicker extends DayPicker
  template: JST["templates/month_picker"]

  renderBlocks: ->
    if @blocks > 0
      for i in [0..(@blocks-1)]
        @$el.append @template _.extend {}, @, { date: moment(@date).add(i, 'year'), useDropdown: i == 0 }
    else
      year = moment(@minDate).startOf('year').add(-1, 'year')
      finalYear = moment(@maxDate).startOf('year')
      while year.add(1, 'year') <= finalYear
        @$el.append @template _.extend {}, @, { date: year }

    @updateActiveCells()

  updateActiveCells: =>
    @$el.find("a.picker-cell").removeClass('picker-cell-active picker-cell-in-range picker-cell-start-range picker-cell-end-range')
    @$el.find("a.picker-cell[data-date='#{date}']").addClass('picker-cell-active') for date in @dates
    dates = @dates

    # Highlight in-between dates
    if @range and @dates.length > 0
      allCells = @$el.find('a.picker-cell')
      allCells.filter("[data-date='#{dates[0]}']").addClass('picker-cell-start-range')
      allCells.filter("[data-date='#{dates[1]}']").addClass('picker-cell-end-range')
      startHighlighting = allCells.first().data('date') > dates[0] and allCells.first().data('date') <= dates[1]

      allCells.each ->
        startHighlighting = true if @.dataset.date == dates[0]
        $(@).addClass('picker-cell-in-range') if startHighlighting
        startHighlighting = false if @.dataset.date == dates[1]

#= require picker
#= require disable_selection
#= require templates/day_picker
#= require templates/cell_tooltip

activating = undefined
rangeItemMoving = undefined

class @DayPicker extends Picker
  template: JST["templates/day_picker"]

  renderBlocks: ->
    if @blocks > 0
      for i in [0..(@blocks-1)]
        @$el.append @template _.extend {}, @, { date: moment(@date).add(i, 'month'), useDropdown: i == 0 }
    else
      month = moment(@minDate).startOf('month').add(-1, 'month')
      finalMonth = moment(@maxDate).startOf('month')
      while month.add(1, 'month') <= finalMonth
        @$el.append @template _.extend {}, @, { date: month }

    @updateActiveCells()

  setupEvents: ->
    $el = @$el
    _picker = @

    $el.on 'mousedown', 'a.picker-cell', (e) ->
      return unless e.buttons == 1 # left-click only

      if _picker.favorite
        activating = !$(@).hasClass('picker-cell-favorite') or !_picker.multi
      else
        activating = !$(@).hasClass('picker-cell-active') or !_picker.multi

      _picker.toggleDate @.dataset.date, activating

      # Track dragging and highlight the cells we drag over
      $(window).on 'mousemove.picker', (e) ->
        return unless e.buttons == 1

        $el.find('a.picker-cell').each ->
          $offset = $(@).offset()
          if $offset.left < e.pageX and $offset.left + $(@).outerWidth() > e.pageX and $offset.top < e.pageY and $offset.top + $(@).outerHeight() > e.pageY
            _picker.toggleDate @.dataset.date, activating

    $el.on 'click', '[data-toggle=picker]', (e) ->
      e.preventDefault()
      _picker.date = moment(@.dataset.date)
      _picker.render()

  toggleDate: (date, active) ->
    # Deep clone
    dates = _.object _.map(@dates, (props, date) -> [date, _.clone(props)])
    oldDates = _.object _.map(@dates, (props, date) -> [date, _.clone(props)])

    do (dates, oldDates, active, _picker = @) ->
      keys = _.keys(dates).sort()
      firstDate = keys[0]
      lastDate = keys[keys.length-1]

      if _picker.favorite
        dates[date]?.favorite = active
      else if _picker.multi
        if active
          dates[date] or= {}
        else
          delete dates[date]
      else if _picker.range
        if keys.length == 0
          rangeItemMoving = 1
        else if rangeItemMoving is undefined
          if date <= firstDate
            rangeItemMoving = 0
          else
            rangeItemMoving = 1

        if rangeItemMoving == 0
          rangeItemMoving = 1 if date > lastDate
          delete dates[firstDate] unless keys.length < 2
          dates[date] = {}
        else if rangeItemMoving == 1
          rangeItemMoving = 0 if date < firstDate
          delete dates[lastDate] unless keys.length < 2
          dates[date] = {}
      else
        dates = {}
        dates[date] = {}

      # update if values have changed
      unless JSON.stringify(oldDates) == JSON.stringify(dates)
        _picker.dates = dates

        # update UI and DOM in separate thread for a little speed
        _.defer _picker.updateActiveCells
        _.defer _picker.updateInput

  updateActiveCells: =>
    $allCells = @$el.find(".picker-days .picker-cell:not(.picker-day-outside)")
    classesToRemove = _(['active', 'favorite', 'low', 'mid', 'high', 'start-range', 'end-range', 'in-range']).map((o) -> "picker-cell-#{o}").join(' ')
    $allOtherCells = $allCells

    maxScore = _.max _.map(@dates, (d) -> d.score)

    for own date, props of @dates
      classesToAdd = ""
      $cellDate = $allCells.filter("[data-date='#{date}']")
      classesToAdd += 'picker-cell-active '
      classesToAdd += 'picker-cell-favorite ' if props.favorite and @favorite

      if props.score?
        classesToadd += 'picker-cell-low '  if props.score > 0               and props.score < maxScore * .33
        classesToadd += 'picker-cell-mid '  if props.score >= maxScore * .33 and props.score < maxScore * .66
        classesToadd += 'picker-cell-high ' if props.score >= maxScore *.66  and props.score < maxScore
        $cellDate.tooltip(title: JST["templates/cell_tooltip"](props), html: true)

      $allOtherCells = $allOtherCells.not($cellDate)
      $cellDate.removeClass(classesToRemove).addClass(classesToAdd)

    dates = _.keys(@dates).sort()
    $allOtherCells.removeClass(classesToRemove)

    # Highlight in-between dates
    if @range and dates.length > 0
      firstDate = dates[0]
      lastDate = if dates.length > 1 then dates[dates.length-1] else firstDate
      $allCells.filter("[data-date='#{firstDate}']").addClass('picker-cell-start-range')
      $allCells.filter("[data-date='#{lastDate}']").addClass('picker-cell-end-range')
      startHighlighting = $allCells.first().data('date') > firstDate and $allCells.first().data('date') <= lastDate

      $allCells.each ->
        startHighlighting = true if @.dataset.date == firstDate
        $(@).addClass('picker-cell-in-range') if startHighlighting
        startHighlighting = false if @.dataset.date == lastDate

$(window).on 'mouseup.day_picker', ->
  $(window).off 'mousemove.day_picker'
  rangeItemMoving = undefined

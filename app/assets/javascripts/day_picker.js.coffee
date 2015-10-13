#= require picker
#= require disable_selection
#= require templates/day_picker
#= require templates/cell_tooltip

activating = undefined
rangeItemMoving = undefined

class @DayPicker extends Picker
  template: JST["templates/day_picker"]
  jqSpecificity: 'cell'

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
    jqs = @jqSpecificity

    $el.off('mousedown').off('touchstart').on 'mousedown touchstart', "a.picker-#{jqs}", (e) ->
      return unless e.button < 2 or e.type == 'touchstart' # left-click or taps only

      if _picker.favorite
        activating = !$(@).hasClass("picker-#{jqs}-favorite") or !_picker.multi
      else
        activating = !$(@).hasClass("picker-#{jqs}-active") or !_picker.multi

      _picker.toggleDate $(@).data('date'), activating

      # Track dragging and highlight the cells we drag over
      $(window).on 'mousemove.day_picker touchmove.day_picker', (e) ->
        return unless e.button < 2 or e.type == 'touchmove'

        e.preventDefault() if e.type == 'touchmove'
        pageX = if e.originalEvent?.touches then e.originalEvent.touches[0].pageX else e.pageX
        pageY = if e.originalEvent?.touches then e.originalEvent.touches[0].pageY else e.pageY

        $found = undefined
        $el.find("a.picker-#{jqs}").each ->
          $offset = $(@).offset()
          $found = $(@) if $offset.left < pageX and $offset.left + $(@).outerWidth() > pageX and $offset.top < pageY and $offset.top + $(@).outerHeight() > pageY

        _picker.toggleDate $found.data('date'), activating if $found

    $el.off('click').on 'click', '[data-toggle=picker]', (e) ->
      e.preventDefault()
      _picker.date = moment($(@).data('date'))
      _picker.render()

  toggleDate: (date, active) ->
    # Deep clone
    dates = _.object _.map(@dates, (props, date) -> [date, _.clone(props)])
    oldDates = _.object _.map(@dates, (props, date) -> [date, _.clone(props)])

    do (dates, oldDates, active, _picker = @) ->
      keys = _.keys(dates).sort()
      firstDate = keys[0]
      lastDate = keys[keys.length-1]
      changedDates = []

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
      changedDates = _.difference(_.union(_.keys(dates), _.keys(oldDates)), _.intersection(_.keys(dates), _.keys(oldDates))).sort()

      if changedDates.length > 0
        _picker.dates = dates

        # update UI and DOM in separate thread for a little speed
        _picker.updateActiveCells(changedDates)
        _picker.updateInput()

  updateActiveCells: (changedDates) =>
    changedDates = _(@dates).keys() unless changedDates
    jqs = @jqSpecificity

    $allCells = @$el.find(".picker-days .picker-#{jqs}:not(.picker-day-outside)")
    classesToRemove = _(['active', 'favorite', 'low', 'mid', 'high']).map((o) -> "picker-#{jqs}-#{o}").join(' ')

    maxScore = _.max _.map(@dates, (d) -> d.score)

    for date in changedDates
      props = @dates[date]
      $cellDate = $allCells.filter("[data-date='#{date}']")

      if props
        classesToAdd = ""
        classesToAdd += "picker-#{jqs}-active "
        classesToAdd += "picker-#{jqs}-favorite " if props.favorite and @favorite

        if props.score?
          classesToAdd += "picker-#{jqs}-low "  if props.score > 0               and props.score < maxScore * .33
          classesToAdd += "picker-#{jqs}-mid "  if props.score >= maxScore * .33 and props.score < maxScore * .66
          classesToAdd += "picker-#{jqs}-high " if props.score >= maxScore *.66  and props.score < maxScore
          $cellDate.tooltip
            title: JST["templates/cell_tooltip"](props)
            html: true
            placement: 'top'

        $cellDate.removeClass(classesToRemove).addClass(classesToAdd)

      else
        $cellDate.removeClass(classesToRemove)

    dates = _.keys(@dates).sort()

    # Highlight in-between dates
    if @range and dates.length > 0
      firstDate = dates[0]
      lastDate = if dates.length > 1 then dates[dates.length-1] else firstDate

      $allCells.each ->
        $el = $(@)
        date = $el.data('date')
        $el.toggleClass "picker-#{jqs}-start-range", date == firstDate
        $el.toggleClass "picker-#{jqs}-end-range", date == lastDate
        $el.toggleClass "picker-#{jqs}-in-range", date >= firstDate and date <= lastDate

$(window).on 'mouseup.day_picker touchend.day_picker', ->
  $(window).off('mousemove.day_picker').off('touchmove.day_picker')
  rangeItemMoving = undefined

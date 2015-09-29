#= require day_picker

class @WeekPicker extends DayPicker

  setupEvents: ->
    $el = @$el
    _picker = @

    $el.on 'mousedown', 'a.picker-row', (e) ->
      return unless e.buttons == 1 # left-click only

      if _picker.favorite
        activating = !$(@).hasClass('picker-row-favorite') or !_picker.multi
      else
        activating = !$(@).hasClass('picker-row-active') or !_picker.multi

      _picker.toggleDate @.dataset.date, activating

      # Track dragging and highlight the rows we drag over
      $(window).on 'mousemove.picker', (e) ->
        return unless e.buttons == 1

        $el.find('a.picker-row').each ->
          $offset = $(@).offset()
          if $offset.left < e.pageX and $offset.left + $(@).outerWidth() > e.pageX and $offset.top < e.pageY and $offset.top + $(@).outerHeight() > e.pageY
            _picker.toggleDate @.dataset.date, activating

    $el.on 'click', '[data-toggle=picker]', (e) ->
      e.preventDefault()
      _picker.date = moment(@.dataset.date)
      _picker.render()

  updateActiveCells: =>
    $allRows = @$el.find(".picker-days .picker-row")
    $allRows.removeClass _(['active', 'favorite', 'low', 'mid', 'high', 'start-range', 'end-range', 'in-range']).map((o) -> "picker-row-#{o}").join(' ')

    maxScore = _.max _.map(@dates, (d) -> d.score)

    for own date, props of @dates
      $rowDate = $allRows.filter("[data-date='#{date}']")
      $rowDate.addClass('picker-row-active')
      $rowDate.addClass('picker-row-favorite') if props.favorite and @favorite

      if props.score?
        $rowDate.addClass('picker-row-low')  if props.score > 0               and props.score < maxScore * .33
        $rowDate.addClass('picker-row-mid')  if props.score >= maxScore * .33 and props.score < maxScore * .66
        $rowDate.addClass('picker-row-high') if props.score >= maxScore *.66  and props.score < maxScore
        $rowDate.tooltip(title: JST["templates/cell_tooltip"](props), html: true)

    dates = _.keys(@dates).sort()

    # Highlight in-between dates
    if @range and dates.length > 0
      firstDate = dates[0]
      lastDate = if dates.length > 1 then dates[dates.length-1] else firstDate
      $allRows.filter("[data-date='#{firstDate}']").addClass('picker-row-start-range')
      $allRows.filter("[data-date='#{lastDate}']").addClass('picker-row-end-range')
      startHighlighting = $allRows.first().data('date') > firstDate and $allRows.first().data('date') <= lastDate

      $allRows.each ->
        startHighlighting = true if @.dataset.date == firstDate
        $(@).addClass('picker-row-in-range') if startHighlighting
        startHighlighting = false if @.dataset.date == lastDate

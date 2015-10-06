stepStarted = {}
stepAnimations =
  one: ->
    setPickerDates = (picker, startDate, endDate) ->
      picker.dates = {}
      picker.dates[startDate.format('YYYY-MM-DD')] = {}
      picker.dates[endDate.format('YYYY-MM-DD')] = {}
      picker.render()

    $picker = $('.welcome #picker-step-1')
    if $picker.length && !$picker.data('stop')
      picker = $picker.data('picker')
      for i in [0..3]
        do (i, setPickerDates, picker) ->
          setTimeout ->
            setPickerDates picker, moment().startOf('month'), moment().startOf('month').add(i, 'weeks')
          , i * 100

  two: ->
    showNextChat = -> $('.fbchat .fade:not(.in)').first().addClass('in')
    setTimeout showNextChat, i * 800 for i in [0..2]

  three: ->
    addPickerDate = (picker, date) ->
      picker.dates[date.format('YYYY-MM-DD')] = {}
      picker.render()

    $picker = $('.welcome #picker-step-3')
    if $picker.length && !$picker.data('stop')
      picker = $picker.data('picker')
      for i in [0..7]
        do (i, addPickerDate, picker) ->
          setTimeout ->
            if i < 4
              date = moment().startOf('month').add(5, 'days').add(i, 'weeks')
              addPickerDate picker, date if date.month() == moment().month()
            else
              date = moment().startOf('month').add(8, 'days').add(i - 4, 'weeks')
              addPickerDate picker, date if date.month() == moment().month()
          , i * 100

  four: ->
    addPickerDateUser = (picker, date, name) ->
      picker.dates[date.format('YYYY-MM-DD')] or= { score: 0, users: [] }
      unless _.findWhere(picker.dates[date.format('YYYY-MM-DD')].users, name: name)
        picker.dates[date.format('YYYY-MM-DD')].score += 1
        picker.dates[date.format('YYYY-MM-DD')].users.push({ name: name })
      picker.render()

    $picker = $('.welcome #picker-step-4')
    if $picker.length && !$picker.data('stop')
      picker = $picker.data('picker')
      for i in [0..17]
        do (i, addPickerDateUser, picker) ->
          setTimeout ->
            if i < 4
              date = moment().startOf('month').add(5, 'days').add(i, 'weeks')
              addPickerDateUser picker, date, 'John' if date.month() == moment().month()
            else if i < 8
              date = moment().startOf('month').add(8, 'days').add(i - 4, 'weeks')
              addPickerDateUser picker, date, 'Andy' if date.month() == moment().month()
            else if i < 14
              date = moment().startOf('month').add(15, 'days').startOf('week').add(i - 8, 'days')
              addPickerDateUser picker, date, 'Sarah' if date.month() == moment().month()
            else if i < 17
              date = moment().startOf('month').add(5, 'days').add(i - 14, 'weeks')
              addPickerDateUser picker, date, 'Alice' if date.month() == moment().month()
            else
              date = moment().startOf('month').add(5, 'days').add(1, 'weeks')
              addPickerDateUser picker, date, 'Andy' if date.month() == moment().month()
          , i * 100

$(document).on 'ready page:load', ->
  stepStarted = {}

  spinCanvas = ->
    $spinCanvas = $('.welcome .wow-header .cal-canvas')
    $spinCanvas.addClass('spin') if $spinCanvas.length

  finalisedCanvas = ->
    $calFront = $('.welcome .wow-header .cal-canvas .cal-front')
    $calFront.addClass('cal-front-finalised') if $calFront.length

  if $('.wow-header .cal-canvas').length
    setTimeout finalisedCanvas, 3500
    unless $.browser.msie
      setTimeout spinCanvas, 1000

$(document).on 'click', '.js-welcome', (e) ->
  e.preventDefault()
  scrollTop = $($(@).attr('href')).position().top
  $('html, body').animate(scrollTop: scrollTop)

$(window).on 'scroll', ->
  stepOne = $('.welcome #step-one')
  stepTwo = $('.welcome #step-two')

  for step in ['one', 'two', 'three', 'four']
    $step = $(".welcome #step-#{step}")

    do (step, $step) ->
      if $step.length and !stepStarted[step] and $step.position().top < $(document).scrollTop() + $(window).height() / 2
        stepStarted[step] = true
        setTimeout stepAnimations[step], 500

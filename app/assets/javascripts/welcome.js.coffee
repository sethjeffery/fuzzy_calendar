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
      $(day: 0).animate { day: 3 },
        duration: 300
        step: (now, fx) ->
          setPickerDates picker, moment().startOf('month'), moment().startOf('month').add(parseInt(now), 'weeks')

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
      $(week: 0).animate { week: 7 },
        duration: 1000
        step: (now, fx) ->
          if now < 4
            date = moment().startOf('month').add(5, 'days').add(parseInt(now), 'weeks')
            addPickerDate picker, date if date.month() == moment().month()
          else
            date = moment().startOf('month').add(8, 'days').add(parseInt(now) - 4, 'weeks')
            addPickerDate picker, date if date.month() == moment().month()

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
      $(week: 0).animate { week: 17 },
        duration: 2000
        easing: 'linear'
        step: (now, fx) ->
          if now < 4
            date = moment().startOf('month').add(5, 'days').add(parseInt(now), 'weeks')
            addPickerDateUser picker, date, 'John' if date.month() == moment().month()
          else if now < 8
            date = moment().startOf('month').add(8, 'days').add(parseInt(now) - 4, 'weeks')
            addPickerDateUser picker, date, 'Andy' if date.month() == moment().month()
          else if now < 14
            date = moment().startOf('month').add(15, 'days').startOf('week').add(parseInt(now) - 8, 'days')
            addPickerDateUser picker, date, 'Sarah' if date.month() == moment().month()
          else if now < 17
            date = moment().startOf('month').add(5, 'days').add(parseInt(now) - 14, 'weeks')
            addPickerDateUser picker, date, 'Alice' if date.month() == moment().month()
          else
            date = moment().startOf('month').add(5, 'days').add(1, 'weeks')
            addPickerDateUser picker, date, 'Andy' if date.month() == moment().month()


$(document).on 'ready page:load', ->
  stepStarted = {}

  spinCanvas = ->
    $spinCanvas = $('.welcome .wow-header .cal-canvas')

    if $spinCanvas.length
      $spinCanvas.addClass('spin')

  setTimeout spinCanvas, 1000 if $('.wow-header .cal-canvas').length

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

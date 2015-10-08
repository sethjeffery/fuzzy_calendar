# Script for the Wizard component.
#
# Wizards can be triggered manually through jQuery.
#   $('.wizard').wizard('next')
#   $('.wizard').wizard('back')
#   $('.wizard').wizard(5)
#
# Or automatically wired up with data attributes.
#   <a data-toggle="wizard" data-target="#wizard" data-move="back">Back</a>
#   <a data-toggle="wizard" data-target="#wizard" data-move="next">Next</a>
#
# You can then listen for events, which will be thrown by the wizard and its steps.
#   wizard.moving:   The wizard wants to move to a new step. The callback will receive the event
#                    and a JSON hash of data. Set the `cancelling` field to `true` to cancel the move.
#
#   wizard.hidden:   Thrown by the old step after move completes.
#   wizard.shown:    Thrown by the new step after move completes.
#
Wizard =
  move: ($wizard, direction) ->
    return if $wizard.hasClass('moving')

    $steps = $wizard.find('.wizard-step')
    $current = $steps.filter('.active').first()
    currentIndex = $steps.index($current)
    $next = $($steps[currentIndex+1])

    if /^[0-9]+$/.test(direction) # numeric = move to index
      $next = $($steps[parseInt(direction)])
    else if direction == 'back' or direction == 'prev'
      $next = $($steps[currentIndex-1])

    nextIndex = $steps.index($next)

    eventData =
      cancelling: nextIndex < 0 or nextIndex >= $steps.length or nextIndex == currentIndex
      wizard: $wizard
      move: direction
      nextStep: $next
      currentStep: $current
      currentIndex: currentIndex
      nextIndex: nextIndex

    $current.trigger($.Event('wizard.moving'), eventData)

    # Allow the user to cancel the event in callback
    return if eventData.cancelling

    # Anonymous method so that these elements are treated independently
    # and unaffected if the method gets called more than once
    do ($wizard, $next, $current, currentIndex, nextIndex) ->
      $wizard.css height: $current.outerHeight()
      $current.css left: '0'
      $next.css left: if currentIndex < nextIndex then '100%' else '-100%'

      $wizard.add($next).add($current).addClass('moving')
      $current.addClass('out')
      $next.addClass('in')

      setTimeout ->
        $next.css left: 0
        $current.css left: if currentIndex < nextIndex then '-100%' else '100%'
        $wizard.css height: $next.outerHeight()
        $next.filter('.fade').css opacity: 1
        $current.filter('.fade').css opacity: 0

        setTimeout ->
          $wizard.add($next).add($current).removeClass('moving').removeClass('in').removeClass('out').removeClass('active').css(height: '', left: '', opacity: '')
          $next.addClass('active')

          eventData =
            wizard: $wizard
            currentStep: $next
            previousStep: $current
            currentIndex: nextIndex
            previousIndex: currentIndex
          $current.trigger($.Event('wizard.hidden'), eventData)
          $next.trigger($.Event('wizard.shown'), eventData)
        , 500
      , 50

# Automatic wire-up of click event
$(document).on 'click', '[data-toggle=wizard]', (e) ->
  e?.preventDefault()

  $el = $(@)
  selector = @getAttribute('data-target')

  if !selector
    selector = @getAttribute('href') or ''
    selector = $el.closest('.wizard') unless /^#[a-z]/i.test(selector)

  $wizard = $(selector)
  Wizard.move($wizard, $el.data('move'))

# jQuery plugin
$.fn.wizard = (cmd) ->
  Wizard.move($(@), cmd)

class @Picker
  constructor: (@$el, { @specificity, @size, @dates, @favorites, @blocks, readOnly, double, minDate, maxDate, date, name, multi, range, useDropdown, favorite }) ->
    @name = name or 'picker'
    @multi = multi?
    @double = double?
    @range = range?
    @readOnly = readOnly?
    @favorite = favorite?
    @date = moment(date)
    @minDate = moment(minDate) if minDate
    @maxDate = moment(maxDate) if maxDate
    @dates = @dates.split(',') if _.isString(@dates)
    @useDropdown = useDropdown or @blocks > 0
    @dates[i] = moment(date).startOf(@specificity).format('YYYY-MM-DD') for date, i in @dates
    @render()
    @_setupEvents()

  render: ->
    @$el.addClass("picker-specificity-#{@specificity}")
    @$el.addClass("picker-#{@size}") if @size
    @$el.addClass("picker-double") if @double
    @$el.html("<input type=\"hidden\" name=\"#{@name}\"/>")
    @$el.data(date: @date)
    @updateInput()
    @updateActiveCells()
    @renderBlocks()

  updateInput: =>
    @$el.find('input').val(JSON.stringify(@dates))
    @$el.data(dates: @dates)

  _setupEvents: ->
    @$el.disableSelection()
    @setupEvents()

$(window).on 'mouseup.picker', ->
  $(window).off 'mousemove.picker'

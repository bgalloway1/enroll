$(document).on 'click', 'form .add_fields', (event) ->
  event.preventDefault()
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  html = $(this).data('fields').replace(regexp, time)
  target = $(this).closest('.form-inputs')
  if $(target).children('fieldset:last').length > 0
    $(target).children('fieldset:last').after(html)
  else
    $(target).prepend(html)
  $(target).children('fieldset:last').find('select').selectric()
  $(target).children('fieldset:last').find("input.floatlabel").floatlabel slideInput: false

  update_delete_buttons()
  applyJQDatePickers()

  $('.benefit-group-fields:last').find('.benefits-fields .slider').bootstrapSlider
    formatter: (value) ->
      return 'Contribution Percentage: ' + value + '%'
  $('.benefit-group-fields:last').find('.benefits-fields .slider').on 'slide', (slideEvt) ->
    $(this).closest('.form-group').find('.hidden-param').val(slideEvt.value).attr 'value', slideEvt.value
    $(this).closest('.form-group').find('.slide-label').text slideEvt.value + '%'
    return
  $('.benefit-group-fields:last .selected-plan').remove()
  $('.benefit-group-fields:last input[value="child_under_26"]').closest('.row-form-wrapper').attr('style','border-bottom: 0px;')



$(document).on 'click', 'form .remove_fields', (event) ->
  $(this).closest('fieldset').remove()
  event.preventDefault()

@update_delete_buttons = ->
  nested_fields = $('.form-inputs')
  nested_fields.each ->
    visible_fieldsets = $(this).find('fieldset:visible')
    delete_button = visible_fieldsets.find('.remove_fields')
    if visible_fieldsets.length == 1
      delete_button.hide()
    else
      delete_button.show()

###*
Popup overlays.
  
For modal dialogs see {{#crossLink "up.modal"}}{{/crossLink}}.
  
@class up.popup 
###
up.popup = (->
  
  position = ($link, $popup, origin) ->
    linkBox = up.util.measure($link, full: true)
    console.log("linkBox", linkBox)
    css = switch origin
      when "bottom-right"
        right: linkBox.right
        top: linkBox.top + linkBox.height
      when "bottom-left"
        left: linkBox.left
        top: linkBox.bottom + linkBox.height
      when "top-right"
        right: linkBox.right
        bottom: linkBox.top
      when "top-left"
        left: linkBox.left
        bottom: linkBox.top
      else
        up.util.error("Unknown origin", origin)
    $popup.css(css)
    
  createHiddenPopup = ($link, selector, sticky) ->
    $popup = up.util.$createElementFromSelector('.up-popup')
    $popup.attr('up-sticky', '') if sticky
    $content = up.util.$createElementFromSelector(selector)
    $content.appendTo($popup)
    $popup.appendTo(document.body)
    $popup.hide()
    $popup
    
  updated = ($link, $popup, origin, animation) ->
    $popup.show()
    $link.addClass('up-current')
    position($link, $popup, origin)
    up.animate($popup, animation)
    
  ###*
  Opens a popup overlay.
  
  @method up.popup.open
  @param {Element|jQuery|String} elementOrSelector
  @param {String} [options.origin='bottom-right']
  @param {String} [options.animation]
  @param {Boolean} [options.sticky=false]
    If `true`, keeps the popup open even if the page changes in the background.
  @param {Object} [options.history=false]
  @example
      <a href="/decks" up-popup=".deck_list">Switch deck</a>
  @example
      <a href="/settings" up-popup=".options" up-popup-sticky>Settings</a>  
  ###
  open = (linkOrSelector, options = {}) ->
    $link = $(linkOrSelector)

    url = up.util.presentAttr($link, 'href')
    selector = options.target || $link.attr('up-popup') || 'body'
    origin = options.origin || $link.attr('up-origin') || 'bottom-right'
    animation = options.animation || $link.attr('up-animation') || 'roll-down'
    sticky = options.sticky || $link.is('[up-sticky]')
    history = options.history || false

    close()
    $popup = createHiddenPopup($link, selector, sticky)
    
    up.replace(selector, url,
      history: history
      insert: -> updated($link, $popup, origin, animation) 
    )

  ###*
  @method up.popup.close
  @param options.animation {String}
  ###
  close = (options) ->
    options = up.util.options(options, animation: 'fade-out')
    $popup = $('.up-popup')
    if $popup.length
      up.animate($popup, options.animation).then -> $popup.remove()
    $('[up-popup]').removeClass('up-current')
    
  autoclose = ->
    unless $('.up-popup').is('[up-sticky]')
      close()
    

  up.on('click', '[up-popup]', (event, $link) ->
    event.preventDefault()
    if $link.is('.up-current')
      close()
    else
      open($link)
  )
  
  up.on('click', 'body', (event, $body) ->
    $target = $(event.target)
    unless $target.closest('.up-popup').length || $target.closest('[up-popup]').length
      event.preventDefault()
      close()
  )
  
  up.bus.on('fragment:ready', ($fragment) ->
    unless $fragment.closest('.up-popup').length
      autoclose()
  )
  
  open: open
  close: close
  
)()


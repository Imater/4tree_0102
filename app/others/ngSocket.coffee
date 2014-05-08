#
# * livi18n.socket.js
# * https://github.com/chrisenytc/livi18n.socket.js
# *
# * Copyright (c) 2013 Christopher EnyTC
# * Licensed under the MIT license.
# 

# Module Copyright (c) 2013 Michael Benford

# Module for provide Socket.io support
"use strict"
angular.module("ngSocket", []).factory "$socket", [
  "$rootScope"
  ($rootScope) ->
    
    #Check if socket is undefined
    socket = io.connect( '//localhost:8888' )  if typeof socket is "undefined"
    
    #
    angularCallback = (callback) ->
      ->
        if callback
          args = arguments
          $rootScope.$apply ->
            callback.apply socket, args
            return

        return

    addListener = (name, scope, callback) ->
      if arguments.length is 2
        scope = null
        callback = arguments[1]
      socket.addListener name, angularCallback(callback)
      if scope isnt null
        scope.$on "$destroy", ->
          removeListener name, callback
          return

      return

    addListenerOnce = (name, callback) ->
      socket.once name, angularCallback(callback)
      return

    removeListener = (name, callback) ->
      socket.removeListener name, angularCallback(callback)
      return

    removeAllListeners = (name) ->
      socket.removeAllListeners name
      return

    emit = (name, data, callback) ->
      socket.emit name, data, angularCallback(callback)
      return
    is_online = () ->
      socket.socket.connected

    return (
      is_online: is_online
      addListener: addListener
      on: addListener
      once: addListenerOnce
      removeListener: removeListener
      removeAllListeners: removeAllListeners
      emit: emit
    )
]
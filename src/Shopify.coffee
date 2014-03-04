request = require 'request'
_ = require 'underscore'
qs = require 'querystring'
Q = require 'q'
utils = require './utils'

Array::toLowerCase = ->
  i = 0
  while i < @length
    @[i] = @[i].toLowerCase()
    i++
  @

module.exports = class Shopify
  constructor: (@config)->
    #return throw new Error "Must be constructed with a store!" unless @config
    @extend()

  methodize: (method)->
    do (method)->
      method = "#{method[0].toLowerCase()}#{_(method).rest().join('')}"
      if not Shopify::[method] then Shopify::[method] = (id)-> 
        @id id if id
        @action = method.split(/(?=[A-Z])/).join('_').toLowerCase()
        @

  nested_methodize: (methods)->
    do (methods)->
      [parent, nested] = methods
      if not Shopify::[nested] then Shopify::[nested] = (id)->
        @child id if id
        @nested = nested
        @

  extend: ->
      
    # CRUDS
    _([
        "Article", "Asset", "Blog", 
        "CarrierService", "Checkout", "Collect", "Comment", 
        "Country", "Location", "Province",
        "CustomCollection", 
        "Customer", "CustomerSavedSearch", "Event",  
        "Fulfillment", "FulfillmentService", "Order", "OrderRisk", "Page", 
        "Metafield",
        "Product", #"ProductImage", "ProductVariant", 
        "RecurringApplicationCharge", "ApplicationCharge", 
        "Redirect", "ScriptTag", "SmartCollection", 
        "Theme", "Transaction", "Webhook"
      ]).chain()
        .map(utils.pluralize)
        .forEach(@methodize)
    # Singulars
    _([
      "Shop"
      ]).forEach(@methodize)

    # Nested
    _([
        "ProductImage"
        "ProductVariant"
        "BlogArticle"
      ]).chain()
        .map(utils.nest)
        .forEach _.bind @nested_methodize, @

           
    # request methods
    _(
      count: "get,count"
      authors: "get,authors"
      tags: "get,tags"
      all: "get"
      get : "get"
      create: "post"
      update: "put"
      "delete": "del"
      search: 'get,search'
      ).map (type, method)->
        do (type, method)->
          [type, route] = type.split(',')
          if not Shopify::[method] then Shopify::[method] = (arg)->
            # detect type of argument passed
            if _.isObject(arg)
              @body arg if arg.body
              @qs arg if arg.query

            # detect Shopify id
            @id arg if _.isNumber(arg)
            
            # store slug from methodized fn
            @route route if route

            deferred = Q.defer()

            opts = url: @url(route)
            opts.json = @toJSON() if @body()
            callback = _.bind @__callback__, @, deferred
            req = request[type] opts, callback
            promise = deferred.promise
            # if global error handler exists
            promise.fail @errorHandler() if @errorHandler()
            promise

    #setters
    _([
        'id'
        'body'
        'route'
        'child'
        'qs'
        'errorHandler'
      ]).forEach (setter)-> 
        do (setter)-> 
        if not Shopify[setter] 
          Shopify::[setter] = (v)-> 
            if v
              @["_#{setter}"] = v
              @ 
            else 
              @["_#{setter}"]
        
    @

  toJSON: ->
    json = {}
    type = utils.singularize @action
    type = utils.singularize @nested if @nested
    json[type] = @body()
    json

  url: (route)->
    url = ["https://#{@config.apikey}:#{@config.password}@#{@config.store}.myshopify.com/admin"]
    throw new Error "nested queries require an ID to be set" if @nested and not (@id() or id)
    url.push "/#{@action}" if @action
    url.push "/#{@id()}" if @id()
    url.push "/#{@nested}" if @nested
    url.push "/#{@child()}" if @child()
    url.push "/#{route}" if route
    url.push('.json')
    url.push("?#{qs.stringify(@qs())}") if @qs()
    return url.join('')
      

  __callback__: (deferred, err, res, body)->
    return deferred.reject err if err
    if res.statusCode is 200 or 201
      try
        body = JSON.parse body
        return deferred.reject body.errors if body.errors
        body = body[Object.keys(body)[0]]
      
      catch e
        body = body
      finally
        deferred.resolve body
    else
      deferred.reject 
        statusCode: res.statusCode
        body: res.body?.errors
    return
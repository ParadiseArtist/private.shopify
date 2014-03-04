store = require './instance'

store
  .webhooks()                 # webhooks slug
  .qs(topic: "orders/create") # let's use a query string to filter the count
  .count()                    # count action (invoked a GET request behind the scenes)
  .then (count)->
    console.log count

store.customCollections().count().then (count)->
  console.log count
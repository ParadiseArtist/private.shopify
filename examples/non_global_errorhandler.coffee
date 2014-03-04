Shopify = require '../lib/Shopify'

store = new Shopify  
  store: 'test'
  apikey: "fake"
  password: "faker"
  sharedsecret: "fakest"

req = store.products().count()

req.then (count)->
  console.log count

req.fail (err)->
  console.log err
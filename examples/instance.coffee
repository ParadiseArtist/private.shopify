Shopify = require '../lib/Shopify'

store = new Shopify  
  store: 'test'
  apikey: "fake"
  password: "faker"
  sharedsecret: "fakest"

store.errorHandler (err)->
  console.log "\t\t>>> Error"
  console.log err

module.exports = store # for use in other examples
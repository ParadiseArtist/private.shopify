store = require './instance'

store.shop().metafields().all().then (metafields)->
  console.log metafields

store.shop().metafields().create(metafield).then (metafield)->
  console.log metafield

store.shop().metafields().delete(fakeId).then (res)->
  console.log res
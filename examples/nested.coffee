store = require './instance'

fakeId = 12345

store.products(fakeId).images().all().then (images)->
  console.log images

store.products(fakeId).images().create(fakeImage).then (image)->
  console.log image
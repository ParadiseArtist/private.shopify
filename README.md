Private.Shopify
====
* Basic module to manage a private app for your shopify store


Usage
-------------

```
npm install private.shopify
```


Methods
--------------

**Shopify#(namespace)***
  
  * namespaces are slugs that are used directly after the /admin part of the URL in Shopify's API

  example1: `/admin/products/count.json`        => store.products.count()
  example2: `/admin/shop.json`                   => store.shop().get()
  example3: `/admin/products/12345/images.json` => store.products(12345).images().get()
  example4: `/admin/products.json`              => store.products().all()

  * chainable for syntactic sugar

**Shopify#setters(value)**
  * Setter methods set various important request options BEFORE you invoke the request

  * Setters are chainable

  * Valid setters:
    - id (main id) `store.products().id(1235).get()`
    - body (for creating/updating) `store.products(12345).body(data).update()`
    - qs (for using query strings ala /admin/products/12345/images.json?since_id=1111) `store.products(12345).images().qs(since_id: 1111).get()`
    - route (sets a route on the Shopify instance)
    - child (for querying nested ids) `store.products(12345).images().child(666).body(fields).put()`
    - errorHandler (for setting a global error handler on a store)



**Shopify#(request)**
  
  * after settings your namespace/nested namespace and desired options (id, qs, etc), you can make the request.

  * all requests return a Promise object from the [Q](https://github.com/kriskowal/q) module and therefore are not chainable

  * Valid request types:
    - count   (GET the count for whatever namespace you have built)
    - tags:   (performs special tags action, which is a fancy GET request for certain namespaces)
    - all:    (GET all from namespace)
    - get:    (GET a singular ID)
    - create: (POST request to a namespace)
    - update: (PUT updates to a namespace)
    - delete: (DELTE request to a namespace)
    - authors (special action for blogs/articles checkout [Shopify API](http://docs.shopify.com/api/article#authors) for more info)
    - search: (performs a customer search, checkout [Shopify API](http://docs.shopify.com/api/customer#search) docs for more info)
  

* checkout examples/

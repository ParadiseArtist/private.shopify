(function() {
  var Q, Shopify, qs, request, utils, _;

  request = require('request');

  _ = require('underscore');

  qs = require('querystring');

  Q = require('q');

  utils = require('./utils');

  Array.prototype.toLowerCase = function() {
    var i;
    i = 0;
    while (i < this.length) {
      this[i] = this[i].toLowerCase();
      i++;
    }
    return this;
  };

  module.exports = Shopify = (function() {

    function Shopify(config) {
      this.config = config;
      this.extend();
    }

    Shopify.prototype.methodize = function(method) {
      return (function(method) {
        method = "" + (method[0].toLowerCase()) + (_(method).rest().join(''));
        if (!Shopify.prototype[method]) {
          return Shopify.prototype[method] = function(id) {
            if (id) this.id(id);
            this.action = method.split(/(?=[A-Z])/).join('_').toLowerCase();
            return this;
          };
        }
      })(method);
    };

    Shopify.prototype.nested_methodize = function(methods) {
      return (function(methods) {
        var nested, parent;
        parent = methods[0], nested = methods[1];
        if (!Shopify.prototype[nested]) {
          return Shopify.prototype[nested] = function(id) {
            if (id) this.child(id);
            this.nested = nested;
            return this;
          };
        }
      })(methods);
    };

    Shopify.prototype.extend = function() {
      _(["Article", "Asset", "Blog", "CarrierService", "Checkout", "Collect", "Comment", "Country", "Location", "Province", "CustomCollection", "Customer", "CustomerSavedSearch", "Event", "Fulfillment", "FulfillmentService", "Order", "OrderRisk", "Page", "Metafield", "Product", "RecurringApplicationCharge", "ApplicationCharge", "Redirect", "ScriptTag", "SmartCollection", "Theme", "Transaction", "Webhook"]).chain().map(utils.pluralize).forEach(this.methodize);
      _(["Shop"]).forEach(this.methodize);
      _(["ProductImage", "ProductVariant", "BlogArticle"]).chain().map(utils.nest).forEach(_.bind(this.nested_methodize, this));
      _({
        count: "get,count",
        authors: "get,authors",
        tags: "get,tags",
        all: "get",
        get: "get",
        create: "post",
        update: "put",
        "delete": "del",
        search: 'get,search'
      }).map(function(type, method) {
        return (function(type, method) {
          var route, _ref;
          _ref = type.split(','), type = _ref[0], route = _ref[1];
          if (!Shopify.prototype[method]) {
            return Shopify.prototype[method] = function(arg) {
              var callback, deferred, opts, promise, req;
              if (_.isObject(arg)) {
                if (arg.body) this.body(arg);
                if (arg.query) this.qs(arg);
              }
              if (_.isNumber(arg)) this.id(arg);
              if (route) this.route(route);
              deferred = Q.defer();
              opts = {
                url: this.url(route)
              };
              if (this.body()) opts.json = this.toJSON();
              callback = _.bind(this.__callback__, this, deferred);
              req = request[type](opts, callback);
              promise = deferred.promise;
              if (this.errorHandler()) promise.fail(this.errorHandler());
              return promise;
            };
          }
        })(type, method);
      });
      _(['id', 'body', 'route', 'child', 'qs', 'errorHandler']).forEach(function(setter) {
        (function(setter) {})(setter);
        if (!Shopify[setter]) {
          return Shopify.prototype[setter] = function(v) {
            if (v) {
              this["_" + setter] = v;
              return this;
            } else {
              return this["_" + setter];
            }
          };
        }
      });
      return this;
    };

    Shopify.prototype.toJSON = function() {
      var json, type;
      json = {};
      type = utils.singularize(this.action);
      if (this.nested) type = utils.singularize(this.nested);
      json[type] = this.body();
      return json;
    };

    Shopify.prototype.url = function(route) {
      var url;
      url = ["https://" + this.config.apikey + ":" + this.config.password + "@" + this.config.store + ".myshopify.com/admin"];
      if (this.nested && !(this.id() || id)) {
        throw new Error("nested queries require an ID to be set");
      }
      if (this.action) url.push("/" + this.action);
      if (this.id()) url.push("/" + (this.id()));
      if (this.nested) url.push("/" + this.nested);
      if (this.child()) url.push("/" + (this.child()));
      if (route) url.push("/" + route);
      url.push('.json');
      if (this.qs()) url.push("?" + (qs.stringify(this.qs())));
      return url.join('');
    };

    Shopify.prototype.__callback__ = function(deferred, err, res, body) {
      var _ref;
      if (err) return deferred.reject(err);
      if (res.statusCode === 200 || 201) {
        try {
          body = JSON.parse(body);
          if (body.errors) return deferred.reject(body.errors);
          body = body[Object.keys(body)[0]];
        } catch (e) {
          body = body;
        } finally {
          deferred.resolve(body);
        }
      } else {
        deferred.reject({
          statusCode: res.statusCode,
          body: (_ref = res.body) != null ? _ref.errors : void 0
        });
      }
    };

    return Shopify;

  })();

}).call(this);

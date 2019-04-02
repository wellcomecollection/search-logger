// This is the generic loader from segment
!(function() {
  var analytics = (window.analytics = window.analytics || []);
  if (!analytics.initialize)
    if (analytics.invoked)
      window.console &&
        console.error &&
        console.error('Segment snippet included twice.');
    else {
      analytics.invoked = !0;
      analytics.methods = [
        'trackSubmit',
        'trackClick',
        'trackLink',
        'trackForm',
        'pageview',
        'identify',
        'reset',
        'group',
        'track',
        'ready',
        'alias',
        'debug',
        'page',
        'once',
        'off',
        'on'
      ];
      analytics.factory = function(t) {
        return function() {
          var e = Array.prototype.slice.call(arguments);
          e.unshift(t);
          analytics.push(e);
          return analytics;
        };
      };
      for (var t = 0; t < analytics.methods.length; t++) {
        var e = analytics.methods[t];
        analytics[e] = analytics.factory(e);
      }
      analytics.load = function(t, e) {
        var n = document.createElement('script');
        n.type = 'text/javascript';
        n.async = !0;
        n.src =
          'https://cdn.segment.com/analytics.js/v1/' + t + '/analytics.min.js';
        var a = document.getElementsByTagName('script')[0];
        a.parentNode.insertBefore(n, a);
        analytics._loadOptions = e;
      };
      analytics.SNIPPET_VERSION = '4.1.0';
      analytics.load('78Czn5jNSaMSVrBq2J9K4yJjWxh6fyRI');
    }
})();

// This is the tracking
(function() {
  if (window.location.pathname.match('/works') && 'URLSearchParams' in window) {
    var workPageMatch = window.location.pathname.match(
      /^\/works\/([a-z0-9]+)$/
    );
    var itemPageMatch = window.location.pathname.match(
      /^\/works\/([a-z0-9]+)\/items$/
    );
    var query = Array.from(new URLSearchParams(window.location.search)).reduce(
      function(acc, keyVal) {
        acc[keyVal[0]] = keyVal[1];
        return acc;
      },
      {}
    );
    var toggles = document.cookie.split(';').reduce(function(acc, cookie) {
      var parts = cookie.split('=');
      var key = parts[0].trim();
      var value = parts[1].trim();

      if (key.match('toggle_')) {
        acc[key] = value;
      }
      return acc;
    }, {});

    if (workPageMatch) {
      analytics.track('Catalogue View Work', {
        resource: {
          type: 'Work',
          title: document.title.replace(' | Wellcome Collection', ''),
          id: workPageMatch[1]
        },
        query: query,
        toggles: toggles
      });
    } else if (itemPageMatch) {
      analytics.track('Catalogue View Item', {
        resource: {
          type: 'Item',
          title: document.title.replace(' | Wellcome Collection', ''),
          id: itemPageMatch[1]
        },
        query: query,
        toggles: toggles
      });
    } else {
      analytics.track('Catalogue Search', {
        resource: {
          type: 'ResultList'
        },
        query: query,
        toggles: toggles
      });
    }
  }
})();

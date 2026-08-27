// CloudFront Function (viewer request)
// Handles: www→apex redirect, clean-URL rewriting
function handler(event) {
  var request = event.request;
  var host    = request.headers.host && request.headers.host.value;
  var uri     = request.uri;

  // Redirect www → apex (or apex → www if www_redirect=false)
  if (host && host.startsWith('www.')) {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: { value: 'https://' + host.slice(4) + uri },
      },
    };
  }

  // Rewrite clean URLs to their index.html
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
  } else if (!uri.split('/').pop().includes('.')) {
    request.uri = uri + '/index.html';
  }

  return request;
}

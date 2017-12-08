/* Take a query strong (without leading ?) and return keys and parameters
 * as key-value pairs */
function parseParamString( pstring ){
  // trim leading question mark
  pstring = pstring.slice(1);

  // resulting key/value containing any/each of the URL parameters
  var params = {};

  // do we have multiple paramaters?
  if( pstring.indexOf( "&" ) != -1 ) {
     // split the parameter list up...
     var plist = pstring.split( "&" );
     var ix = 0;
     for ( ix = 0; ix < plist.length; ix++ ) {
         var nv = plist[ ix ].split( "=" )
         if ( nv.length == 2 ) {
             params[ nv[ 0 ] ] = nv[ 1 ];
         }
     }
  } else {
      var nv = pstring.split( "=" )
      if ( nv.length == 2 ) {
         params[ nv[ 0 ] ] = nv[ 1 ];
      }
  }

  return params;
}

// Return key-value pairs for parameters for the current URL
function parseURL( ) {
  return parseParamString(window.location.search)
}

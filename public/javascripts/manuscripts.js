$(document).ready(function() {

    // hide all the sub menu's
    $( ".sublist").hide();

    // hide the transcript selector, color key and XML button
    $("#view-control").hide();
    $("#view-control-title").hide();
    $("#color-key-div").hide();
    $("#xml-button").hide();

    // sub menu toggle behavior handlers
	$(".mainlist-item").toggle(function(){
        $( ".sublist").slideUp(75);
        $(this).parent().next().slideDown(450, function(){
           $(this).children('.sublist-item').first().click();
        });
	},
	function(){
		$(this).parent().next().slideUp(75);
	});

    // selection box changes
    $("#view-control").change(function () {

        // get the current view
        var view = getManuscriptViewState( );
        /* use showManuscript rather than redirectToManuscript, preserving
         * the position */
        var newURL = changeUrlQueryString(window.location, 'view', view);
        history.replaceState(null, null, newURL);
        showManuscript( $("#transcription-name").attr("href"), view );
    });

    //
    // menu item handlers
    //

    $("#SJA-manuscript").click(function() {
        redirectToManuscript( "SJA", "diplomatic")
    });

    $("#SJA-description").click(function() {
        redirectToDescription( "SJA" );
    });


    $("#SJC-manuscript").click(function() {
        redirectToManuscript( "SJC", "diplomatic")
    });

    $("#SJC-description").click(function() {
        redirectToDescription( "SJC" );
    });


    $("#SJD-manuscript").click(function() {
        redirectToManuscript( "SJD", "diplomatic")
    });

    $("#SJD-description").click(function() {
        redirectToDescription( "SJD" );
    });


    $("#SJE-manuscript").click(function() {
        redirectToManuscript( "SJE", "diplomatic")
    });

    $("#SJE-description").click(function() {
        redirectToDescription( "SJE" );
    });


    $("#SJEx-manuscript").click(function() {
        redirectToManuscript( "SJEx", "diplomatic")
    });

    $("#SJEx-description").click(function() {
        redirectToDescription( "SJEx" );
    });


    $("#SJL-manuscript").click(function() {
        redirectToManuscript( "SJL", "diplomatic")
    });

    $("#SJL-description").click(function() {
        redirectToDescription( "SJL" );
    });


    $("#SJP-manuscript").click(function() {
        redirectToManuscript( "SJP", "diplomatic")
    });

    $("#SJP-description").click(function() {
        redirectToDescription( "SJP" );
    });


    $("#SJU-manuscript").click(function() {
        redirectToManuscript( "SJU", "diplomatic")
    });

    $("#SJU-description").click(function() {
        redirectToDescription( "SJU" );
    });


    $("#SJV-manuscript").click(function() {
        redirectToManuscript( "SJV", "diplomatic")
    });

    $("#SJV-description").click(function() {
        redirectToDescription( "SJV" );
    });

    // load the URL paramaters...
    var params = parseURL();
    // if we are going to a specific page...
    if( ( params["manuscript"] != null ) && ( params["view"] != null ) ) {
        // set the GUI widgets to the correct state
        setGUIForManuscript( params["manuscript"], params["view"] );
        showManuscript( params["manuscript"], params["view"], params["folio"] );
        $("#page").removeClass();
        $("#page").addClass("manuscript")
        $("#page-header").removeClass("manuscript-page").addClass("manuscript-view");
    } else if( params["description"] != null ) {
        // set the GUI widgets to the correct state
        setGUIForDescription( params["description"] );
        showDescription( params["description"] );
        $("#page").removeClass();
        $("#page").addClass("description");
        $("#page-header").removeClass("manuscript-view").addClass("manuscript-page");
    } else {
       // otherwise, set the default view...
       $("#overview").addClass("active");
        $("#page").removeClass();
        $("#page").addClass("page");
        $("#page-header").removeClass("manuscript-view").addClass("manuscript-page");
    }
});

function moveScroller() {
    var move = function() {
        var st = $(window).scrollTop();
        var ot = $("#transcription-name").offset().top;
        var s = $("#content-controls");
        var d = $("#content-display");
        if(st > ot) {
            s.css({
                position: "fixed",
                width: "600px",
                top: "0px",
                margin: "0px 23px 0px 25px"

            });

            d.css ({ top: "45px"})
        } else {
            if(st <= ot) {
                s.css({
                    position: "relative",
                    width: "",
                    top: "",
                    margin: "15px 23px 0px 25px"
                });

                d.css ({ top: ""})
            }
        }
    };
    $(window).scroll(move);
    move();
}

function showManuscript( name, view, scrollto_id ) {

    // set the manuscript name; we may need this later when setting a new view
    $("#transcription-name").attr("href", name );

    // remove any color box decoration/handlers... we will add more shortly.
    $.colorbox.remove();

    // nice wait display...
    showWaitOverlay();

    // load the resource and report an error if unsuccessful
    var resource = name.replace( "SJ", "MS") + "-" + view + ".html";
    loadRemoteResource( resource, "#content-display", makeDocReadyCallback( false, scrollto_id ) );
}

function showDescription( name ) {

    // remove any color box decoration/handlers... we will add more shortly.
    $.colorbox.remove();

    // nice wait display...
    showWaitOverlay();

    // load the resource and report an error if unsuccessful
    var resource = name + "-description.html";
    loadRemoteResource( resource, "#content-display", makeDocReadyCallback( true, null ) );
}

// scroll_to_id is optional
function redirectToManuscript( name, view, scroll_to_id ) {

    var newURL = "manuscript.html?manuscript=" + name + "&view=" + view;
    if (typeof scroll_to_id !== 'undefined') {
        newURL += "#" + scroll_to_id;
    }
    document.location.href = newURL;
}

function redirectToDescription( name ) {

    var newURL = "manuscript.html?description=" + name;
    document.location.href = newURL;
}

function setGUIForManuscript( name, view ) {

    // show the transcript selector, color key and XML button
    $("#view-control").show();
    $("#view-control-title").show();
    $("#color-key-div").show();
    $("#xml-button").show();

    // clear any existing content...
    $("#content-display").empty( );

    // setup the correct classes for specific views
    $("#content-display").removeClass("overview description manuscript");
    $("#content-display").addClass("manuscript");

    // configure the XML button so it does the right thing...
    setXMLButtonAttributes( name );

    // set up the nav bar correctly...
    var navElement = $( "#" + name + "-manuscript");
    navElement.parent( ).slideDown( 0 );
    highliteNavElement( navElement );

    // set the view dropdown
    setManuscriptViewState( view )
}

function setGUIForDescription( name ) {

    // hide the transcript selector and color key and show the XML button
    $("#view-control").hide();
    $("#view-control-title").hide();
    $("#color-key-div").hide();
    $("#xml-button").show();

    // clear any existing content...
    $("#content-display").empty();

    // setup the correct classes for specific views
    $("#content-display").removeClass("overview description manuscript");
    $("#content-display").addClass("description");

    // configure the XML button so it does the right thing...
    setXMLButtonAttributes( name.replace( "SJ", "") + "Description" );

    // set up the nav bar correctly...
    var navElement = $( "#" + name + "-description");
    navElement.parent().slideDown( 0 );
    highliteNavElement( navElement );
}

function setXMLButtonAttributes( name ) {

    var xml_href = "/xml/" + name + ".xml";
    $("#xml-button").attr("href", xml_href );
    $("#xml-button").attr("target", "_blank" );
}

function highliteNavElement( element ) {

    // clear any existing highlights...
    $( ".sublist-item").removeClass( "active");
    $("#overview").removeClass( "active");

    // and highlight this element.
    element.addClass( "active");
}

// get the state of the view dropdown so we know which view to display
function getManuscriptViewState( ) {

    var view = $("#view-control option:selected").text( );
    switch( view ) {
        case "All Tags":
            return( "alltags" );

        case "Critical":
            return( "critical" );

        case "Diplomatic":
            return( "diplomatic" );

        case "Scribal":
        default:
           return( "scribal" );
    }
}

// set the state of the view drop-down to reflect what we are currently showing
function setManuscriptViewState( name ) {
    $("#view-control" ).val( name );
}

/* accept a location object; return the same URL with the query string at a
 * given key altered to a specified value. If the key provided is not found
 * in the query string, append it to the query string. */
function changeUrlQueryString( loc, key, value ){
  var build_url = loc.origin + loc.pathname;

  var queries = parseParamString(loc.search.slice(1));
  queries[key] = value;
  var first_it = true;
  for (q in queries) {
    if (first_it) {
      build_url += '?';
      first_it = false;
    } else {
      build_url += '&';
    }
    build_url += q + '=' + queries[q];
  }
  build_url += loc.hash;
  return build_url;
}

function makeDocReadyCallback( enable_popup, scrollto_id ) {

    var callback = function( ) {

        if( enable_popup == true ) {
           // enable the image pop-up behavior
           $( ".popup-span" ).dialog({ width: "auto", autoOpen: false, show: "blind", hide: "blind" });
        }

        // attach the click handler to open the image pop-up
        $(".graphic" ).click(function() {
            var popupdiv = "#" + $(this).attr( "src" ) + "-popup";
            $( popupdiv ).dialog( "open" )
        });

        // Enable the lightbox behavior
        $(".imglightbox").colorbox( { iframe:true, width: "70%", height: "95%" } );

        // decorate the tooltips...
        decorateTooltips( );

        // scroll to the right position if appropriate...
        if( scrollto_id != null ) {
           $('html,body').animate( { scrollTop: $("#" + scrollto_id ).offset().top - 15 },'slow' );
        }
    }

    return( callback )

}

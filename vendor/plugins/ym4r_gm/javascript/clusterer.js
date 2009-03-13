// Clusterer.js - marker clustering routines for Google Maps apps
//
// The original version of this code is available at:
// http://www.acme.com/javascript/
//
// Copyright © 2005,2006 by Jef Poskanzer <jef@mail.acme.com>.
// All rights reserved.
//
// Modified for inclusion into the YM4R library in accordance with the 
// following license:
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// For commentary on this license please see http://www.acme.com/license.html


// Constructor.
Clusterer = function(markers,icon,maxVisibleMarkers,gridSize,minMarkersPerCluster,maxLinesPerInfoBox) {	
    this.markers = [];
    if(markers){
	for(var i =0 ; i< markers.length ; i++){
	    this.addMarker(markers[i]);
	}
    }    
    this.clusters = [];
    this.timeout = null;
        
    this.maxVisibleMarkers = maxVisibleMarkers || 150;
    this.gridSize = gridSize || 5;
    this.minMarkersPerCluster = minMarkersPerCluster || 5;
    this.maxLinesPerInfoBox = maxLinesPerInfoBox || 10;
    
    this.icon = icon || G_DEFAULT_ICON;
}

Clusterer.prototype = new GOverlay();

Clusterer.prototype.initialize = function ( map ){
    this.map = map;
    this.currentZoomLevel = map.getZoom();
   
    GEvent.addListener( map, 'zoomend', Clusterer.makeCaller( Clusterer.display, this ) );
    GEvent.addListener( map, 'moveend', Clusterer.makeCaller( Clusterer.display, this ) );
    GEvent.addListener( map, 'infowindowclose', Clusterer.makeCaller( Clusterer.popDown, this ) );
    //Set map for each marker
    for(var i = 0,len = this.markers.length ; i < len ; i++){
	this.markers[i].setMap( map );
    }
    this.displayLater();
}

Clusterer.prototype.remove = function(){
     for ( var i = 0; i < this.markers.length; ++i ){
	 this.removeMarker(this.markers[i]);
     }
}

Clusterer.prototype.copy = function(){
    return new Clusterer(this.markers,this.icon,this.maxVisibleMarkers,this.gridSize,this.minMarkersPerCluster,this.maxLinesPerInfoBox);
}

Clusterer.prototype.redraw = function(force){
    this.displayLater();
}

// Call this to change the cluster icon.
Clusterer.prototype.setIcon = function ( icon ){
    this.icon = icon;
}

// Call this to add a marker.
Clusterer.prototype.addMarker = function ( marker, description){
    marker.onMap = false;
    this.markers.push( marker );
    marker.description = marker.description || description;
    if(this.map != null){
	marker.setMap(this.map);
	this.displayLater();
    }
};


// Call this to remove a marker.
Clusterer.prototype.removeMarker = function ( marker ){
    for ( var i = 0; i < this.markers.length; ++i )
	if ( this.markers[i] == marker ){
	    if ( marker.onMap )
		this.map.removeOverlay( marker );
	    for ( var j = 0; j < this.clusters.length; ++j ){
		var cluster = this.clusters[j];
		if ( cluster != null ){
		    for ( var k = 0; k < cluster.markers.length; ++k )
			if ( cluster.markers[k] == marker ){
			    cluster.markers[k] = null;
			    --cluster.markerCount;
			    break;
			}
		    if ( cluster.markerCount == 0 ){
			this.clearCluster( cluster );
			this.clusters[j] = null;
			}
		    else if ( cluster == this.poppedUpCluster )
			Clusterer.rePop( this );
		    }
		}
	    this.markers[i] = null;
	    break;
	    }
    this.displayLater();
};

Clusterer.prototype.displayLater = function (){
    if ( this.timeout != null )
	clearTimeout( this.timeout );
    this.timeout = setTimeout( Clusterer.makeCaller( Clusterer.display, this ), 50 );
};

Clusterer.display = function ( clusterer ){
    var i, j, marker, cluster, len, len2;

    clearTimeout( clusterer.timeout );

    var newZoomLevel = clusterer.map.getZoom();
    if ( newZoomLevel != clusterer.currentZoomLevel ){
	// When the zoom level changes, we have to remove all the clusters.
	for ( i = 0 , len = clusterer.clusters.length; i < len; ++i ){
	    if ( clusterer.clusters[i] != null ){
		clusterer.clearCluster( clusterer.clusters[i] );
		clusterer.clusters[i] = null;
	    }
	}
	clusterer.clusters.length = 0;
	clusterer.currentZoomLevel = newZoomLevel;
    }

    // Get the current bounds of the visible area.
    var bounds = clusterer.map.getBounds();

    // Expand the bounds a little, so things look smoother when scrolling
    // by small amounts.
    var sw = bounds.getSouthWest();
    var ne = bounds.getNorthEast();
    var dx = ne.lng() - sw.lng();
    var dy = ne.lat() - sw.lat();
    dx *= 0.10;
    dy *= 0.10;
    bounds = new GLatLngBounds(
      new GLatLng( sw.lat() - dy, sw.lng() - dx ),
      new GLatLng( ne.lat() + dy, ne.lng() + dx ) 
    );

    // Partition the markers into visible and non-visible lists.
    var visibleMarkers = [];
    var nonvisibleMarkers = [];
    for ( i = 0, len = clusterer.markers.length ; i < len; ++i ){
	marker = clusterer.markers[i];
	if ( marker != null )
	    if ( bounds.contains( marker.getPoint() ) )
		visibleMarkers.push( marker );
	    else
		nonvisibleMarkers.push( marker );
    }

    // Take down the non-visible markers.
    for ( i = 0, len = nonvisibleMarkers.length ; i < len; ++i ){
	marker = nonvisibleMarkers[i];
	if ( marker.onMap ){
	    clusterer.map.removeOverlay( marker );
	    marker.onMap = false;
	}
    }

    // Take down the non-visible clusters.
    for ( i = 0, len = clusterer.clusters.length ; i < len ; ++i ){
	cluster = clusterer.clusters[i];
	if ( cluster != null && ! bounds.contains( cluster.marker.getPoint() ) && cluster.onMap ){
	    clusterer.map.removeOverlay( cluster.marker );
	    cluster.onMap = false;
	}
    }

    // Clustering!  This is some complicated stuff.  We have three goals
    // here.  One, limit the number of markers & clusters displayed, so the
    // maps code doesn't slow to a crawl.  Two, when possible keep existing
    // clusters instead of replacing them with new ones, so that the app pans
    // better.  And three, of course, be CPU and memory efficient.
    if ( visibleMarkers.length > clusterer.maxVisibleMarkers ){
	// Add to the list of clusters by splitting up the current bounds
	// into a grid.
	var latRange = bounds.getNorthEast().lat() - bounds.getSouthWest().lat();
	var latInc = latRange / clusterer.gridSize;
	var lngInc = latInc / Math.cos( ( bounds.getNorthEast().lat() + bounds.getSouthWest().lat() ) / 2.0 * Math.PI / 180.0 );
	for ( var lat = bounds.getSouthWest().lat(); lat <= bounds.getNorthEast().lat(); lat += latInc )
	    for ( var lng = bounds.getSouthWest().lng(); lng <= bounds.getNorthEast().lng(); lng += lngInc ){
		cluster = new Object();
		cluster.clusterer = clusterer;
		cluster.bounds = new GLatLngBounds( new GLatLng( lat, lng ), new GLatLng( lat + latInc, lng + lngInc ) );
		cluster.markers = [];
		cluster.markerCount = 0;
		cluster.onMap = false;
		cluster.marker = null;
		clusterer.clusters.push( cluster );
	    }

	// Put all the unclustered visible markers into a cluster - the first
	// one it fits in, which favors pre-existing clusters.
	for ( i = 0, len = visibleMarkers.length ; i < len; ++i ){
	    marker = visibleMarkers[i];
	    if ( marker != null && ! marker.inCluster ){
		for ( j = 0, len2 = clusterer.clusters.length ; j < len2 ; ++j ){
		    cluster = clusterer.clusters[j];
		    if ( cluster != null && cluster.bounds.contains( marker.getPoint() ) ){
			cluster.markers.push( marker );
			++cluster.markerCount;
			marker.inCluster = true;
		    }
		}
	    }
	}

	// Get rid of any clusters containing only a few markers.
	for ( i = 0, len = clusterer.clusters.length ; i < len ; ++i )
	    if ( clusterer.clusters[i] != null && clusterer.clusters[i].markerCount < clusterer.minMarkersPerCluster ){
		clusterer.clearCluster( clusterer.clusters[i] );
		clusterer.clusters[i] = null;
	    }

	// Shrink the clusters list.
	for ( i = clusterer.clusters.length - 1; i >= 0; --i )
	    if ( clusterer.clusters[i] != null )
		break;
	    else
		--clusterer.clusters.length;

	// Ok, we have our clusters.  Go through the markers in each
	// cluster and remove them from the map if they are currently up.
	for ( i = 0, len = clusterer.clusters.length ; i < len; ++i ){
	    cluster = clusterer.clusters[i];
	    if ( cluster != null ){
		for ( j = 0 , len2 = cluster.markers.length ; j < len2; ++j ){
		    marker = cluster.markers[j];
		    if ( marker != null && marker.onMap ){
			clusterer.map.removeOverlay( marker );
			marker.onMap = false;
		    }
		}
	    }
	}
	
	// Now make cluster-markers for any clusters that need one.
	for ( i = 0, len = clusterer.clusters.length; i < len; ++i ){
	    cluster = clusterer.clusters[i];
	    if ( cluster != null && cluster.marker == null ){
		// Figure out the average coordinates of the markers in this
		// cluster.
		var xTotal = 0.0, yTotal = 0.0;
		for ( j = 0, len2 = cluster.markers.length; j < len2 ; ++j ){
		    marker = cluster.markers[j];
		    if ( marker != null ){
			xTotal += ( + marker.getPoint().lng() );
			yTotal += ( + marker.getPoint().lat() );
		    }
		}
		var location = new GLatLng( yTotal / cluster.markerCount, xTotal / cluster.markerCount );
		marker = new GMarker( location, { icon: clusterer.icon } );
		cluster.marker = marker;
		GEvent.addListener( marker, 'click', Clusterer.makeCaller( Clusterer.popUp, cluster ) );
	    }
	}
    }

    // Display the visible markers not already up and not in clusters.
    for ( i = 0, len = visibleMarkers.length; i < len; ++i ){
	marker = visibleMarkers[i];
	if ( marker != null && ! marker.onMap && ! marker.inCluster )
	{
	    clusterer.map.addOverlay( marker );
	    marker.addedToMap();
	    marker.onMap = true;
	}
    }

    // Display the visible clusters not already up.
    for ( i = 0, len = clusterer.clusters.length ; i < len; ++i ){
	cluster = clusterer.clusters[i];
	if ( cluster != null && ! cluster.onMap && bounds.contains( cluster.marker.getPoint() )){
	    clusterer.map.addOverlay( cluster.marker );
	    cluster.onMap = true;
	}
    }

    // In case a cluster is currently popped-up, re-pop to get any new
    // markers into the infobox.
    Clusterer.rePop( clusterer );
};


Clusterer.popUp = function ( cluster ){
    var clusterer = cluster.clusterer;
    var html = '<table width="300">';
    var n = 0;
    for ( var i = 0 , len = cluster.markers.length; i < len; ++i )
	{
	var marker = cluster.markers[i];
	if ( marker != null )
	    {
	    ++n;
	    html += '<tr><td>';
	    if ( marker.getIcon().smallImage != null )
		html += '<img src="' + marker.getIcon().smallImage + '">';
	    else
		html += '<img src="' + marker.getIcon().image + '" width="' + ( marker.getIcon().iconSize.width / 2 ) + '" height="' + ( marker.getIcon().iconSize.height / 2 ) + '">';
	    html += '</td><td>' + marker.description + '</td></tr>';
	    if ( n == clusterer.maxLinesPerInfoBox - 1 && cluster.markerCount > clusterer.maxLinesPerInfoBox  )
		{
		html += '<tr><td colspan="2">...and ' + ( cluster.markerCount - n ) + ' more</td></tr>';
		break;
		}
	    }
	}
    html += '</table>';
    clusterer.map.closeInfoWindow();
    cluster.marker.openInfoWindowHtml( html );
    clusterer.poppedUpCluster = cluster;
};

Clusterer.rePop = function ( clusterer ){
    if ( clusterer.poppedUpCluster != null )
	Clusterer.popUp( clusterer.poppedUpCluster );
};

Clusterer.popDown = function ( clusterer ){
    clusterer.poppedUpCluster = null;
};

Clusterer.prototype.clearCluster = function ( cluster ){
    var i, marker;

    for ( i = 0; i < cluster.markers.length; ++i ){
	if ( cluster.markers[i] != null ){
	    cluster.markers[i].inCluster = false;
	    cluster.markers[i] = null;
	}
    }
    
    cluster.markers.length = 0;
    cluster.markerCount = 0;
    
    if ( cluster == this.poppedUpCluster )
	this.map.closeInfoWindow();
    
    if ( cluster.onMap )
    {
	this.map.removeOverlay( cluster.marker );
	cluster.onMap = false;
    }
};

// This returns a function closure that calls the given routine with the
// specified arg.
Clusterer.makeCaller = function ( func, arg ){
    return function () { func( arg ); };
};


// Augment GMarker so it handles markers that have been created but
// not yet addOverlayed.
GMarker.prototype.setMap = function ( map ){
    this.map = map;
};

GMarker.prototype.getMap = function (){
    return this.map;
}

GMarker.prototype.addedToMap = function (){
    this.map = null;
};


GMarker.prototype.origOpenInfoWindow = GMarker.prototype.openInfoWindow;
GMarker.prototype.openInfoWindow = function ( node, opts ){
    if ( this.map != null )
	return this.map.openInfoWindow( this.getPoint(), node, opts );
    else
	return this.origOpenInfoWindow( node, opts );
};

GMarker.prototype.origOpenInfoWindowHtml = GMarker.prototype.openInfoWindowHtml;
GMarker.prototype.openInfoWindowHtml = function ( html, opts ){
    if ( this.map != null )
	return this.map.openInfoWindowHtml( this.getPoint(), html, opts );
    else
	return this.origOpenInfoWindowHtml( html, opts );
};

GMarker.prototype.origOpenInfoWindowTabs = GMarker.prototype.openInfoWindowTabs;
GMarker.prototype.openInfoWindowTabs = function ( tabNodes, opts ){
    if ( this.map != null )
	return this.map.openInfoWindowTabs( this.getPoint(), tabNodes, opts );
    else
	return this.origOpenInfoWindowTabs( tabNodes, opts );
};

GMarker.prototype.origOpenInfoWindowTabsHtml = GMarker.prototype.openInfoWindowTabsHtml;
GMarker.prototype.openInfoWindowTabsHtml = function ( tabHtmls, opts ){
    if ( this.map != null )
       return this.map.openInfoWindowTabsHtml( this.getPoint(), tabHtmls, opts );
    else
       return this.origOpenInfoWindowTabsHtml( tabHtmls, opts );
};

GMarker.prototype.origShowMapBlowup = GMarker.prototype.showMapBlowup;
GMarker.prototype.showMapBlowup = function ( opts ){
    if ( this.map != null )
	return this.map.showMapBlowup( this.getPoint(), opts );
    else
	return this.origShowMapBlowup( opts );
};


function addDescriptionToMarker(marker, description){
    marker.description = description;
    return marker;
}

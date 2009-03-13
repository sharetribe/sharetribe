function GMarkerGroup(active, markers, markersById) {
    this.active = active;
    this.markers = markers || new Array();
    this.markersById = markersById || new Object();
}

GMarkerGroup.prototype = new GOverlay();

GMarkerGroup.prototype.initialize = function(map) {
    this.map = map;
    
    if(this.active){
	for(var i = 0 , len = this.markers.length; i < len; i++) {
	    this.map.addOverlay(this.markers[i]);
	}
	for(var id in this.markersById){
	    this.map.addOverlay(this.markersById[id]);
	}
    }
}

//If not already done (ie if not inactive) remove all the markers from the map
GMarkerGroup.prototype.remove = function() {
    this.deactivate();
}

GMarkerGroup.prototype.redraw = function(force){
    //Nothing to do : markers are already taken care of
}

//Copy the data to a new Marker Group
GMarkerGroup.prototype.copy = function() {
    var overlay = new GMarkerGroup(this.active);
    overlay.markers = this.markers; //Need to do deep copy
    overlay.markersById = this.markersById; //Need to do deep copy
    return overlay;
}

//Inactivate the Marker group and clear the internal content
GMarkerGroup.prototype.clear = function(){
    //deactivate the map first (which removes the markers from the map)
    this.deactivate();
    //Clear the internal content
    this.markers = new Array();
    this.markersById = new Object();
}

//Add a marker to the GMarkerGroup ; Adds it now to the map if the GMarkerGroup is active
GMarkerGroup.prototype.addMarker = function(marker,id){
    if(id == undefined){
	this.markers.push(marker);
    }else{
	this.markersById[id] = marker;
    }
    if(this.active && this.map != undefined ){
	this.map.addOverlay(marker);
    }
}

//Open the info window (or info window tabs) of a marker
GMarkerGroup.prototype.showMarker = function(id){
    var marker = this.markersById[id];
    if(marker != undefined){
	GEvent.trigger(marker,"click");
    }
}

//Activate (or deactivate depending on the argument) the GMarkerGroup
GMarkerGroup.prototype.activate = function(active){
    active = (active == undefined) ? true : active;
    if(!active){
	if(this.active){
	    if(this.map != undefined){
		for(var i = 0 , len = this.markers.length; i < len; i++){
		    this.map.removeOverlay(this.markers[i])
		}
		for(var id in this.markersById){
		    this.map.removeOverlay(this.markersById[id]);
		}
	    }
	    this.active = false;
	}
    }else{
	if(!this.active){
	    if(this.map != undefined){
		for(var i = 0 , len = this.markers.length; i < len; i++){
		    this.map.addOverlay(this.markers[i]);
		}
		for(var id in this.markersById){
		    this.map.addOverlay(this.markersById[id]);
		}
	    }
	    this.active = true;
	}
    }
}

GMarkerGroup.prototype.centerAndZoomOnMarkers = function() {
    if(this.map != undefined){
	//merge markers and markersById
	var tmpMarkers = this.markers.slice();
	for (var id in this.markersById){
	    tmpMarkers.push(this.markersById[id]);
	}
	if(tmpMarkers.length > 0){
    	    this.map.centerAndZoomOnMarkers(tmpMarkers);
	} 
    }
}	

//Deactivate the Group Overlay (convenience method)
GMarkerGroup.prototype.deactivate = function(){
    this.activate(false);
}

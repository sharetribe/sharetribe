// Thanks for the map Label code goes to Uncle Tomm
// Source8: (http://www.tdmarketing.co.nz/blog/2011/03/09/create-marker-with-custom-labels-in-google-maps-api-v3/)

// Define the overlay, derived from google.maps.OverlayView
function Label(opt_options) {
     // Initialization
     this.setValues(opt_options);

     // Here go the label styles
     var span = this.span_ = document.createElement('span');
     span.style.cssText = 'position: relative; left: -50%; top: -10px; ' +
                          'white-space: nowrap;' +
                          'padding: 2px;font-family: Arial; font-weight: bold;' +
                          'font-size: 12px;';

     var div = this.div_ = document.createElement('div');
     div.appendChild(span);
     div.style.cssText = 'position: absolute; display: none';
};

function initialize_labels() {

  Label.prototype = new google.maps.OverlayView;

  Label.prototype.onAdd = function() {
       var pane = this.getPanes().overlayImage;
       pane.appendChild(this.div_);

       // Ensures the label is redrawn if the text or position is changed.
       var me = this;
       this.listeners_ = [
            google.maps.event.addListener(this, 'position_changed',
                 function() { me.draw(); }),
            google.maps.event.addListener(this, 'text_changed',
                 function() { me.draw(); }),
            google.maps.event.addListener(this, 'zindex_changed',
                 function() { me.draw(); })
       ];
  };

  // Implement onRemove
  Label.prototype.onRemove = function() {
       this.div_.parentNode.removeChild(this.div_);

       // Label is removed from the map, stop updating its position/text.
       for (var i = 0, I = this.listeners_.length; i < I; ++i) {
            google.maps.event.removeListener(this.listeners_[i]);
       }
  };

  // Implement draw
  Label.prototype.draw = function() {
       var projection = this.getProjection();
       var position = projection.fromLatLngToDivPixel(this.get('position'));
       var div = this.div_;
       div.style.left = position.x + 'px';
       div.style.top = position.y - 40 + 'px';
       div.style.display = 'block';
       div.style.zIndex = this.get('zIndex'); //ALLOW LABEL TO OVERLAY MARKER
       this.span_.style.cssText += 'color:#' + this.get('color').toString(); + ';'
       this.span_.innerHTML = this.get('text').toString();
  };
}

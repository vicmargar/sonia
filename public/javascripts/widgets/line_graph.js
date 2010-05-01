var LineGraph = Class.create(Widget, {
  initialize: function($super, widget_id, config) {
    this.messages = [];
    return($super(widget_id, config));
  },
  receive: function(payload) {
      //this.messages = [];
    //payload.each(function(message) {
      this.messages.push( payload );
      //}.bind(this));
    this.update();
  },
  update: function() {
    new Draggable($(this.container));
    this.container.childElements().invoke('remove');
    this.container.appendChild(this.buildWidgetIcon());
    this.container.appendChild(this.buildHeader());
    this.messages.each(function(message) {
      var cont = new Element('p', { id: message.id});

      data = new Element('span', { className: 'status' });
      data.appendChild(document.createTextNode(message.time + " : " +message.value));
      cont.appendChild(data);

      this.container.appendChild(cont);
      // new Effect.Pulsate(this.container, { pulses: 2, duration: 1 });
    }.bind(this));
  },
  buildWidgetIcon: function() {
    return(new Element("img", {src: "images/tfl.png", width: 32, height: 32, className: 'tfl icon'}));
  },
  buildHeader: function() {
    return(new Element("h2").update(this.title));
  }
});

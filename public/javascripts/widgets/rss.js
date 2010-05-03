var RSS = Class.create(Widget, {
  initialize: function($super, widget_id, config) {
    this.messages = [];
    return($super(widget_id, config));
  },
  receive: function(payload) {
      console.log(payload);
      this.messages = payload.items;
      this.update();
    },
  update: function() {
    new Draggable($(this.container));

    var position = Element.positionedOffset($(this.container))

    this.container.childElements().invoke('remove');
    this.container.appendChild(this.buildWidgetIcon());
    this.container.appendChild(this.buildHeader());
    var cont = new Element('div');
    this.messages.each(function(message){
        var i = new Element("p").update(message);
        cont.appendChild(i);
      });
      this.container.appendChild(cont);
  },
  buildWidgetIcon: function() {
      return(new Element("img", {src: "images/rss.png", width: 32, height: 32, className: 'graph icon'}));
    },
      buildHeader: function() {
      return(new Element("h2").update(this.title));
    }
});

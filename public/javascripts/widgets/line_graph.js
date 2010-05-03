var LineGraph = Class.create(Widget, {
  initialize: function($super, widget_id, config) {
    this.messages = [];
    return($super(widget_id, config));
  },
  receive: function(payload) {
      this.messages.push( payload );
      this.update();
    },
  update: function() {
    new Draggable($(this.container));

    var position = Element.positionedOffset($(this.container))

    this.container.childElements().invoke('remove');
    this.container.appendChild(this.buildWidgetIcon());
    this.container.appendChild(this.buildHeader());
    this.container.appendChild(this.buildGraphArea());

    var values = [];
    if(this.messages.size() == 20){
      this.messages = [];
    }

    var i=0;
    this.messages.each(function(message) {
        values.push([++i, message.value]);
    }.bind(this));

    new Proto.Chart($('graph'),
    [
     {data: values, label: "Data 1"}
    ],
    {
        //since line chart is the default charting view
        //we do not need to pass any specific options for it.
        xaxis: {min: 0, max: 20, tickSize: 1},
        yaxis: {min: 0, max: 100, tickSize: 10},
    });

  },
  buildWidgetIcon: function() {
      return(new Element("img", {src: "images/graph.png", width: 32, height: 32, className: 'graph icon'}));
    },
      buildHeader: function() {
      return(new Element("h2").update(this.title));
    },
      buildGraphArea: function() {
      return(new Element("div", {id: "graph"}));
    }
});

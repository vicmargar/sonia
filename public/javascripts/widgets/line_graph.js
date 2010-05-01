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
    var xs = [];

    for (i=1; i<=20; i++){
      values.push(0);
      xs.push(i);
    }
    var i=0;
    this.messages.each(function(message) {
        values[++i] = message.value;
    }.bind(this));

    var paper = Raphael("graph");
    //paper.g.piechart(120, 150, 100, values);

    var opts = {nostroke: true, axis: "0 0 1 1", symbol: "x"}
            //axminx: .8, axmaxx: 1.2, axminy: .8, axmaxy: 1.2};

    paper.g.linechart(30,80,200,250, xs, values, opts);

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

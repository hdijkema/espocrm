/* vi: set sw=4 ts=4:  */
define(
	'views/record/panels/autoupdate-relationship',
	[ 'views/record/panels/relationship' , 'signals' ], 
	function (Dep, Signals) {
		return Dep.extend({
				topic: 'autoupdate',

				setup: function() {
					Dep.prototype.setup.call(this);
					//console.log(this);
                    var signals = Signals;
					//console.log(signals);
                    var me = this;
                    signals.registerSignal(this, 
										   this.topic, this.model.entityType, this.model.id,
										   function() { me.collection.fetch(); }
										  );
				}
		});
     }
);


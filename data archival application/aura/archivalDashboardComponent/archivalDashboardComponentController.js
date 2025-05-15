({
	init : function(component, event, helper) {
         component.set('v.columns', [
            {label: 'Object name', fieldName: 'name', type: 'text'},
            {label: 'Record Count', fieldName: 'y', type: 'number', cellAttributes: { alignment: 'left' }}
        ]);
        helper.inithelper(component,event,helper);
	}
})
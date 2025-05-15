({
	init : function(component, event, helper) {
		var field=component.get("v.field");
        console.log(field);
        if(field==null || field==undefined || field=='')
            component.set("v.field","Id");
	}
})
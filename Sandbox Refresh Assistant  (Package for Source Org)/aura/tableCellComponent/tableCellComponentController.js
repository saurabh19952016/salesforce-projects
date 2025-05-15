({
    doInit : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");
        if(record!=undefined){
            component.set("v.cellValue", record[field.fieldName]);
        }
   },

    handleChange:function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");
        record[field.fieldName]=component.get("v.cellValue");
        component.set("v.record",record);
        console.log(component.get("v.record")[field.fieldName]);
    }
})
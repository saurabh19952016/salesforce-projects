({
    doInit : function(component, event, helper) {
        var fieldList=component.get("v.fieldListObject.fieldList__c");
        console.log('inside display');
        component.set("v.fields",fieldList.split(","));
        component.set("v.searchList",fieldList.split(","));
    },

    handleSelection:function(component, event, helper) {
        component.set("v.isOpen",false);
        var appEvent = $A.get("e.c:selectFieldListEvent");
        appEvent.setParams({
            "fields" : component.get("v.fields"),
            "object" : component.get("v.object")
         });
        appEvent.fire();
    },

    search : function(component,event,helper){
        var fields=component.get("v.fields");
        var searchVal=component.get("v.searchValue");
        if(searchVal=='' || searchVal==' ' || searchVal==undefined){
            component.set("v.searchList",fields);
        }
        else{
            var searchList=[];
            searchVal=searchVal.toLowerCase();
            for(var i in fields){
                var fieldVal=fields[i].toLowerCase();
                if(fieldVal.includes(searchVal)){
                    searchList.push(fields[i]);
                }
            }
            component.set("v.searchList",searchList);
        }
    }
})
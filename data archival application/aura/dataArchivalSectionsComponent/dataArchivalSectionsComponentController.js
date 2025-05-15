({
    switchTab : function(component, event, helper) {
        var select= event.getParam("visibleTab");
        if(select=='subParent'){
        component.set("v.message","Reparenting successful");
        component.set("v.type","success");
        }
        component.find("tabset").set("v.selectedTabId",select);
    }
})
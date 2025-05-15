({
    init:function(component,event,helper){
        var action=component.get("c.getsobjectList");
        action.setParams({
            "QualifiedName" :component.get("v.selected")
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set("v.listOfSearchRecords",response.getReturnValue());  
                var selected=component.get("v.selected");
                if(selected!=null && selected!='')
                {
                    console.log('found id');
                    $A.util.toggleClass(component.find("lookup-pill"), 'slds-hide');
                    $A.util.toggleClass(component.find("lookupField"), 'slds-hide');
                }
                
                console.log('selected record' + component.get("v.selected"));     
            }
        });
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,getInputkeyWord) {
        var action=component.get("c.getsobjectList");
        action.setParams({
            "QualifiedName" :getInputkeyWord
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                component.set("v.listOfSearchRecords", response.getReturnValue());       
                
            }
        });
        $A.enqueueAction(action);
    },
})
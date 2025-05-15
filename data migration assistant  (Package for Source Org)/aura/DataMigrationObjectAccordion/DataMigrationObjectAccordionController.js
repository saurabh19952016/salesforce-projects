({
    handlePrint : function(component, event, helper) {
        
        var objList=component.get("v.objList");
        var activeSections=[];
        for(var key in objList){
            console.log(objList[key]);
            if(component.get("v.isPicklist")){
                activeSections.push(objList[key].objectName + '.' + objList[key].fieldName);
                
            } 
            else{
                console.log('test' + objList[key]['key']);
                activeSections.push(objList[key]['key']);
            }
        }
        console.log('test' + activeSections);
              if(component.get("v.isPicklist")){
      component.set("v.activePicklistAccordion",activeSections);
              }
        else{
      component.set("v.activeSectionsAccordion",activeSections);
            
        }
        
        var interval = window.setTimeout(
            $A.getCallback(function() {
                window.print();
            }), 700
        );   
    }
    
})
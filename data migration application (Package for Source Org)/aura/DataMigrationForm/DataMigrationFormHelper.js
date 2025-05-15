({
	  initSettings:function(component,event,helper){
            $A.util.removeClass(component.find("spinner"),"slds-hide");
            var action2=component.get("c.getSettings");
          var hierarchylevel=component.get("v.HierarchyLevel");
          console.log('hierarchylevel' + hierarchylevel);
               action2.setParams({
                    "HierarchyLevel": hierarchylevel
                });
                action2.setCallback(this,function(response){
                    console.log('new set --> ',response.getState());
                    if(response.getState()=='SUCCESS'){
                        if(response.getReturnValue().length==0 && hierarchylevel!=1){
                            $A.util.addClass(component.find("h2"),"slds-hide");
                            component.set("v.message","Sub Parent doesn't exist.");
                            component.set("v.type","info");
                       }
                        else{
                            helper.initList(component,response.getReturnValue());
                        }                        
                    }
                    else
                    {
                        helper.handleError(component,event,response);
                    }
                     $A.util.addClass(component.find("spinner"),"slds-hide");
               
                });
                $A.enqueueAction(action2);
        
    },
    saveSettings : function(component,event,helper) {
        var setting=component.get("v.settingsList")[0];
        console.log(setting);
        var action=component.get("c.saveSettings");
        if(setting.Object_type__c=='Parent'){
            if(setting.objectName__c==undefined || setting.objectName__c=='')
            {
                component.set("v.message","Please fill Name for settings.");
                component.set("v.type","error");
                return;
            }
        
        }
        console.log(setting);
        action.setParams({
            "setting":setting,
            "HierarchyLevel":component.get("v.HierarchyLevel") 
        });
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                component.set("v.message","Settings saved successfully!");
                component.set("v.type","success");
                helper.initList(component,response.getReturnValue());
            }
            else{
                component.set("v.message","An Error occured while saving your settings!");
                component.set("v.type","error");
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    deleteSettings:function(component,event,helper){
        var settinglist=component.get("v.settingsList");
        var action=component.get("c.deleteAllSettings");
        action.setParams({
            "setting":settinglist[0] 
        });
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                component.set("v.message","Settings deleted successfully!");
                component.set("v.type","success");    
                
                var cpevent=$A.get("e.c:refreshParent");
                cpevent.setParams({
                    "visibleTab":"1"
                });
                cpevent.fire();
            }
            else{
                component.set("v.message","An Error occured while deleting your settings!");
                component.set("v.type","error");
            }
            $A.util.addClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    

    
    initList:function(component,settingList){
        component.set("v.settingsList",settingList);
        console.log(settingList);
        component.set("v.parentRecord",settingList[0]);
        component.set("v.childlist",settingList.slice(1,15));
        component.set("v.totalPages",Math.ceil(settingList.length/14));
    },
    
  
    /*helperMethod : function(component,event,helper) {
        var action=component.get("c.insertRecords");
        var object=component.get("v.objectDetails");
        console.log(object);
        action.setParams({
            "objectDetails":object
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                alert("job submitted successfully");
            }
            
        });
        $A.enqueueAction(action);
	}*/
    
    
})
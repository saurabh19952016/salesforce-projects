({
    initSettings:function(component,event,helper){
        var action=component.get("c.getBatchStatus");
        action.setCallback(this,function(response){
            console.log('new set --> ',response.getReturnValue());
            if(response.getState()=='SUCCESS'){
                if(response.getReturnValue()==true){
                    component.set("v.disabled",false);
                }
                $A.util.toggleClass(component.find("spinner"),"slds-hide");
                var action2=component.get("c.getSettings");
                action2.setParams({
                    "HierarchyLevel":component.get("v.HierarchyLevel") 
                });
                action2.setCallback(this,function(response){
                    console.log('new set --> ',response.getState());
                    if(response.getState()=='SUCCESS'){
                        if(response.getReturnValue().length==0){
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
                    $A.util.toggleClass(component.find("spinner"),"slds-hide");
                    
                });
                $A.enqueueAction(action2);
            }
            else
            {
                helper.handleError(component,event,response);
            }
        });
        $A.enqueueAction(action);
        
    },
    saveSettings : function(component,event,helper) {
        var setting=component.get("v.settingsList")[0];
        var today = new Date();
        var currentdate = helper.formatDate();
        var action=component.get("c.saveSettings");
        if(setting.Object_type__c=='Parent'){
            if(setting.Object_Name__c==undefined || setting.Object_Name__c=='' ||  setting.Archival_To_Date__c==undefined || setting.Archival_From_Date__c==undefined)
            {
                component.set("v.message","Please fill all Name and date filters.");
                component.set("v.type","error");
                return;
            }
            else if(setting.Archival_From_Date__c>setting.Archival_To_Date__c){
                component.set("v.message","From Date cannot be greater than To Date.");
                component.set("v.type","error");
                return;
            }
                else if(setting.Archival_From_Date__c.substring(0, 10)>currentdate
                        || setting.Archival_To_Date__c.substring(0, 10)>currentdate){
                    component.set("v.message","From Date and To Date cannot be greater than current date.");
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
        var action=component.get("c.deleteSettings");
        action.setParams({
            "setting":settinglist[0] 
        });
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                component.set("v.message","Settings deleted successfully!");
                component.set("v.type","success");    
                
                var cpevent=$A.get("e.c:refreshParent");
                cpevent.setParams({
                    "visibleTab":"Parent"
                });
                cpevent.fire();
            }
            else{
                component.set("v.message","An Error occured while deleting your settings!");
                component.set("v.type","error");
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    formatDate: function() {
        var d = new Date(),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
        
        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;
        
        return [year, month, day].join('-');
    },
    
    initList:function(component,settingList){
        component.set("v.settingsList",settingList);
        
        component.set("v.parentRecord",settingList[0]);
        component.set("v.childlist",settingList.slice(1,15));
        component.set("v.totalPages",Math.ceil(settingList.length/14));
    },
    
})
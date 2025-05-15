({
       init: function(component, event, helper) {
        component.set("v.offset",0);
        component.set("v.currentPage",1);
        helper.initSettings(component,event,helper);
        
    },
   save:function(component,event,helper){
        helper.saveSettings(component,event,helper);
    },
    
    delete:function(component,event,helper){
    helper.deleteSettings(component,event,helper);
},
 	close : function(component, event, helper) {
		 component.set("v.message",null);
	},
        

 /*addRows:function(component, event, helper) {
        var settinglist=component.get("v.settingsList");
        if(settinglist[settinglist.length-1].Object_Name__c==undefined || settinglist[settinglist.length-1].Archival_To_Date__c==undefined || settinglist[settinglist.length-1].Archival_From_Date__c==undefined)
        {
            component.set("v.message","Please fill all Name and date filters before adding new Row.");
            component.set("v.type","error");
            return;
        }
        else{
            var settinglist=component.get("v.settingsList");
            settinglist.push({'sobjectType':'Data_Archival_Object_Settings__c'});
            component.set("v.settingsList",settinglist);
        }
    },*/
 Next:function(component, event, helper) {
    component.set("v.currentPage", component.get("v.currentPage")+ 1);
    var offset = component.get("v.offset") + 14;
    var settingList=component.get("v.settingsList");
    var childList=settingList.slice(offset,offset+14);
    console.log(settingList);
    console.log(childList);
    component.set("v.childlist",childList);
    component.set("v.offset",offset);
    
},
    Previous:function(component, event, helper) {
        component.set("v.currentPage", component.get("v.currentPage")- 1);
        var offset = component.get("v.offset") - 14;
        var settingList=component.get("v.settingsList");
        if(offset==0){
            offset=1;
        }
        var childList=settingList.slice(offset,offset+ 14);
        component.set("v.childlist",childList);
        component.set("v.offset",offset);
        
    },
    reparentHandle:function(component, event, helper) {
                component.set("v.offset",0);
                component.set("v.currentPage",1);
                helper.initSettings(component,event,helper);
        },
            /*clearFields:function(component, event, helper) {
        component.set("v.fieldList",[]);
        component.set("v.objectName","");

    },
    
      handleFieldEvent:function(component,event,helper){
        component.set('v.selectedFields',[]);
        var action=component.get("c.getFieldList");
        var object=component.get("v.objectName");
        console.log(object);
        action.setParams({
            "selectedObj":object
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                var objectDetails=response.getReturnValue();
                console.log(objectDetails);
                var options=[];
                for(var i in objectDetails.fieldList){
                    options.push({'label': objectDetails.fieldList[i],'value':objectDetails.fieldList[i]});
                }
                component.set("v.fieldList",options);
                component.set("v.objectDetails",objectDetails);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    insertRecords:function(component,event,helper){
        helper.insertRecords(component,event,helper);
        
    },*/
})
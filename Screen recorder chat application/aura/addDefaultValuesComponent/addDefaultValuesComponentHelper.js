({
    initialize : function(component,event,helper) {
        helper.getPromise(
            component,
            helper,
            "c.getDefaultSettingRecords",
            {
                environment:component.get("v.environmentName")
            }
        ).then(function(response){
            $A.util.addClass(component.find("spinner"),"slds-hide");
            var newSettingList=response.map(res=>{
                if(res.Name.includes('API_')){
                		res.Name= res.Name.replace('API_','');
                		return res;
            	}
                 else{
                        return res;                    
                 }
            });
            component.set("v.settingList",newSettingList);
        })
        .catch(function(error){
            helper.showToast("ERROR",error.message,"error");
        })
    },
    
    saveRecords : function(component,settingNewList,helper) {
        console.log(settingNewList);
        helper.getPromise(
            component,
            helper,
            "c.saveDefaultSettingRecords",
            {
                settingRecords:settingNewList,
                environment:component.get("v.environmentName")
            }
        ).then(function(response){
            $A.util.addClass(component.find("spinner"),"slds-hide");
            helper.showToast("SUCCESS","Settings created successfully!","success");
            $A.get('e.force:refreshView').fire();
        })
        .catch(function(error){
            $A.util.addClass(component.find("spinner"),"slds-hide");
            console.log('error'+error);
            helper.showToast("ERROR",error.message,"error");
        })
    },
    
    deleteRecordWithId: function(component,recId,helper){
        $A.util.removeClass(component.find("spinner"),"slds-hide");
        helper.getPromise(
            component,
            helper,
            "c.deleteSingleRecord",
            {
                settingRecordId:recId
            }
        ).then(function(response){
            $A.util.addClass(component.find("spinner"),"slds-hide");
            helper.deleteRecordFromTable(component,recId);
            
        })
        .catch(function(error){
            $A.util.addClass(component.find("spinner"),"slds-hide");
            helper.showToast("ERROR",error.message,"error");
        })
    },
    
    createObjects : function(component,object,helper) {
        var environment =component.get("v.environmentName");
        var  settingNewList=[];
        (object).forEach(setting=>{
            if(setting.Name!=''){
            
            setting.Id=null;
            if(environment=='Salesforce'){
            setting.isSFDC__c=true;
            setting.isAPI__c=false;
        }
        else if(environment=='Target Environment'){
            setting.Name='API_' +setting.Name;
            setting.isAPI__c=true;
            setting.isSFDC__c=false;
        }
        settingNewList.push(setting);
    }
    
});
return settingNewList;
},
    
    deleteRecordFromTable : function(component,recId){
        var draftValues=component.find("table").get("v.draftValues");
        var settingList=component.get("v.settingList");
        for(var i in settingList){
            if(settingList[i].Id==recId){
                settingList.splice(i,1);
                break;
            }
        }
        for(var i in draftValues){
            if(draftValues[i].Id==recId){
                draftValues.splice(i,1);
                break;
            }
        }
        component.set("v.settingList",settingList);
        component.find("table").set("v.draftValues",draftValues);
    }

})
({
    doInit : function(component, event, helper) {
        helper.initialize(component,event,helper);
        component.set('v.columns', [
            {label: 'Field Name', fieldName: 'Name', type: 'text', editable: true, typeAttributes: { required: true }},
            {label: 'Field Value', fieldName: 'field_Value__c', type: 'text', editable: true },
            {type: "button", typeAttributes: {
                label: 'Delete',
                name: 'delete',
                title: 'Delete',
                disabled: false,
                value: 'delete',
                iconName:'utility:delete',
                variant:'destructive'
            }}
        ]);
    },
    
    addRows: function(component, event, helper) {
        var settingList=component.get("v.settingList");
        settingList.push(
            {Id:settingList.length+1,Name:''}
        );
        component.set("v.settingList",settingList);
    },
    
    deleteRow : function(component, event, helper) {
        
        var actionName = event.getParam('action').name;
        if ( actionName == 'delete' ) {
            var recId = event.getParam('row').Id;
            if(recId.length<15){
                helper.deleteRecordFromTable(component,recId);
            }
            else{
                helper.deleteRecordWithId(component,recId,helper);
                
            }
        }
        
    },
    
    handleSave: function(component, event, helper) {
        $A.util.addClass(component.find("spinner"),"slds-hide");
        
        var settingNewList=helper.createObjects(component,component.get("v.settingList"),helper);
        var draftNewList=helper.createObjects(component,event.getParam('draftValues'),helper);
        
        helper.saveRecords(component,[...settingNewList, ...draftNewList],helper);
    },
})
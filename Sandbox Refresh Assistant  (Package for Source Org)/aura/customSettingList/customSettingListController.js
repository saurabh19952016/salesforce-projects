({
    doInit : function(component, event, helper) {
        var columns=[];
        columns.push({label: 'Custom setting name', fieldName: 'Name', type: 'text'});
        columns.push({type: "button", typeAttributes: {
            label: 'view conflict',
            name: 'conflict',
            title: 'conflict',
            disabled: {fieldName:'Merged'},
            value: 'conflict',
            variant:'brand',
            iconName: 'utility:preview'
        }});
        component.set("v.columns",columns);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
     },

    getRecords : function(component, event, helper) {
        var recId = event.getParam('row').Name;
        console.log(recId);
        var actionName = event.getParam('action').name;
        if ( actionName == 'conflict' ) {
            var customSettings=component.get("v.customSettings");
            for(var i in customSettings){
                console.log(customSettings[i]);
                component.set("v.selectedObj",customSettings[i]);
                if(customSettings[i].Name==recId){
                    $A.createComponents([
                        ["c:customSettingCompareRecords",{
                            "selectedObject" :customSettings[i]
                        }]
                     ],
                                        function(components, status, errorMessage){
                                            if (status === "SUCCESS") {
                                                component.set("v.body", components);
                                                component.set("v.step",'2');
                                            }
                                        }
                    );
                    break;
                }
            }
        }
    },

    handleEvent:function(component, event, helper) {
        var eventType=event.getParam("eventType");
        component.set("v.step","1");
        if(eventType=='Success'){
            var selected=component.get("v.selectedObj");
            var customSettings=component.get("v.customSettings");
            console.log(customSettings.indexOf(selected));
            var element=customSettings[customSettings.indexOf(selected)];
            element.Merged=true;
            customSettings[customSettings.indexOf(selected)]=element;
            component.set("v.customSettings",customSettings);
        }
    },

    mergeAll : function(component, event, helper) {
        var cmpEvent=component.getEvent("mergeAll");
        cmpEvent.setParams({
            settingsList:component.get("v.customSettings")
        });
        cmpEvent.fire();
    },
})
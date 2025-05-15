({
    init:function(component,event,helper){
        var action=component.get("c.getsobjectList");
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                component.set("v.InputListToSearch",response.getReturnValue());
                var selected=component.get("v.selected");
                    if(selected!=null || selected!='')
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
        console.log('<<searchHelper>>');
        var inputlist=component.get("v.InputListToSearch");
        var outputList=[];
        for (var i in inputlist) {
            getInputkeyWord=getInputkeyWord.toLowerCase();
            var pickval=inputlist[i];
            console.log(pickval.toLowerCase().includes(getInputkeyWord));
            var keyword;
            if(pickval!=null && pickval.toLowerCase().includes(getInputkeyWord))
            {
                console.log('product' +pickval);
                outputList.push(pickval);
            }
        }
        component.set("v.listOfSearchRecords", outputList);       
    },
})
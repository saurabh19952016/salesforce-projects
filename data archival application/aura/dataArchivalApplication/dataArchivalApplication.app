<aura:application extends="force:slds">
    
    <div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_info slds-text-align_left" aura:id="alert" role="alert">
        <lightning:icon iconName="utility:info" variant="inverse" size="small" class="slds-m-right--large"/>
        <ul class="slds-list--dotted">
            <li>
                <h2>
                    Please create the field with API name Archive_Indexes__c in all objects before running the archival batch.
                </h2>
            </li>
            <li>
                <h2>
                    Please run the archival batch for all the Child Objects after archiving parent object records to maintain consistency in data.
                </h2>
            </li>
            <li>
                <h2>
                    Do not delete archived records in Salesforce before unarchiving the records, doing so might result in junk data being created.
                </h2>
            </li>
            
        </ul>
        <div class="slds-notify__close">
            <lightning:icon iconName="utility:close"  variant="inverse" onclick="{!c.close}"/>
        </div>
    </div>      
    <div  class="slds-brand-band slds-brand-band_cover slds-brand-band_large">    

        <c:ArchivalHeader/>
        <c:setupComponent/>
        <div class="slds-m-around--medium">
            <lightning:tabset selectedTabId="Archive" variant="scoped">
                <lightning:tab iconName="utility:archive" label="Data Archival" id="Archive">
                    <c:dataArchivalSectionsComponent/>
                </lightning:tab>
                <lightning:tab iconName="utility:email_open" label="Data Unarchival" id="unArchive">
                    <c:DataUnarchivalComponent/>
                </lightning:tab>
                  <lightning:tab iconName="standard:dashboard_ea" label="Dashboard" id="dashboard">
                            <c:archivalDashboardComponent/>
                </lightning:tab>

            </lightning:tabset>   
        </div>
    </div>
</aura:application>
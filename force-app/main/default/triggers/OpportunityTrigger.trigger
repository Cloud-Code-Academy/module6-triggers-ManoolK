/**
* The Opportunty Trigger 
* @author Oxana Suvorova
*/
trigger OpportunityTrigger on Opportunity (before update, before delete) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            OpportunityTriggerHandler.beforeUpdate(Trigger.newMap);
        }
        when BEFORE_DELETE {
            OpportunityTriggerHandler.beforeDelete(Trigger.oldMap);
        }
    }
}
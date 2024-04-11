/**
* The Account Trigger 
* @author Oxana Suvorova
*/
trigger AccountTrigger on Account (before insert, after insert) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            AccountTriggerHandler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {
            AccountTriggerHandler.afterInsert(Trigger.new);
        }
    }
}
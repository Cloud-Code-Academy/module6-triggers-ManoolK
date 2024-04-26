/**
* @description The Opportunity Trigger Handler class
* @author Oxana Suvorova
*/
public with sharing class OpportunityTriggerHandler {

    /**
    * @description Before Update method.
    * @param opportunities The Map of new inserted Opportunities by Id: Trigger.newMap
    **/
    public static void beforeUpdate(Map<Id, Opportunity> opportunitiesById) {
        // Get Accounts by Id with a Contact which Title = 'CEO'
        Map<Id, Account> accountsById = new Map<Id, Account>([
            SELECT Id, (SELECT Id FROM Contacts WHERE Title = 'CEO' LIMIT 1)
            FROM Account 
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE ID IN :opportunitiesById.keySet())
        ]);
        for (Opportunity oppty : opportunitiesById.values()) {
            // When an opportunity is updated validate that the amount is greater than 5000.
            // Error Message: 'Opportunity amount must be greater than 5000'
            if (oppty.Amount < 5000) {
                oppty.addError('Opportunity amount must be greater than 5000');
            }
            // When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'.
            Account acc = accountsById.get(oppty.AccountId);
            if (acc != null) {
                oppty.Primary_Contact__c = acc?.Contacts[0].Id;
            }
        }
    }

    /**
    * @description Before Delete method.
    * @param opportunities The Map of deleted Opportunities by Id: Trigger.oldMap
    **/
    public static void beforeDelete(Map<Id, Opportunity> opportunitiesById) {
        // When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        // Error Message: 'Cannot delete closed opportunity for a banking account that is won'
        List<Opportunity> oppsNotForDel = [
            SELECT Id
            FROM Opportunity
            WHERE Id IN :opportunitiesById.keySet()
                AND isClosed = true AND isWon = true
                AND Account.Industry = 'Banking'
            WITH SECURITY_ENFORCED
        ];
        for (Opportunity oppty : oppsNotForDel) {
            opportunitiesById.get(oppty.Id).addError('Cannot delete closed opportunity for a banking account that is won');
        }
    }
}
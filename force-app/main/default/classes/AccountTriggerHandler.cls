/**
* @description The Account Trigger Handler class
* @author Oxana Suvorova
*/
public with sharing class AccountTriggerHandler {

    /**
    * @description Before Insert method.
    * @param accounts The list of new inserted Accounts: Trigger.new
    **/
    public static void beforeInsert(List<Account> accounts) {
        for (Account acc : accounts) {
            // When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
            // When an account is inserted copy the shipping address to the billing address.
            acc.BillingStreet = acc.ShippingStreet;
            acc.BillingCity = acc.ShippingCity;
            acc.BillingState = acc.ShippingState;
            acc.BillingPostalCode = acc.ShippingPostalCode;
            acc.BillingCountry = acc.ShippingCountry;
            // When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    /**
    * @description After Insert method.
    * @param accounts The list of new inserted Accounts: Trigger.new
    **/
    public static void afterInsert(List<Account> accounts) {
        /* When an account is inserted create a contact related to the account with the following default values:
        * LastName = 'DefaultContact'
        * Email = 'default@email.com'
        */
        List<Contact> contactsToCreate = new List<Contact>();
        for (Account acc : accounts) {
            contactsToCreate.add(new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acc.Id));
        }
        // To be able to save duplicate records (as we use the same name) we need to change the DML options
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        dml.DuplicateRuleHeader.RunAsCurrentUser = true;
        // Insert new Contacts
        Database.insert(contactsToCreate, dml);
    }
}
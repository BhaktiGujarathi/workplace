/***********************************************************************************
 * Class : CatalogFactory
 * Created By : Ajinkya Hingne
 -----------------------------------------------------------------------------------
 * Description : Factory class for Catalog__c object
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ajinkya Hingne    04/05/2016    Initial Development
 **********************************************************************************/
public class CatalogFactory {

    /**
     * Creates Catalog records
     */
    /*public static List<Catalog__c> createDefault(Integer numberOfRecords, String recordTypeName) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', recordTypeName);
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }*/

    /**
     * Creates Catalog record with for Profession record type
     */
    public static List<Catalog__c> createProfessionCatalog(Integer numberOfRecords) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', 'Profession');
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                Profession_Category__c = 'Investigations',
                Active__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }

    /**
     * Creates Catalog record with for Language record type
     */
    public static List<Catalog__c> createLanguageCatalog(Integer numberOfRecords) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', 'Language');
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                Language_Category__c = 'JRR',
                Active__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }

    /**
     * Creates Catalog record with for Area of Expertise record type
     */
    public static List<Catalog__c> createExpertiseCatalog(Integer numberOfRecords) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', 'Area_of_Expertise');
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                Item_Type__c = 'FOR',
                AoE_Category__c = 'Legal',
                Active__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }

    /**
     * Creates Catalog record with for Legal System record type
     */
    public static List<Catalog__c> createLegalSystemCatalog(Integer numberOfRecords) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', 'Legal_System');
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                Active__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }

    /**
     * Creates Catalog record with for Country record type
     */
    public static List<Catalog__c> createCountryCatalog(Integer numberOfRecords) {
        Id recordTypeId = RecordType_Utils.getRecordTypeId('Catalog__c', 'Country');
        List<Catalog__c> catalogs = new List<Catalog__c>();
        for (Integer i = 1; i <= numberOfRecords; i++) {
            Catalog__c catalog = new Catalog__c(
                Name = 'Test'+i,
                Official_Name__c = 'Test'+i,
                Region_UN__c = 'Asia: Western',
                UN_Member__c = 'Yes',
                MENA_JRR__c = 'Yes',
                DAC_List__c = 'Yes',
                HRC_Member__c = 'No',
                Rome_Statute__c = 'No',
                Active__c = 'Yes',
                RecordTypeId = recordTypeId
            );
            catalogs.add(catalog);
        }
        return catalogs;
    }

    /**
     * Inserts data into database
     */
    public static List<Catalog__c> insertData(List<Catalog__c> catalogs) {
        insert catalogs;
        return catalogs;
    }
}
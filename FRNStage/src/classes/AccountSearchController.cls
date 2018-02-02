public with sharing class AccountSearchController {
  private String soql {get;set;}
  public List<Account> accounts {get;set;}
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'desc'; } return sortDir;  }
    set;
  }
  public String sortField {
    get  { if (sortField == null) {sortField = 'Priority_Step_Down__c'; } return sortField;  }
    set;
  }
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 100'; }
    set;
  }
  public AccountSearchController() {
    soql = 'select Priority_Step_Down__c,name,shippingstreet,shippingcity,shippingstate,shippingpostalcode,phone,type,account_rating1__c,low_cost__c,Type_of_Treatment_Offered__c,Disorder_Treatment_and_Specialization__c,patient_sex__c, owner.name, ram_text__c, ram_hit_list__c from account where enabled__c = true and do_not_refer__c = false';
    runQuery();
  }
  public void toggleSort() {
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    runQuery();
  }
  public void runQuery() {
    try {
      accounts = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 100');
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

  }

  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {

    String shippingcity = Apexpages.currentPage().getParameters().get('shippingcity');
    String shippingstate = Apexpages.currentPage().getParameters().get('shippingstate');
    String shippingpostalcode = Apexpages.currentPage().getParameters().get('shippingpostalcode');
    String Accreditation = Apexpages.currentPage().getParameters().get('Accreditation');
    String facility_type = Apexpages.currentPage().getParameters().get('facility_type');
    String private_practice = Apexpages.currentPage().getParameters().get('private_practice');
    String patient_sex = Apexpages.currentPage().getParameters().get('patient_sex');
    String age_and_population = Apexpages.currentPage().getParameters().get('age_and_population');
    String levels_of_care = Apexpages.currentPage().getParameters().get('levels_of_care');
    String Type_of_Treatment_Offered = Apexpages.currentPage().getParameters().get('Type_of_Treatment_Offered');
    String Disorder_Treatment_and_Specialization = Apexpages.currentPage().getParameters().get('Disorder_Treatment_and_Specialization');
    String Mothers_with_Children = Apexpages.currentPage().getParameters().get('Mothers_with_Children');
    String Public_Funded_Ins = Apexpages.currentPage().getParameters().get('Public_Funded_Ins');
    String Insurance_List = Apexpages.currentPage().getParameters().get('Insurance_List');
    String Community_Partner = Apexpages.currentPage().getParameters().get('Community_Partner');
    String ParentText = Apexpages.currentPage().getParameters().get('ParentText');

    soql = 'select Priority_Step_Down__c,name,shippingstreet,shippingcity,shippingstate,shippingpostalcode,phone,type,account_rating1__c,low_cost__c,Type_of_Treatment_Offered__c,Disorder_Treatment_and_Specialization__c,patient_sex__c,owner.name, ram_text__c, ram_hit_list__c from account where enabled__c = true and do_not_refer__c = false';
    if (!shippingcity.equals(''))
      soql += ' and shippingcity LIKE \''+String.escapeSingleQuotes(shippingcity)+'%\'';
    if (!shippingstate.equals(''))
      soql += ' and shippingstate LIKE \''+String.escapeSingleQuotes(shippingstate)+'%\'';
    if (!shippingpostalcode.equals(''))
      soql += ' and shippingpostalcode LIKE \''+String.escapeSingleQuotes(shippingpostalcode)+'%\'';  
    if (!Accreditation.equals(''))
      soql += ' and Accreditation__c includes (\''+Accreditation+'\')';
      if (!facility_type.equals(''))
      soql += ' and facility_type__c in (\''+facility_type+'\')';
    if (!private_practice.equals(''))
      soql += ' and private_practice__c includes (\''+private_practice+'\')';
    if (!patient_sex.equals(''))
      soql += ' and patient_sex__c includes (\''+patient_sex+'\')';
    if (!age_and_population.equals(''))
      soql += ' and age_and_population__c includes (\''+age_and_population+'\')';
    if (!levels_of_care.equals(''))
      soql += ' and levels_of_care__c includes (\''+levels_of_care+'\')';
    if (!Type_of_Treatment_Offered.equals(''))
      soql += ' and Type_of_Treatment_Offered__c includes (\''+Type_of_Treatment_Offered+'\')';
    if (!Disorder_Treatment_and_Specialization.equals(''))
      soql += ' and Disorder_Treatment_and_Specialization__c includes (\''+Disorder_Treatment_and_Specialization+'\')';
    if (!Mothers_with_Children.equals(''))
      soql += ' and Mothers_with_Children__c includes (\''+Mothers_with_Children+'\')';
    if (!Public_Funded_Ins.equals(''))
      soql += ' and Public_Funded_Ins__c includes (\''+Public_Funded_Ins+'\')';
    if (!Insurance_List.equals(''))
      soql += ' and Insurance_List__c includes (\''+Insurance_List+'\')';
    if (!Community_Partner.equals(''))
      soql += ' and Community_Partner__c includes (\''+Community_Partner+'\')';
    if (!ParentText.equals(''))
      soql += ' and parent.name LIKE \''+String.escapeSingleQuotes(ParentText)+'%\'';

    // run the query again
    runQuery();

    return null;
  }
    
  // use apex describe to build the picklist values

    public List<String> Accreditation {
    get {
      if (Accreditation == null) {
      
        Accreditation = new List<String>();
        Schema.DescribeFieldResult field = Account.Accreditation__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Accreditation.add(f.getLabel());
      }
      return Accreditation;          
    }
    set;
    }
    public List<String> facility_type {
    get {
      if (facility_type == null) {
      
        facility_type = new List<String>();
        Schema.DescribeFieldResult field = Account.facility_type__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          facility_type.add(f.getLabel());
      }
      return facility_type;          
    }
    set;
    }
    public List<String> private_practice {
    get {
      if (private_practice == null) {
      
        private_practice = new List<String>();
        Schema.DescribeFieldResult field = Account.private_practice__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          private_practice.add(f.getLabel());
      }
      return private_practice;          
    }
    set;
    }
    public List<String> patient_sex {
    get {
      if (patient_sex == null) {
      
        patient_sex = new List<String>();
        Schema.DescribeFieldResult field = Account.patient_sex__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          patient_sex.add(f.getLabel());
      }
      return patient_sex;          
    }
    set;
    }
    public List<String> age_and_population {
    get {
      if (age_and_population == null) {
      
        age_and_population = new List<String>();
        Schema.DescribeFieldResult field = Account.age_and_population__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          age_and_population.add(f.getLabel());
      }
      return age_and_population;          
    }
    set;
    }
    public List<String> levels_of_care {
    get {
      if (levels_of_care == null) {
      
        levels_of_care = new List<String>();
        Schema.DescribeFieldResult field = Account.levels_of_care__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          levels_of_care.add(f.getLabel());
      }
      return levels_of_care;          
    }
    set;
    }
    public List<String> Type_of_Treatment_Offered {
    get {
      if (Type_of_Treatment_Offered == null) {
      
        Type_of_Treatment_Offered = new List<String>();
        Schema.DescribeFieldResult field = Account.Type_of_Treatment_Offered__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Type_of_Treatment_Offered.add(f.getLabel());
      }
      return Type_of_Treatment_Offered;          
    }
    set;
    }
    public List<String> Disorder_Treatment_and_Specialization {
    get {
      if (Disorder_Treatment_and_Specialization == null) {
      
        Disorder_Treatment_and_Specialization = new List<String>();
        Schema.DescribeFieldResult field = Account.Disorder_Treatment_and_Specialization__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Disorder_Treatment_and_Specialization.add(f.getLabel());
      }
      return Disorder_Treatment_and_Specialization ;          
    }
    set;
    }
    public List<String> Mothers_with_Children {
    get {
      if (Mothers_with_Children == null) {
      
        Mothers_with_Children = new List<String>();
        Schema.DescribeFieldResult field = Account.Mothers_with_Children__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Mothers_with_Children.add(f.getLabel());
      }
      return Mothers_with_Children;          
    }
    set;
    }
    public List<String> Public_Funded_Ins {
    get {
      if (Public_Funded_Ins == null) {
      
        Public_Funded_Ins = new List<String>();
        Schema.DescribeFieldResult field = Account.Public_Funded_Ins__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Public_Funded_Ins.add(f.getLabel());
      }
      return Public_Funded_Ins;          
    }
    set;
    }
    public List<String> Insurance_List {
    get {
      if (Insurance_List == null) {
      
        Insurance_List = new List<String>();
        Schema.DescribeFieldResult field = Account.Insurance_List__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Insurance_List.add(f.getLabel());
      }
      return Insurance_List;          
    }
    set;
    }
    public List<String> Community_Partner {
    get {
      if (Community_Partner == null) {
      
        Community_Partner = new List<String>();
        Schema.DescribeFieldResult field = Account.Community_Partner__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
          Community_Partner.add(f.getLabel());
      }
      return Community_Partner;          
    }
    set;
    }
    public String ParentText {
    get {
      
      return ParentText;          
    }
    set;
    }
}
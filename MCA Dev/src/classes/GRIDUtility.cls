public with sharing class GRIDUtility {


    public static ReferenceFieldWrapper isReferenceFieldPresent(ReferenceFieldWrapper refWrap)
    {
        for(Schema.FieldSetMember fieldInstance :refWrap.fieldsetList)
        {
           if(fieldInstance.getFieldPath().contains('__r.') || fieldInstance.getFieldPath().contains('.'))
           {
               refWrap.refrenceFieldLabel = fieldInstance.getLabel();
               refWrap.isReferenceField = true;
               return refWrap;
           }

        }

        refWrap.isReferenceField = false;
        return refWrap;
        
    }

   // wrapper for offers
    public class ReferenceFieldWrapper
    {
        public List<Schema.FieldSetMember> fieldsetList                                  {get;set;}
        public String refrenceFieldLabel                                                 {get;set;}
        public Boolean isReferenceField                                                  {get;set;}
        public ReferenceFieldWrapper(List<Schema.FieldSetMember> pFieldsetList, String pRefrenceFieldLabel, Boolean pIsReferenceField)
        {
            fieldsetList= pFieldsetList;
            refrenceFieldLabel= pRefrenceFieldLabel;
            isReferenceField = pIsReferenceField;
        }
    }
}
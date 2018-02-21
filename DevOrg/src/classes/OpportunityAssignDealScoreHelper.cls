/* 
 * Evaluate the Rule criteria for active Rules for the created / updated Opportunity record and 
 * assign the respective score to the configured field on Rule.
 *
 * Revision History:
 *
 * Version     Author                     Date              Description
 * 1.0         Amit Shingavi              3/3/2013            Initial Draft
 *
 * 1.1         Sid Birari                 04/15/2014        Issue Fixing to update 'Max Score' and 'Max Score Excluded'
 *                                                          appropriately. When updating Deal records in bulk, the mentioned
 *                                                          fields weren't getting populated appropriately.
 *
 * 1.2         Sid Birari                 04/18/2014        Issue Fixing to calculate 'Negative Scores' appropriately
 */


public class OpportunityAssignDealScoreHelper{
    
    //Private Variables
    private static final String  EQUALS_TO = 'equals to';
    private static final String  NOT_EQUALS_TO = 'not equals to';
    private static final String  GREATER_THAN = 'greater than';
    private static final String  LESS_THAN = 'less than';
    private static final String  GREATER_THAN_OR_EQUAL = 'greater than or equal to';
    private static final String  LESS_THAN_OR_EQUAL = 'less than or equal to';
    private static final String  IN_BETWEEN = 'in between';
    private static final String  INCLUDES = 'includes';
    private static final String  EXCLUDES = 'excludes';
    private static final String  COMPARISON_TYPE_MULTIPLE_SINGLE = 'Multiple – Single Select';
    private static final String  COMPARISON_TYPE_MULTIPLE_SELECT = 'Multiple – Multi Select';
    private static final String  PIPE = '\\|';
    private static final String  COMMA = ';';
    
    //Calculate the Deal Rating based on comparison criteria configured in the Rule and Rule 
    //Criteria objects.
    public void calculateDealScoreValue(List<Opportunity> pOppNewLst ){
        
        Decimal assigningScore = 0,totalMaxRatingPossible=0,maxScoreExcluded=0;
        List<String> multipleStringLst = new List<String>();
        Integer flag = 0,flag1=0;
        String tempString;
        
        //Sid 1.2
        Boolean blnIsScoreAssigned = false;
        Decimal decIndividualRuleScore = 0;
        
        Map<Id,Rule__c> mapRule = new Map<id,Rule__c>([SELECT Id,
                                                              Name,
                                                              Sort_Order__c, 
                                                              Scoring_Field_to_Update__c,
                                                              Active__c,
                                                              Max_Rating_Possible__c,
                                                              Exclude_from_Max_Score__c,
                                                              (SELECT Id,
                                                                      Name,
                                                                      Score_Value_to_Assign__c, 
                                                                      Rule__c, 
                                                                      Operator_to_Use__c, 
                                                                      Min_Field_Value_s__c, 
                                                                      Max_Field_Value_s__c,
                                                                      Field_API_Name__c, 
                                                                      Comparison_Type__c
                                                               FROM  Rule_Criterias__r)           
                                                         FROM Rule__c  
                                                         Order By Sort_Order__c]);
        if(!mapRule.isEmpty()){
          
            for(Opportunity oppItr : pOppNewLst){
                //try{assigningScore = 0;
                    
                    //Sid 1.1
                    totalMaxRatingPossible = 0;
                    maxScoreExcluded = 0;
                    
                    for(Rule__c ruleItr : mapRule.values()){
                        
                        if(ruleItr.active__c){
                            
                            tempString = ruleItr.Scoring_Field_to_Update__c;
                            System.debug('else'+'===='+tempString);
                            System.debug('*****ruleItr.Exclude_from_Max_Score__c'+ruleItr.Exclude_from_Max_Score__c);
                            if(ruleItr.Max_Rating_Possible__c <> null){
                            	maxScoreExcluded = !ruleItr.Exclude_from_Max_Score__c ? (maxScoreExcluded += ruleItr.Max_Rating_Possible__c): maxScoreExcluded;                                                       
                           
                            totalMaxRatingPossible += ruleItr.Max_Rating_Possible__c;
                            }   
                                System.debug('==== EVALUATION FOR RULE ' + ruleItr.Name);
                                
                                //Sid 1.2
                                blnIsScoreAssigned = false;
                                decIndividualRuleScore = 0;
                                
                                for(Rule_Criteria__c ruleCriteriaItr : mapRule.get(ruleItr.id).Rule_Criterias__r){
                                    
                                    System.debug('======= comparision type ' + ruleCriteriaItr.Comparison_Type__c);
                                    if(ruleCriteriaItr.Comparison_Type__c <> null){
	                                    if(ruleCriteriaItr.Comparison_Type__c.equalsIgnoreCase(COMPARISON_TYPE_MULTIPLE_SINGLE)){
	                                    
	                                        multipleStringLst = ruleCriteriaItr.Min_Field_Value_s__c.split(PIPE);
	                                        System.debug('====multipleStringLst'+multipleStringLst);
	                                        for(String tempStringItr : multipleStringLst){
	                                        
	                                            if(tempStringItr.equalsIgnoreCase(String.valueOf(oppItr.get(ruleCriteriaItr.Field_API_Name__c)))){
	        
	                                                oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
	                                                assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c; 
	                                                system.debug('====='+tempString+'==='+ruleCriteriaItr.Score_Value_to_Assign__c);
	                                                
	                                                //Sid 1.2
	                                                blnIsScoreAssigned = true;
	                                                
	                                                flag = 1;
	                                                break;
	                                            }
	                                        }
	                                        if(flag==1)    break;
	                                        else    oppItr.put(tempString,0);
	                                    }
	                                    system.debug('****ruleCriteriaItr.Operator_to_Use__c****'+ruleCriteriaItr.Operator_to_Use__c);
                                    }
                                    
                                    
                                    //COMPARISION TYPE - SINGLE
                                    else if((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(EQUALS_TO) && 
                                            oppItr.get(ruleCriteriaItr.Field_API_Name__c) == ruleCriteriaItr.Min_Field_Value_s__c) ||
                                            ((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(EQUALS_TO) && 
                                            oppItr.get(ruleCriteriaItr.Field_API_Name__c) == boolean.valueOf(ruleCriteriaItr.Min_Field_Value_s__c)))||
                                            ((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(EQUALS_TO) && 
                                            String.isBlank(String.valueOf(oppItr.get(ruleCriteriaItr.Field_API_Name__c))) && String.valueOf(ruleCriteriaItr.Min_Field_Value_s__c).equalsIgnoreCase('NULL'))
                                            )){
                                            
                                            oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                            assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                            
                                            //Sid 1.2
                                            blnIsScoreAssigned = true;
                                            
                                            break;
                                    }
                                    
                                    else if((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(NOT_EQUALS_TO) && 
                                            oppItr.get(ruleCriteriaItr.Field_API_Name__c) != ruleCriteriaItr.Min_Field_Value_s__c) ||
                                            ((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(NOT_EQUALS_TO) && 
                                            oppItr.get(ruleCriteriaItr.Field_API_Name__c) != boolean.valueOf(ruleCriteriaItr.Min_Field_Value_s__c)))){
                                            
                                            oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                            assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                            
                                            //Sid 1.2
                                            blnIsScoreAssigned = true;
                                            
                                            break;
                                    }
                                    
                                    else if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(GREATER_THAN) && 
                                           (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) > Integer.valueof(ruleCriteriaItr.Min_Field_Value_s__c))){
                                            
                                            oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                            assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                            
                                            //Sid 1.2
                                            blnIsScoreAssigned = true;
                                            
                                            break;
                                    }
                                    
                                    else if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(LESS_THAN) && 
                                           (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) < Integer.valueof(ruleCriteriaItr.Min_Field_Value_s__c))){
                                       
                                           oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                           assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                           
                                           //Sid 1.2
                                           blnIsScoreAssigned = true;
                                           
                                           break;
                                    }
                                    else if((ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(IN_BETWEEN)) && 
                                            (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) >= Integer.valueof(ruleCriteriaItr.Min_Field_Value_s__c)) &&
                                            (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) < Integer.valueof(ruleCriteriaItr.Max_Field_Value_s__c))){
                                            
                                            oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                            assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                            
                                            //Sid 1.2
                                            blnIsScoreAssigned = true;
                                            
                                            break;
                                    }
                                    else if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(GREATER_THAN_OR_EQUAL) && 
                                           (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) >= Integer.valueof(ruleCriteriaItr.Min_Field_Value_s__c))){
                                           
                                           oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                           assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                           
                                           //Sid 1.2
                                           blnIsScoreAssigned = true;
                                           
                                           break;
                                    }
                                    
                                    else if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(LESS_THAN_OR_EQUAL) && 
                                           (Integer.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) <= Integer.valueof(ruleCriteriaItr.Min_Field_Value_s__c))){
                                       
                                           oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                           assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                           
                                           //Sid 1.2
                                           blnIsScoreAssigned = true;
                                           
                                           break;
                                    }
                                    
                                    //COMPARISION TYPE - MULTIPLE - MULTI SELECT
                                    else if(ruleCriteriaItr.Comparison_Type__c.equalsIgnoreCase(COMPARISON_TYPE_MULTIPLE_SELECT)){
                                         System.debug('======= Multi Select');
                                         System.debug('========== String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)) ' + String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)));
                                          if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(INCLUDES)&& (!String.isBlank(String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c))))){
                                            for(String oppStrItr : String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)).split(COMMA)){
                                                for(String ruleStrItr : ruleCriteriaItr.Min_Field_Value_s__c.split(COMMA)){
                                                    if(oppStrItr.equalsIgnoreCase(ruleStrItr)){
                                                        //Sid 1.2
                                                        //oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                                        //assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                        
                                                        //Sid 1.2
                                                        assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                        decIndividualRuleScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                        oppItr.put(tempString, decIndividualRuleScore);                                                        
                                                        blnIsScoreAssigned = true;
                                                        
                                                        flag1 = 1;
                                                        
                                                        System.debug('====== INCLUDES value to assign ' + ruleCriteriaItr.Score_Value_to_Assign__c);
                                                        System.debug('====== INCLUDES Opportunity ' + oppItr);
                                                        break;
                                                    }
                                                }
                                                if(flag1 == 1)
                                                    break;
                                            }
                                            System.debug('====== INCLUDES ASSIGNING SCORE ' + assigningScore);
                                          }
                                          else if(ruleCriteriaItr.Operator_to_Use__c.equalsIgnoreCase(EXCLUDES)
                                          &&(!String.isBlank(String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c))))){
                                            
                                            for(String oppStrItr : String.valueof(oppItr.get(ruleCriteriaItr.Field_API_Name__c)).split(COMMA)){
                                                for(String ruleStrItr : ruleCriteriaItr.Min_Field_Value_s__c.split(COMMA)){
                                                    if(oppStrItr.equalsIgnoreCase(ruleStrItr)){
                                                        flag1 = 1;
                                                        break;
                                                    }
                                                    else{
                                                        flag1 = 0;
                                                    }
                                                }
                                                System.debug('===== flag1 ' + flag1);
                                                if(flag1 == 0){  
                                                    //Sid 1.2
                                                    //oppItr.put(tempString,ruleCriteriaItr.Score_Value_to_Assign__c);
                                                    //assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                    
                                                    //Sid 1.2
                                                    assigningScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                    decIndividualRuleScore += ruleCriteriaItr.Score_Value_to_Assign__c;
                                                    oppItr.put(tempString, decIndividualRuleScore);
                                                    blnIsScoreAssigned = true;                                                    
                                                    
                                                    System.debug('====== EXCLUDES ASSIGNING SCORE ' + assigningScore);
                                                    System.debug('====== score value to assign ' + ruleCriteriaItr.Score_Value_to_Assign__c);
                                                    System.debug('====== Opportunity ' + oppItr);
                                                    break;
                                                }                                                
                                                else if(flag1 == 1)                                                
                                                break;
                                            }
                                            System.debug('====== FINAL ASSIGNING SCORE ' + assigningScore);
                                          }
                                    }
                                    else{
                                        System.debug('else'+tempString);
                                        //Sid 1.2
                                        if(!blnIsScoreAssigned)
                                            oppItr.put(tempString,0);
                                    }
                            }//for - Rule Criteria
                        }
                        else{
                            tempString = ruleItr.Scoring_Field_to_Update__c;
                            oppItr.put(tempString,0);
                            assigningScore +=0;
                        }// if - else end
                }//for - Rule
                System.debug('===== ASSIGNING SCORE ' + assigningScore);
                System.debug('====== Opportunity ' + oppItr);
                if(totalMaxRatingPossible != 0){
                    oppItr.Total_Rating_New__c = assigningScore;
                    oppItr.Max_Score__c = totalMaxRatingPossible;
                    oppItr.Max_Score_with_Excluded_Rule__c = maxScoreExcluded;
                } 
                else{
                	System.debug('successful====');
                    oppItr.Total_Rating_New__c = 0;
                    oppItr.Max_Score__c = 0;
                    oppItr.Max_Score_with_Excluded_Rule__c = 0;
                }
            /*} catch(Exception e){
                oppItr.addError(e.getMessage()+' on Rule custom object');
            }*/
        }//for - Opportunity
       
    }
  }
}
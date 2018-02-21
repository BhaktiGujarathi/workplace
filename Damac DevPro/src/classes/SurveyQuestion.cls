public with sharing class SurveyQuestion { 
    
    public String   name                        {get; set;}
    public String   id                          {get; set;}
    public String   question                    {get; set;}
    public String   orderNumber                 {get; set;}
    public String   choices                     {get; set;}
    public String   selectedOption              {get; set;}
    public List<String> selectedOptions         {get; set;}
    public List<SelectOption> singleOptions     {get; set;}
    public List<SelectOption> multiOptions      {get; set;}
    public Boolean  required                    {get; set;}
    public String   questionType                {get; set;}
    public String   surveyName                  {get; set;}
    public Boolean   renderFreeText             {get; set;}
    public Boolean   renderSelectRadio          {get; set;}
    public Boolean   renderSelectCheckboxes     {get; set;}
    public Boolean   renderSelectRow            {get; set;}
    public Boolean   renderPicklist             {get; set;}
    public List<String> responses               {get; set;}
    public List<SelectOption> rowOptions        {get; set;}
    public String noOfRowsForTextArea           {get; set;}
    public String   choiceForAdditionalTextbox  {get; set;}
    public String   additionalTextboxNumber     {get; set;}
    public String   additionalResponse          {get; set;}
    public List<SurveyQuestion> subQuestions    {get; set;}
    public Survey_Question__c surveyQuestion    {get; set;}
    public Boolean isSubQuestion                {get; set;}
    
    /** Fills up the question object
     *  param:    Survey_Question__c
     */
    public SurveyQuestion(Survey_Question__c sq, List<SurveyQuestion> subQuestionList) {
        name = sq.Name;
        surveyQuestion = sq;
        id = sq.Id;
        question = sq.Question__c;
        isSubQuestion = false;
        if(subQuestionList != null && subQuestionList.size() >0){
            isSubQuestion = true;
        }
        subQuestions = subQuestionList;
        orderNumber = sq.Order_Number_Displayed__c;
        choices = sq.Choices__c;
        required = sq.Required__c;
        questionType = sq.Type__c;  
        choiceForAdditionalTextbox = sq.Choice_for_Additional_Textbox__c;
        selectedOption = '';
        additionalResponse = '';
        additionalTextboxNumber = '';
        renderSelectRadio = false;
        renderSelectCheckboxes = false;
        renderPicklist = false;
        renderFreeText = false;
        renderSelectRow = false;
        selectedOptions = new List < String > ();
        if (sq.Type__c == 'Single Select--Vertical') {
            renderSelectRadio = true;
            singleOptions = stringToSelectOptions(choices);

            renderSelectCheckboxes = false;
            renderPicklist = false;
            renderFreeText = false;
            renderSelectRow = false;
            selectedOption = '';
            selectedOptions = new List < String > ();
        }
        else if (sq.Type__c == 'Multi-Select--Vertical') {
            renderSelectCheckboxes = true;
            multiOptions = stringToSelectOptions(choices);
            renderSelectRadio = false;
            renderPicklist = false;
            renderFreeText = false;
            renderSelectRow = false;
            selectedOption = '';
            selectedOptions = new List < String > ();
        }
        else if (sq.Type__c == 'Single Select--Horizontal') {
            renderSelectCheckboxes = false;
            rowOptions = stringToSelectOptions(choices);
            renderSelectRadio = false;
            renderPicklist = false;
            renderFreeText = false;
            renderSelectRow = true;
            selectedOption = '';
            selectedOptions = new List < String > ();

        }else if (sq.Type__c == 'Picklist') {
            renderPicklist = true;
            renderSelectRadio = false;
            singleOptions = new List<SelectOption>();
            singleOptions.add(new SelectOption('', ''));
            singleOptions.addAll(stringToSelectOptions(choices));

            renderSelectCheckboxes = false;
            renderFreeText = false;
            renderSelectRow = false;
            selectedOption = '';
            selectedOptions = new List < String > ();
        }
        else if (sq.Type__c == 'Free Text' || sq.Type__c == 'Free Text - Single Row Visible') {
            renderFreeText = true;
            renderSelectRadio = false;
            renderSelectCheckboxes = false;
            renderPicklist = false;
            renderSelectRow = false;
            choices = '';

            //If it's text area but for single row then only show single row even though it's stil text area
            if (sq.Type__c == 'Free Text - Single Row Visible') {
                noOfRowsForTextArea = '1';
            } else {
                noOfRowsForTextArea = '5';
            }

        }
        //responses= getResponses();
    }

    /** Splits up the string as given by the user and adds each option
    *  to a list to be displayed as option on the Visualforce page
    *  param: str   String as submitted by the user
    *  returns the List of SelectOption for the visualforce page
    */
    private List < SelectOption > stringToSelectOptions(String str) {
        if (str == '') {
            return new List < SelectOption > ();
        }
        List<String> strList = str.split('\n');

        List < SelectOption > returnVal = new List < SelectOption > ();
        Integer i = 0;
        for (String s: strList) {
            if (s != '') {
                if (s != 'null' && s != null) {
                    String sBis = s.replace(' ', '%20');
                    if(choiceForAdditionalTextbox != null){
                        List<String> optionList = choiceForAdditionalTextbox.split(';');
                        if(optionList.size()>0){
                            for (String option : optionList) {
                                if(option != '' && option.equals(s.trim())){
                                    additionalTextboxNumber = additionalTextboxNumber + String.valueOf(i) + ';';
                                    continue;
                                }
                            }
                        }
                    }
                    
                    returnVal.add(new SelectOption(String.valueOf(i), s));
                    i++;
                }
            }
        }
        return returnVal;
    }
}
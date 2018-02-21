/***********************************************************************************
 * Class : PositionSelectOption
 * Created By : Ashwini Singh
 -----------------------------------------------------------------------------------
 * Description : Wrapper class for storing label and value for picklist values
 -----------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ashwini Singh    02/05/2016    Initial Development
 **********************************************************************************/
public with sharing class PositionSelectOption {

    public String label {get; set;}
    public String value {get; set;}

    public PositionSelectOption(String label,String value) {
            this.label = label;
            this.value = value;
    }

}
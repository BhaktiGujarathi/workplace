<?xml version="1.0" encoding="utf-8"?>
<wsdl:definitions xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:tns="http://achworks.com/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" targetNamespace="http://achworks.com/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
  <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">ACHWorksWS (ACHWorks-SOAP 4.0) is a web service (web API) by &lt;a href="http://www.achworks.com"&gt;ACHWorks&lt;/a&gt; that provides a complete solution for Automated Clearing House (ACH) operations:  Sending transactions and getting status of returns and settlements.  The complete API Guide can be downloaded &lt;a href="http://www.achworks.com/files/achworkssoapver4guide.pdf"&gt;here&lt;/a&gt;.   Please &lt;a href="http://www.achworks.com/contactus"&gt;contact us&lt;/a&gt; for more information. Last updated on: 05/17/2013. Release Version 4.0.10HA</wsdl:documentation>
  <wsdl:types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://achworks.com/">
      <s:element name="ConnectionCheck">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="CompanyInfo">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Company" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CompanyKey" type="s:string" />
        </s:sequence>
      </s:complexType>
      <s:element name="ConnectionCheckResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="ConnectionCheckResult" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="CheckCompanyStatus">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="CheckCompanyStatusResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="CheckCompanyStatusResult" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="SendACHTrans">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpACHTransRecord" type="tns:ACHTransRecord" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="ACHTransRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="FrontEndTrace" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="OriginatorName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="TransactionCode" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustTransType" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerRoutingNo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerAcctNo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerAcctType" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TransAmount" type="s:double" />
          <s:element minOccurs="0" maxOccurs="1" name="CheckOrCustID" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="CheckOrTransDate" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="EffectiveDate" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="Memo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="OpCode" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="AccountSet" type="s:string" />
        </s:sequence>
      </s:complexType>
      <s:element name="SendACHTransResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="SendACHTransResult" type="tns:TransResult" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="TransResult">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Status" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Details" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CallMethod" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="CallDateTime" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="FileName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="FrontEndTrace" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumErrors" type="s:int" />
          <s:element minOccurs="0" maxOccurs="1" name="Errors" type="tns:ArrayOfString" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfString">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="string" nillable="true" type="s:string" />
        </s:sequence>
      </s:complexType>
      <s:element name="SendACHTransBatch">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpACHFile" type="tns:ACHFile" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="ACHFile">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="ACHFileName" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalDebitRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalDebitAmount" type="s:double" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalCreditRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalCreditAmount" type="s:double" />
          <s:element minOccurs="0" maxOccurs="1" name="ACHRecords" type="tns:ArrayOfACHTransRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfACHTransRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="ACHTransRecord" nillable="true" type="tns:ACHTransRecord" />
        </s:sequence>
      </s:complexType>
      <s:element name="SendACHTransBatchResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="SendACHTransBatchResult" type="tns:TransResult" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="SendACHTransBatchBin">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpBinFile" type="s:base64Binary" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="SendACHTransBatchBinResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="SendACHTransBatchBinResult" type="tns:TransResult" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="SendIATACHTransBatch">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpACHFile" type="tns:IATACHFile" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="IATACHFile">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="ACHFileName" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalDebitRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalDebitAmount" type="s:double" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalCreditRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalCreditAmount" type="s:double" />
          <s:element minOccurs="0" maxOccurs="1" name="IATOptions" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="IATACHRecords" type="tns:ArrayOfIATACHTransRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfIATACHTransRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="IATACHTransRecord" nillable="true" type="tns:IATACHTransRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="IATACHTransRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="FrontEndTrace" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="OriginatorName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="TransactionCode" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustTransType" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerRoutingNo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerAcctNo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerAcctType" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerAddress" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerBank" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerBankAddress" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerBenef" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerBenefAddress" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TransAmount" type="s:double" />
          <s:element minOccurs="0" maxOccurs="1" name="CheckOrCustID" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="CheckOrTransDate" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="EffectiveDate" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="Memo" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="OpCode" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="AccountSet" type="s:string" />
        </s:sequence>
      </s:complexType>
      <s:element name="SendIATACHTransBatchResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="SendIATACHTransBatchResult" type="tns:TransResult" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturns">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsResult" type="tns:ACHReturns" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="ACHReturns">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Status" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Details" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="ReturnDateFrom" nillable="true" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="ReturnDateTo" nillable="true" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumErrors" type="s:int" />
          <s:element minOccurs="0" maxOccurs="1" name="Errors" type="tns:ArrayOfString" />
          <s:element minOccurs="0" maxOccurs="1" name="ACHReturnRecords" type="tns:ArrayOfACHReturnRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfACHReturnRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="ACHReturnRecord" nillable="true" type="tns:ACHReturnRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ACHReturnRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="SourceFile" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="FrontEndTrace" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="ResponseCode" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustTransType" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="BackEndSN" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CustomerName" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TransAmount" nillable="true" type="s:double" />
          <s:element minOccurs="1" maxOccurs="1" name="EffectiveDate" nillable="true" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="ActionDate" nillable="true" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="ActionDetail" type="s:string" />
        </s:sequence>
      </s:complexType>
      <s:element name="GetACHReturnsHist">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateFrom" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateTo" type="s:dateTime" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsHistResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsHistResult" type="tns:ACHReturns" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsRC">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpResponseCode" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsRCResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsRCResult" type="tns:ACHReturns" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsHistRC">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateFrom" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateTo" type="s:dateTime" />
            <s:element minOccurs="0" maxOccurs="1" name="InpResponseCode" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsHistRCResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsHistRCResult" type="tns:ACHReturns" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsBin">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="InpReturnFormat" type="tns:ReturnsFormat" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:simpleType name="ReturnsFormat">
        <s:restriction base="s:string">
          <s:enumeration value="ByRecord" />
          <s:enumeration value="ByFile" />
        </s:restriction>
      </s:simpleType>
      <s:element name="GetACHReturnsBinResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsBinResult" type="s:base64Binary" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsHistBin">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateFrom" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="ReturnDateTo" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="InpReturnFormat" type="tns:ReturnsFormat" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetACHReturnsHistBinResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetACHReturnsHistBinResult" type="s:base64Binary" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetResultFile">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="ResultDateFrom" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="ResultDateTo" type="s:dateTime" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetResultFileResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetResultFileResult" type="tns:ResultFile" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="ResultFile">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Status" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Details" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalResultRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="ResultDateFrom" nillable="true" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="ResultDateTo" nillable="true" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="TransResults" type="tns:ArrayOfTransResult" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfTransResult">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="TransResult" nillable="true" type="tns:TransResult" />
        </s:sequence>
      </s:complexType>
      <s:element name="GetErrorFile">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="1" maxOccurs="1" name="ErrorDateFrom" type="s:dateTime" />
            <s:element minOccurs="1" maxOccurs="1" name="ErrorDateTo" type="s:dateTime" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="GetErrorFileResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="GetErrorFileResult" type="tns:ErrorFile" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="ErrorFile">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Status" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="Details" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalErrorRecords" type="s:int" />
          <s:element minOccurs="1" maxOccurs="1" name="ErrorDateFrom" nillable="true" type="s:dateTime" />
          <s:element minOccurs="1" maxOccurs="1" name="ErrorDateTo" nillable="true" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="ErrorRecords" type="tns:ArrayOfErrorRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ArrayOfErrorRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="unbounded" name="ErrorRecord" nillable="true" type="tns:ErrorRecord" />
        </s:sequence>
      </s:complexType>
      <s:complexType name="ErrorRecord">
        <s:sequence>
          <s:element minOccurs="0" maxOccurs="1" name="SSS" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="LocID" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="CallMethod" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="CallDateTime" type="s:dateTime" />
          <s:element minOccurs="0" maxOccurs="1" name="FileName" type="s:string" />
          <s:element minOccurs="0" maxOccurs="1" name="FrontEndTrace" type="s:string" />
          <s:element minOccurs="1" maxOccurs="1" name="TotalNumErrors" type="s:int" />
          <s:element minOccurs="0" maxOccurs="1" name="Errors" type="tns:ArrayOfString" />
        </s:sequence>
      </s:complexType>
      <s:element name="ViewACHTransBatch">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpACHFileName" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="ViewACHTransBatchResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="ViewACHTransBatchResult" type="tns:ACHFile" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="DeleteACHTransBatch">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="InpCompanyInfo" type="tns:CompanyInfo" />
            <s:element minOccurs="0" maxOccurs="1" name="InpACHFileName" type="s:string" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="DeleteACHTransBatchResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="0" maxOccurs="1" name="DeleteACHTransBatchResult" type="tns:TransResult" />
          </s:sequence>
        </s:complexType>
      </s:element>
    </s:schema>
  </wsdl:types>
  <wsdl:message name="ConnectionCheckSoapIn">
    <wsdl:part name="parameters" element="tns:ConnectionCheck" />
  </wsdl:message>
  <wsdl:message name="ConnectionCheckSoapOut">
    <wsdl:part name="parameters" element="tns:ConnectionCheckResponse" />
  </wsdl:message>
  <wsdl:message name="CheckCompanyStatusSoapIn">
    <wsdl:part name="parameters" element="tns:CheckCompanyStatus" />
  </wsdl:message>
  <wsdl:message name="CheckCompanyStatusSoapOut">
    <wsdl:part name="parameters" element="tns:CheckCompanyStatusResponse" />
  </wsdl:message>
  <wsdl:message name="SendACHTransSoapIn">
    <wsdl:part name="parameters" element="tns:SendACHTrans" />
  </wsdl:message>
  <wsdl:message name="SendACHTransSoapOut">
    <wsdl:part name="parameters" element="tns:SendACHTransResponse" />
  </wsdl:message>
  <wsdl:message name="SendACHTransBatchSoapIn">
    <wsdl:part name="parameters" element="tns:SendACHTransBatch" />
  </wsdl:message>
  <wsdl:message name="SendACHTransBatchSoapOut">
    <wsdl:part name="parameters" element="tns:SendACHTransBatchResponse" />
  </wsdl:message>
  <wsdl:message name="SendACHTransBatchBinSoapIn">
    <wsdl:part name="parameters" element="tns:SendACHTransBatchBin" />
  </wsdl:message>
  <wsdl:message name="SendACHTransBatchBinSoapOut">
    <wsdl:part name="parameters" element="tns:SendACHTransBatchBinResponse" />
  </wsdl:message>
  <wsdl:message name="SendIATACHTransBatchSoapIn">
    <wsdl:part name="parameters" element="tns:SendIATACHTransBatch" />
  </wsdl:message>
  <wsdl:message name="SendIATACHTransBatchSoapOut">
    <wsdl:part name="parameters" element="tns:SendIATACHTransBatchResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturns" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHist" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHistResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsRCSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturnsRC" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsRCSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsRCResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistRCSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHistRC" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistRCSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHistRCResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsBinSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturnsBin" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsBinSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsBinResponse" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistBinSoapIn">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHistBin" />
  </wsdl:message>
  <wsdl:message name="GetACHReturnsHistBinSoapOut">
    <wsdl:part name="parameters" element="tns:GetACHReturnsHistBinResponse" />
  </wsdl:message>
  <wsdl:message name="GetResultFileSoapIn">
    <wsdl:part name="parameters" element="tns:GetResultFile" />
  </wsdl:message>
  <wsdl:message name="GetResultFileSoapOut">
    <wsdl:part name="parameters" element="tns:GetResultFileResponse" />
  </wsdl:message>
  <wsdl:message name="GetErrorFileSoapIn">
    <wsdl:part name="parameters" element="tns:GetErrorFile" />
  </wsdl:message>
  <wsdl:message name="GetErrorFileSoapOut">
    <wsdl:part name="parameters" element="tns:GetErrorFileResponse" />
  </wsdl:message>
  <wsdl:message name="ViewACHTransBatchSoapIn">
    <wsdl:part name="parameters" element="tns:ViewACHTransBatch" />
  </wsdl:message>
  <wsdl:message name="ViewACHTransBatchSoapOut">
    <wsdl:part name="parameters" element="tns:ViewACHTransBatchResponse" />
  </wsdl:message>
  <wsdl:message name="DeleteACHTransBatchSoapIn">
    <wsdl:part name="parameters" element="tns:DeleteACHTransBatch" />
  </wsdl:message>
  <wsdl:message name="DeleteACHTransBatchSoapOut">
    <wsdl:part name="parameters" element="tns:DeleteACHTransBatchResponse" />
  </wsdl:message>
  <wsdl:portType name="ACHWorksWSSoap">
    <wsdl:operation name="ConnectionCheck">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Checks validity of user/company information</wsdl:documentation>
      <wsdl:input message="tns:ConnectionCheckSoapIn" />
      <wsdl:output message="tns:ConnectionCheckSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="CheckCompanyStatus">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Checks status of user/company account</wsdl:documentation>
      <wsdl:input message="tns:CheckCompanyStatusSoapIn" />
      <wsdl:output message="tns:CheckCompanyStatusSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="SendACHTrans">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Sends single ACH transaction record</wsdl:documentation>
      <wsdl:input message="tns:SendACHTransSoapIn" />
      <wsdl:output message="tns:SendACHTransSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatch">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Sends multiple ACH transaction records</wsdl:documentation>
      <wsdl:input message="tns:SendACHTransBatchSoapIn" />
      <wsdl:output message="tns:SendACHTransBatchSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatchBin">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Sends multiple ACH transaction records in a binary encoded file</wsdl:documentation>
      <wsdl:input message="tns:SendACHTransBatchBinSoapIn" />
      <wsdl:output message="tns:SendACHTransBatchBinSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="SendIATACHTransBatch">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Sends multiple IAT ACH transaction records</wsdl:documentation>
      <wsdl:input message="tns:SendIATACHTransBatchSoapIn" />
      <wsdl:output message="tns:SendIATACHTransBatchSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturns">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets returns and deletes from server</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsSoapIn" />
      <wsdl:output message="tns:GetACHReturnsSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHist">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets returns from given date range</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsHistSoapIn" />
      <wsdl:output message="tns:GetACHReturnsHistSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsRC">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets returns per entered responsecode and deletes from server</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsRCSoapIn" />
      <wsdl:output message="tns:GetACHReturnsRCSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistRC">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets returns per entered response code from given date range</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsHistRCSoapIn" />
      <wsdl:output message="tns:GetACHReturnsHistRCSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsBin">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets binary return files and deletes from server</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsBinSoapIn" />
      <wsdl:output message="tns:GetACHReturnsBinSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistBin">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets binary return files from given date range</wsdl:documentation>
      <wsdl:input message="tns:GetACHReturnsHistBinSoapIn" />
      <wsdl:output message="tns:GetACHReturnsHistBinSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetResultFile">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets result records at specified date range</wsdl:documentation>
      <wsdl:input message="tns:GetResultFileSoapIn" />
      <wsdl:output message="tns:GetResultFileSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="GetErrorFile">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Gets error records at specified date range</wsdl:documentation>
      <wsdl:input message="tns:GetErrorFileSoapIn" />
      <wsdl:output message="tns:GetErrorFileSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="ViewACHTransBatch">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">View or Read an ACH Batch File</wsdl:documentation>
      <wsdl:input message="tns:ViewACHTransBatchSoapIn" />
      <wsdl:output message="tns:ViewACHTransBatchSoapOut" />
    </wsdl:operation>
    <wsdl:operation name="DeleteACHTransBatch">
      <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">Delete or Stop an ACH Batch File</wsdl:documentation>
      <wsdl:input message="tns:DeleteACHTransBatchSoapIn" />
      <wsdl:output message="tns:DeleteACHTransBatchSoapOut" />
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="ACHWorksWSSoap" type="tns:ACHWorksWSSoap">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http" />
    <wsdl:operation name="ConnectionCheck">
      <soap:operation soapAction="http://achworks.com/ConnectionCheck" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="CheckCompanyStatus">
      <soap:operation soapAction="http://achworks.com/CheckCompanyStatus" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTrans">
      <soap:operation soapAction="http://achworks.com/SendACHTrans" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatch">
      <soap:operation soapAction="http://achworks.com/SendACHTransBatch" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatchBin">
      <soap:operation soapAction="http://achworks.com/SendACHTransBatchBin" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendIATACHTransBatch">
      <soap:operation soapAction="http://achworks.com/SendIATACHTransBatch" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturns">
      <soap:operation soapAction="http://achworks.com/GetACHReturns" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHist">
      <soap:operation soapAction="http://achworks.com/GetACHReturnsHist" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsRC">
      <soap:operation soapAction="http://achworks.com/GetACHReturnsRC" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistRC">
      <soap:operation soapAction="http://achworks.com/GetACHReturnsHistRC" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsBin">
      <soap:operation soapAction="http://achworks.com/GetACHReturnsBin" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistBin">
      <soap:operation soapAction="http://achworks.com/GetACHReturnsHistBin" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetResultFile">
      <soap:operation soapAction="http://achworks.com/GetResultFile" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetErrorFile">
      <soap:operation soapAction="http://achworks.com/GetErrorFile" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="ViewACHTransBatch">
      <soap:operation soapAction="http://achworks.com/ViewACHTransBatch" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="DeleteACHTransBatch">
      <soap:operation soapAction="http://achworks.com/DeleteACHTransBatch" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:binding name="ACHWorksWSSoap12" type="tns:ACHWorksWSSoap">
    <soap12:binding transport="http://schemas.xmlsoap.org/soap/http" />
    <wsdl:operation name="ConnectionCheck">
      <soap12:operation soapAction="http://achworks.com/ConnectionCheck" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="CheckCompanyStatus">
      <soap12:operation soapAction="http://achworks.com/CheckCompanyStatus" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTrans">
      <soap12:operation soapAction="http://achworks.com/SendACHTrans" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatch">
      <soap12:operation soapAction="http://achworks.com/SendACHTransBatch" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendACHTransBatchBin">
      <soap12:operation soapAction="http://achworks.com/SendACHTransBatchBin" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SendIATACHTransBatch">
      <soap12:operation soapAction="http://achworks.com/SendIATACHTransBatch" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturns">
      <soap12:operation soapAction="http://achworks.com/GetACHReturns" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHist">
      <soap12:operation soapAction="http://achworks.com/GetACHReturnsHist" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsRC">
      <soap12:operation soapAction="http://achworks.com/GetACHReturnsRC" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistRC">
      <soap12:operation soapAction="http://achworks.com/GetACHReturnsHistRC" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsBin">
      <soap12:operation soapAction="http://achworks.com/GetACHReturnsBin" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetACHReturnsHistBin">
      <soap12:operation soapAction="http://achworks.com/GetACHReturnsHistBin" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetResultFile">
      <soap12:operation soapAction="http://achworks.com/GetResultFile" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="GetErrorFile">
      <soap12:operation soapAction="http://achworks.com/GetErrorFile" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="ViewACHTransBatch">
      <soap12:operation soapAction="http://achworks.com/ViewACHTransBatch" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="DeleteACHTransBatch">
      <soap12:operation soapAction="http://achworks.com/DeleteACHTransBatch" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="ACHWorksWS">
    <wsdl:documentation xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">ACHWorksWS (ACHWorks-SOAP 4.0) is a web service (web API) by &lt;a href="http://www.achworks.com"&gt;ACHWorks&lt;/a&gt; that provides a complete solution for Automated Clearing House (ACH) operations:  Sending transactions and getting status of returns and settlements.  The complete API Guide can be downloaded &lt;a href="http://www.achworks.com/files/achworkssoapver4guide.pdf"&gt;here&lt;/a&gt;.   Please &lt;a href="http://www.achworks.com/contactus"&gt;contact us&lt;/a&gt; for more information. Last updated on: 05/17/2013. Release Version 4.0.10HA</wsdl:documentation>
    <wsdl:port name="ACHWorksWSSoap" binding="tns:ACHWorksWSSoap">
      <soap:address location="http://tstsvr.achworks.com/dnet/achws.asmx" />
    </wsdl:port>
    <wsdl:port name="ACHWorksWSSoap12" binding="tns:ACHWorksWSSoap12">
      <soap12:address location="http://tstsvr.achworks.com/dnet/achws.asmx" />
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
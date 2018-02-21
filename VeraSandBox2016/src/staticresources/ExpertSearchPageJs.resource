var HTML_INPUTTYPE_START = '<input';
var HTML_SELECT_TAG = '<select/>';
var HTML_OPTION_TAG = '<option/>';
var HTML_VALUE_ATTR = ' value ';
var HTML_TYPE_ATTR = ' type ';
var HTML_CLASS_ATTR = ' class ' ;
var HTML_DOUBLEQOUTES = '"';
var ANGULAR_BRACKET_END = '/>';
var HTML_EQUALS = '=';
var rowCount = 0;
var DEFAULT_OPTION = '--Select--';

j$ = jQuery.noConflict();

j$(document).ready(
    function($) {
        setCollapsibleListeners();
        setSectionState();
        createCacheForPicklist();
        if (j$('input[id$=prepopulatedFilter]').val()) {
            prepopulateFilters(j$('input[id$=prepopulatedFilter]').val());
        }
    }
);

/**
 * Adds new filter row in the filters section on page
 */
function addFilter() {
    addFilterRow();
    var rowId = "filterRow" + rowCount;
    showPicklist('1', null, rowId);
}

/**
 * Show picklist values for level passed to it
 * If data exists in cache, show data from cache else call remote action
 */
function showPicklist(level, value, rowId) {
    removeSelect(level, rowId);
    if(existsInCache(level, value)) {
        renderPicklist(level, rowId, getPicklistValuesFromCache(level, value));
    } else {
        invokeRemoteMethod(level, value, rowId, false);
    }
}

/**
 * Renders picklist and adds passed values to it
 */
function renderPicklist(level, rowId, values) {
    var lastlevel = false;
    j$.each(values, function(a, b) {
        if (b.value == 'last level') {
            lastlevel = true;
        }
    });
    if (!lastlevel) {
        var select = j$(HTML_SELECT_TAG);
        select.append(j$(HTML_OPTION_TAG).attr("value", DEFAULT_OPTION).text(DEFAULT_OPTION));
        j$.each(values, function(a, b) {
            select.append(j$(HTML_OPTION_TAG).attr("value", b.value).text(b.label));
        });
        j$("#"+rowId).find('.level'+level).append(select);
    }
}

/**
 * Empties next level of select from the passed row and level
 */
function removeSelect(level,rowId){
    for (i = level; i <= 4; i++) {
        j$('#'+rowId).find('.level'+i).find('select').remove();
    }
}

/**
 * Get the filter of next level from provided select.
 */
function getNextLevelFilter(event) {
    var value = j$(event).find('select').val();
    var level = j$(event).attr('data-level');
    var rowId = j$(event).closest('tr').attr('id');
    showPicklist(level, value, rowId);
}

/**
 * Called for removing the filters (whole row).
 */
function removeFilter(event) {
    j$(event).closest('tr').remove();
}

/**
 * Called for searching the contact.
 */
function callSearch() {
    addAndRemoveFilters();
}

/**
 * Adding or removing the filters to search contact it creates List of List of string.
 */
function addAndRemoveFilters() {
    var positionFilterValues = [];
    var filterLevel = [];
    var filterSelect = false;
    j$('.positionFilter').each(function() {
        filterLevels=[];
        for (i = 1; i <= 4; i++) {
            var filterLevel = j$(this).find('.level'+i).find('select').val() ?
                                j$(this).find('.level'+i).find('select').val() :
                                '';
            if (filterLevel !== '') {
                filterLevels.push(filterLevel);
            }
            if (filterLevel == DEFAULT_OPTION) {
                filterSelect = true;
            }
        }
        if (!filterSelect){
            positionFilterValues.push(filterLevels);
            j$("#responseErrors").html('');
        } else {
            var errorMessage = '<img src="/img/msg_icons/warning16.png"/>';
            errorMessage += '&nbsp;Few filters are not completed';
             j$("#responseErrors").html('').append(errorMessage);
        }
    });
    addRemoveFilters(JSON.stringify(positionFilterValues));
}

/**
 * Confirming the eligible experts
 */
function confirm(){
    confirmExperts();
}

/**
 * Save the selected expert.
 */
function save(){
    saveSelectedExpertDeployment();
}

/**
 * Remove the selected expert
 */
function removeExpert(event) {
    element = event.target;
    var expertId = element.id;
    DeleteExpertDeployment(expertId);
}

/**
 * Added generic function for input type
 */
function addInput(inputType, styleClassName, displayText, eventName, functionToInvoke) {
    return (HTML_INPUTTYPE_START + HTML_TYPE_ATTR + HTML_EQUALS+ HTML_DOUBLEQOUTES + inputType +
            HTML_DOUBLEQOUTES + HTML_CLASS_ATTR + HTML_EQUALS + HTML_DOUBLEQOUTES + styleClassName +
            HTML_DOUBLEQOUTES + HTML_VALUE_ATTR + HTML_EQUALS+ HTML_DOUBLEQOUTES +
            displayText + HTML_DOUBLEQOUTES + eventName + HTML_EQUALS+ HTML_DOUBLEQOUTES +
            functionToInvoke + HTML_DOUBLEQOUTES + ANGULAR_BRACKET_END);
}

/**
 * Prepopulating the filters if position is there.
 */
function prepopulateFilters(filterStringified) {
    var filters = JSON.parse(filterStringified);
    for (var i=0; i < filters.length; i++) {
        addFilterRow();
        for (var j=0; j < filters[i].length; j++) {
            var level = j+1;
            var selectedValue = filters[i][j];
            var previousValue = j === 0 ? null : filters[i][j-1];
            var rowId = 'filterRow'+(i+1);
            if(existsInCache(level, previousValue)) {
                renderPicklist(level, rowId, getPicklistValuesFromCache(level, previousValue));
                setFilterPicklistValue(level, rowId);
            } else {
                invokeRemoteMethod(level, previousValue, rowId, true);
            }
        }
    }
}

/**
 * To get the level1 value of filter
 */
function getSearchFilterName(level, rowId, isPrepopulatingCall) {
    if (!isPrepopulatingCall) {
        searchFilterName = j$('#'+rowId).find('.level1').find('select').val() ?
                            j$('#'+rowId).find('.level1').find('select').val() :
                            null;
    } else {
         searchFilterName = getFirstLevelValue(level, rowId);
    }
    return searchFilterName;
}

/**
 * Set picklist value for filters
 */
function setFilterPicklistValue(level, rowId) {
    var rowNumber = rowId.split('filterRow')[1];
    var filters = JSON.parse(j$('input[id$=prepopulatedFilter]').val());
    j$('#'+rowId).find('.level'+level).find('select').val(filters[rowNumber-1][level-1]);
}

/**
 * Get value for first level of filter
 */
function getFirstLevelValue(level, rowId) {
    var rowNumber = rowId.split('filterRow')[1];
    var filters = JSON.parse(j$('input[id$=prepopulatedFilter]').val());
    return filters[rowNumber-1][0];
}

/**
 * Adding row for filter
 */
function addFilterRow() {
    rowCount++;
    var tableBody = j$("#filterCriteriaTable");
    var appendHtml = '<tr id="filterRow'+rowCount+'" class="positionFilter">';
    appendHtml += '<td class="level1" data-level="2" onchange="getNextLevelFilter(this);"></td>';
    appendHtml += '<td class="level2" data-level="3" onchange="getNextLevelFilter(this);"></td>';
    appendHtml += '<td class="level3" data-level="4" onchange="getNextLevelFilter(this);"></td>';
    appendHtml += '<td class="level4"></td><td class="position-btn-container">';
    appendHtml += addInput('button', 'btn position-btn', 'Remove', 'onclick', 'removeFilter(this)');
    appendHtml +='</td></tr>';
    tableBody.append(appendHtml);
}

/**
 * Function definitions for caching of picklist values
 * Check picklistData exists in cache, if not create it
 */
function createCacheForPicklist() {
    if (!localStorage.picklistData) {
        var picklistData = {
            level1PicklistValues: [],
            level2PicklistValues: {},
            level3PicklistValues: {},
            level4PicklistValues: {}
        };
        updatePicklistCache(picklistData);
    }
}

/**
 * Returns values for next picklist to be rendered
 */
function getPicklistValuesFromCache(level, name) {
    var localPicklistData = getCachedPicklistData();
    var picklistValues = [];
    if (level == 1) {
        picklistValues = localPicklistData[getPropertyName(level)].slice();
    } else {
        picklistValues = localPicklistData[getPropertyName(level)][name].slice();
    }
    return picklistValues;
}

/**
 * Check if the dependent picklist values exist in cache
 */
function existsInCache(level, name) {
    var localPicklistData = getCachedPicklistData();
    var isExisting = false;
    if (level == 1) {
        isExisting = localPicklistData[getPropertyName(level)].length;
    } else {
        isExisting = localPicklistData[getPropertyName(level)].hasOwnProperty(name);
    }
    return isExisting;
}

/**
 * Cache new data in localStorage
 */
function savePicklistDataInCache(level, name, values) {
    if(!existsInCache(level, name)) {
        var localPicklistData = getCachedPicklistData();
        if (level == 1) {
            localPicklistData[getPropertyName(level)].push(...values);
        } else {
            localPicklistData[getPropertyName(level)][name] = values;
        }
        updatePicklistCache(localPicklistData);
    }
}

/**
 * Returns an object having picklist data
 */
function getCachedPicklistData() {
    return localStorage.picklistData ? JSON.parse(localStorage.picklistData) : null;
}

/**
 * Update picklist cache with object passed in as string
 */
function updatePicklistCache(picklistData) {
    localStorage.picklistData = JSON.stringify(picklistData);
}

/**
 * Get property name based on picklist level
 */
function getPropertyName(level) {
    var propName = '';
    if (level == 1) {
        propName = 'level1PicklistValues';
    } else if (level == 2) {
        propName = 'level2PicklistValues';
    } else if (level == 3) {
        propName = 'level3PicklistValues';
    } else if (level == 4) {
        propName = 'level4PicklistValues';
    }
    return propName;
}

/**
 * Set listeners for collapsible sections in the page
 */
function setCollapsibleListeners() {
    // Add click listener for collapsible sections
    j$('body').on('click',
        '[id$=searchResultsSection] > div > img,' +
        '[id$=selectedExpertsSection] > div > img',
        function() {
            toggleCollpasibleSection(this);
        }
    );
}

/**
 * Collapses or Expands section based on it's previous state
 */
function toggleCollpasibleSection(clickedElement) {
    j$(clickedElement).parent().parent().siblings().closest('.collapsiblePanel').toggle();
}

/**
 * Sets the section state as collapsed/expanded
 */
function setSectionState() {
    if(isOpenedFromTab()) {
        // Collapse search result section
        j$('[id$=searchResultsSection] > div > img').trigger('click');
    }
}

/**
 * Returns a boolean which tells if page was opened from tab or custom button
 */
function isOpenedFromTab() {
    return !getUrlParameter('id');
}

/**
 * Returns value for parameter name passed to it
 */
function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;
    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
}

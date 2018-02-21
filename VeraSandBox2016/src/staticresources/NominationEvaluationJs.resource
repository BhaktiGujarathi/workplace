j$ =  jQuery.noConflict();

j$(document).on('ready',
    function() {
        setCollapsibleListeners();
        setSectionState();
    }
);

/**
 * Set listeners for collapsible sections in the page
 */
function setCollapsibleListeners() {
    // Add click listener for collapsible sections
    j$('body').on('click',
        '[id$=nominationsSection] > div > img,' +
        '[id$=evaluationsSection] > div > img,' +
        '[id$=summarySection] > div > img',
        function() {
            toggleCollpasibleSection(this);
        }
    );
}

/**
 * Collapses or Expands section based on it's previous state
 */
function toggleCollpasibleSection(clickedElement) {
    j$(clickedElement).parent().parent().siblings().closest('span.collapsiblePanel').toggle();
}

/**
 * Sets the section state as collapsed/expanded
 */
function setSectionState() {
    if(isOpenedFromTab()) {
        // Collapse all
        j$('.sectionHeader').parent().find('img').trigger('click');
    }
    else {
        // Expand Nomination section, Collapse others
        j$('[id$=evaluationsSection] > div > img').trigger('click');
        j$('[id$=summarySection] > div > img').trigger('click');
    }
}

/**
 * Returns a boolean which tells if page was opened from tab or custom button
 */
function isOpenedFromTab() {
    return !getUrlParameter('id');
}

/**
 * Function called on selection of training using lookup
 */
function onTrainingSelect(event) {
    // Set Training name in header
    j$('#trainingNameSpan').html(event.target.value);
    // Load nomination records
    loadNominations();
}

/**
 * Hide/Show New Evaluation row when Save call is complete
 */
function toggleEvaluationRowOnSave() {
    var isRecordSaved = j$('input[id$=savedIndicator]').val();
    if (isRecordSaved === 'true') {
        hideAddEvaluationRow();
    }
    else {
        showAddEvaluationRow();
    }
}

/**
 * Show the editable row for adding evaluation
 */
function showAddEvaluationRow() {
    j$('#newEvaluationRow').show();
}

/**
 * Hide the editable row for adding evaluation
 */
function hideAddEvaluationRow() {
    j$('#newEvaluationRow').hide();
}

/**
 * This function returns parameter value for paramter name passed to it
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

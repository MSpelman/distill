// Function to sort the products table by clicking on a column header
// JavaScript & jQuery by Jon Duckett was used as a reference, but every attempt was made
// to program this on my own.  Thus my version is very different and has unique
// functionality not found in the book's code.
function sort() {
  // Create object to store functions that format and compare the different column data
  // types
  var compareObj = {
    name: function(a, b) {
      if (a < b) {
        return -1;
      } else if (a > b) {
        return 1;
      } else {
        return 0;
      }
    },
    number: function(a, b) {
      a = Number(a);
      b = Number(b);
      return a - b;
    },
    date: function(a, b) {
      if (a === '') a = '1970-01-01';  // Blank should be sorted to bottom
      a = new Date(a);
      if (b === '') b = '1970-01-01';
      b = new Date(b);
      return b - a;
    },
    rating: function(a, b) {
      a = Number(a.split('(')[0]);
      if (isNaN(a)) a = -1;  // If no rating, put at bottom of list
      b = Number(b.split('(')[0]);
      if (isNaN(b)) b = -1;
      return b - a; // The default order is to have highest rated products first
    },
    boolean: function(a, b) {
      // Active (i.e. true) should be before inactive (i.e. false|nil) in ascending sort
      a = (a === 'true') ? 1 : 2;
      b = (b === 'true') ? 1 : 2;
      return a - b;
    },
    rplfwd: function(a, b) {
      // Messages that were not a reply/forward (i.e. '') should be after messages that
      // were a reply/forward (i.e. not '') in ascending sort
      a = (a === '') ? 2 : 1;
      b = (b === '') ? 2 : 1;
      return a - b;
    },
    subject: function(a, b) {
      a = a.replace(' (Reply)*', '').toUpperCase();
      b = b.replace(' (Reply)*', '').toUpperCase();

      if (a < b) {
        return -1;
      } else if (a > b) {
        return 1;
      } else {
        return 0;
      }
    }
  };
  // Loop on all the tables with class of sortable-table, as this can handle multiple
  // sortable tables on the same page.
  $('table.sortable-table').each(function() {
    // Set up variables specific to each table
    var $table = $(this);
    var $tbody = $table.find('tbody');
    var $headers = $table.find('th');
    var rows = []  // This needs to be an array so can use sort() and reverse()
    rows = $tbody.find('tr').toArray();

    // Add event listener to each column heading
    $headers.on('click', function() {
      // Set up variables for each header/listener
      var $header = $(this);
      var dataType;
      var columnIndex; // The index of the column being sorted

      // Already sorted on this column; just change sort order
      // default and reversed are used instead of ascending and descending because the
      // primary sort order for ratings and dates is to put the highest first 
      // (descending), while the primary sort order for all the rest is ascending
      if ($header.is('.default') || $header.is('.reversed')) {
        $header.toggleClass('default reversed');
        $tbody.append(rows.reverse());
      } else {  // Not already sorted on that column
        $headers.removeClass('default reversed');
        $header.addClass('default');
        dataType = $header.data('sort');
        if (compareObj.hasOwnProperty(dataType)) {
          columnIndex = $headers.index(this);
          rows.sort(function(a, b) {
            a = $(a).find('td').eq(columnIndex).text();
            b = $(b).find('td').eq(columnIndex).text();
            return compareObj[dataType](a, b);
          });
          $tbody.append(rows);
        }
      }
    });
  });
}
// Function used for record selection 
function recordSelect(containerId) {
  if (containerId.charAt(0) !== '#') {
    containerId = '#' + containerId;
  }
  // Set up variables
  var $selectContainer = $(containerId);
  var $lookupForm = $selectContainer.find('.record-lookup-form');
  var $lookupTextField = $selectContainer.find('.record-lookup');
  var $searchButton = $selectContainer.find('.record-search-button');
  var $recordSelect = $selectContainer.find('div.select-record');
  var $recordTable = $recordSelect.find('div.record-lookup-table');
  var $recordSelectRows = $recordSelect.find('tbody tr');
  var $cancelLink = $recordSelect.find('a.select-cancel');
  var $selectedRecordDisplay = $selectContainer.find('.record-display');
  var $selectedRecordField = $selectContainer.next().find('.selected-record');

  // Add event listener to each record select row
  $recordSelectRows.on('click', function(event) {
    var selectedRecordId;
    var selectedRecordName;
    var $selectedRow = $(this);
    event.preventDefault;  // If they click on 'Select' link, don't follow it
    // Display the selected record
    selectedRecordName = $selectedRow.find('td.record-name').text();
    $selectedRecordDisplay.text(selectedRecordName);
    // Store selected record so it is passed to server when form submitted
    selectedRecordId = $selectedRow.attr('id').replace('user_', '');
    $selectedRecordField.val(selectedRecordId);
    $recordTable.remove();  // Remove listing of records to choose from
    $lookupTextField.val('');
    $searchButton.removeAttr('disabled');
  });
  // Add event listener for cancel link
  $cancelLink.on('click', function(event) {
    event.preventDefault;
    $recordTable.remove();
    $lookupTextField.val('');
    $searchButton.removeAttr('disabled');
  });
}
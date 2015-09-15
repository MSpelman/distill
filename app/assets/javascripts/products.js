// JavaScript for filtering a table by type
function filter() {
  var $rows = $('tbody.filtered-table tr');
  var $typeSelect = $('.type-filter').find(':input');  // Selects drop-down list element
    
  $typeSelect.on('change', function() {
    var selectedType = $typeSelect.val();
    // A value of '' corresponds to the user selecting 'All'
    if (selectedType === '') {
      $rows.removeClass('filter-hide');
      $rows.each(function() {
        var $row = $(this);
        // Allow user to use filter and search together
        if (!($row.is('.search-hide'))) {
          $row.show();
        }
      });
    } else {
      $rows.each(function() {
        var $row = $(this);
        var rowType = $row.find('.type').text();
        if (selectedType === rowType) {
          $row.removeClass('filter-hide');
          if (!($row.is('.search-hide'))) {
            $row.show();
          }
        } else {
          $row.addClass('filter-hide');
          $row.hide();
        }
      });
    }
  });
}
// Function to search the products table for a given product name
// JavaScript & jQuery by Jon Duckett was used as a reference, but every attempt was made
// to program this on my own. For example, the ability for the filter and search to work
// together was not in the book.
function search() {
  var $rows = $('tbody tr');
  var $searchField = $('#search-input');
  var cache = [];

  $rows.each(function() {
    var $row = $(this);
    var name = $row.find('td a.name-column').text().trim().toUpperCase();
    cache.push({name: name, jQSelection: $row});
  });

  $searchField.on('input', nameFilter);

  function nameFilter() {
    var searchText = $searchField.val().trim().toUpperCase();

    cache.forEach(function(namedRow) {
      var index = 0
      if (searchText.length > 0) {
        index = namedRow.name.indexOf(searchText);
      }
      if (index === -1) {
        namedRow.jQSelection.addClass('search-hide');
        namedRow.jQSelection.hide();
      } else {
        namedRow.jQSelection.removeClass('search-hide');
        if (!(namedRow.jQSelection.is('.filter-hide'))) {
          namedRow.jQSelection.show();
        }
      }
    });
  }
}
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
      // primary sort order for ratings and release date is to put the highest first 
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

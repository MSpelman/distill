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
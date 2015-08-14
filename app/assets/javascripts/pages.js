// JavaScript to display Google map
function initializeMap() {
  var mapOptions = {
    center: new google.maps.LatLng(47.995865,-88.90929),
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    zoom: 10,
    zoomControl: true,
    zoomControlOptions: {
      style: google.maps.ZoomControlStyle.SMALL,
      position: google.maps.ControlPosition.TOP_LEFT
    },
    scaleControl: false,
    mapTypeControl: true,
    mapTypeControlOptions: {
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
      position: google.maps.ControlPosition.TOP_RIGHT
    },
    streetViewControl: false,
    rotateControl: false,
    overviewMapControl: false
  };
  var map;
  map = new google.maps.Map(document.getElementById('map'), mapOptions);
  var markerLocation = new google.maps.LatLng(47.995865,-88.90929);
  var marker = new google.maps.Marker({
    position: markerLocation,
    map: map,
    icon: "/assets/pin.jpg"
  });
}

// JavaScript to display slide show
// I realize there are a number of JavaScript libraries that allow you to create
// UI features like this without having to program them from scratch. The purpose
// of this is to show I know the basics of JavaScript and jQuery.
// JavaScript & jQuery by Jon Duckett was used as a reference, but every attempt was made
// to program this on my own.
function slideShow() {
  $('.slide-viewer').each(function() {
    // set up variables specific to each slider
    var $this = $(this);  // jQuery selection for the slide-viewer
    var $container = $this.find('.slide-container');
    var $slides = $this.find('.slide');
    var buttons = [];  // Array for the buttons that allow you to select a slide
    var currentIndex = 0;  // Index of slide currently on
    var timer;  // timer to change slide every 5 s
    var $slideButtons = $this.next();  // Could be > 1 slideshow on page; get right one

    // Create button for each slide
    $slides.each(function(index) {
      var $button = $('<button type="button" class="slide-button"></button>');
      if (index === currentIndex) {
        $button.addClass('selected');
      }
      $button.on('click', function() {
        move(index);
      });
      $slideButtons.append($button);
      buttons.push($button);
    });

    // Start timer; at this point the script is done, rest of code is just functions
    autoAdvance();

    // Function to move new slide into view and hides old one
    function move(newIndex) {
      var newSlidePosition, animationDirection;

      autoAdvance();  // Reset timer

      // slide @ newIndex already selected or previous selection still animating,
      // so don't change slide 
      if ((newIndex === currentIndex) || ($container.is(':animated'))) {
        return;
      }

      // Update which button is selected
      buttons[currentIndex].removeClass('selected');
      buttons[newIndex].addClass('selected');

      // Determine which direction the slides should animate
      if (newIndex > currentIndex) {
        newSlidePosition = '100%';  // New slide should be placed on right of current
        animationDirection = '-100%';  // Slides should animate from right to left
      } else {
        newSlidePosition = '-100%';  // New slide should be placed on left of current
        animationDirection = '100%';  // Slides should animate from left to right
      }

      // Position new slide
      $slides.eq(newIndex).css({left: newSlidePosition, display: 'block'});
      // Animate new slide into view
      $container.animate({left: animationDirection}, function() {
        $slides.eq(currentIndex).css({display: 'none'});  // Hide old slide
        $slides.eq(newIndex).css({left: '0'});
        $container.css({left: '0'});  // Make sure container back where it should be
        currentIndex = newIndex;  // All done, update currentIndex
      });
    }

    // Creates timer to auto-advance slide
    function autoAdvance() {
      clearTimeout(timer);  // Clear old timer
      timer = setTimeout(function() {
        if (currentIndex === ($slides.length - 1)) {
          move(0);
        } else {
          move(currentIndex+1);
        }
      }, 5000);
    }
  });
}
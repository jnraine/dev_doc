// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

(function($) {
	$(document).on("ready page:load", function() {
		var toggleOverlay = function(overlay, action) {
			if(action !== "close") {
				$.each(overlays, function(index, otherOverlay) {
					if(otherOverlay != overlay) {
						toggleOverlay(otherOverlay, "close");
					}
				});
			}

			var $overlay = $(overlay);

			if ($overlay.hasClass('open') && action !== "open") {
				$overlay.removeClass('open');
				$overlay.addClass('close');

				var onEndTransitionFn = function( ev ) {
					if( ev.propertyName !== 'visibility' ) return;
					this.removeEventListener("transitionend", onEndTransitionFn);
					$overlay.removeClass('close');
				};

				overlay.addEventListener("transitionend", onEndTransitionFn);
			} else if (!$overlay.hasClass('close') && action !== "close") {
				$overlay.addClass('open');
				$overlay.find("input").focus();
			}
		}

		var overlays = [];

		function initializeOverlay(overlaySelector, triggerSelector, triggerKeyCode) {
			var triggerEl = document.querySelector(triggerSelector);
	    var overlay   = document.querySelector(overlaySelector);

			triggerEl.addEventListener('click', function() { toggleOverlay(overlay) });

			$(overlay).click(function(event) {
				console.log(event.target);
		    if($(event.target).is(".overlay,nav")) {
		    	toggleOverlay();
		    }
			});

			$(document).keyup(function(e) {

				var escKey = 27;

			  if (e.keyCode == escKey) {
			  	toggleOverlay(overlay, "close");
			  } else if(e.keyCode == triggerKeyCode) {
					// Skip when accepting user input
					if(document.activeElement.tagName == "INPUT") {
						return;
					}

			  	toggleOverlay(overlay);
			  }
			});

			overlays.push(overlay);
		}

		//
		// Wire up overlays
		//
		var tKey = 84;
		var nKey = 78;

		initializeOverlay(".nav-overlay", "#js-nav-trigger", nKey);
		initializeOverlay(".search-overlay", "#js-search-trigger", tKey);

		//
		// Search magic
		//
		$(document).on("keyup focus", ".search-overlay input", function() {
			var searchTerms = $(this).val().replace(/^\s+|\s+$/g, "").split(/\s+/);

			$(".search-overlay li a").each(function(index, link) {
				var text = $(link).text();
				// var html = $(link).html();
				var score = 0;
				var regexString = "(" + searchTerms.join("|") + ")"; // /(foo|bar|baz)/
				var regex = new RegExp(regexString, "ig");

				score += (text.match(regex) || []).length;

				// matchHighlighted = html.replace(regex, "<strong>$1</strong>");
				// $(link).data("score", score).html(matchHighlighted);

				if(score > 0) {
					$(link).parent().show();
				} else {
					$(link).removeClass("selected").parent().hide();
				}
			}).sort(function(a, b) {
				var scoreA = $(a).data("score");
				var scoreB = $(b).data("score");

				if(scoreA == scoreB) { // compare alphabetically
					if($(a).text().toLowerCase() < $(b).text().toLowerCase()) {
						return 1
					} else {
						return -1;
					}
				} else { // compare by score
					return scoreA - scoreB;
				}
			}).each(function() {
				var listItem = $(this).parent();
				var list = listItem.parents("ul").first();

				listItem.prependTo(list);
			});

			if($(".search-overlay li a.selected").length == 0) {
				$(".search-overlay li a").not(":hidden").first().addClass("selected");
			}
		});

		$(document).on("keydown", ".search-overlay input", function(e) {
			var upKey = 38;
			var downKey = 40;
			var enterKey = 13;
			var selectedLink = $(".search-overlay li a.selected");

			if (e.keyCode == upKey) {
				var prevItem = selectedLink.removeClass("selected").parent().prev();


			// A bug exists, causing this to not work when there are hidden elements at the top or end of the list
				if(prevItem.length == 0) { // get last list item if we're at the start of the list
					var prevItem = selectedLink.parents("ul").children("li").last();
				}

				prevItem.children("a").first().addClass("selected");

				e.preventDefault();
			} else if (e.keyCode == downKey) {
				var nextItem = selectedLink.removeClass("selected").parent().next();

				if(nextItem.length == 0) { // get first list item if we're at the end of the list
					var nextItem = selectedLink.parents("ul").children("li").first();
				}

				nextItem.children("a").first().addClass("selected");
				e.preventDefault();
			} else if (e.keyCode == enterKey) {
				window.location.href = $(".search-overlay li a.selected").attr("href");
				e.preventDefault();
			}
		});


		$("iframe").load(function() {
			$(this).parent().find(".iframe-loading").remove();
		});
	});

	$(document).trigger("ready");
})(jQuery);

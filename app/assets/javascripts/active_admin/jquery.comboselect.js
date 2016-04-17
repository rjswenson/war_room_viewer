// jQuery comboselect plugin
//
// version 2.0.0

// Versions 2+ represent a reworking of the plugin.  See Jason Huck's site for the original
// I used spring board. http://devblog.jasonhuck.com/
//
// This reworking add efficiency and some options and a bug fix for the invalid markup.
// Its also done with jQuery 1.4 in mind.
// Sorting is removed for the time being.

// ------------------------------------------------------------------------------------
//
// Transforms a single select element into a pair of multi-selects
// with controls to move items left to right and vice versa.
// items are submitted by the original form element. Double-clicking
// moves an item from one side to the other.
//
//
// Usage: $('#myselect').comboselect({
//            sort: 'both',  // sort which sides? 'none'|'left'|'right'|'both'
//            addremall : true,  // include the add/remove all buttons
//            add_allbtn: ' &gt;&gt; ',   // label for the "add all" button
//            rem_allbtn: ' &lt;&lt; ',    // label for the "remove all" button
//            addbtn: ' &gt; ',// text of the "add" button
//            rembtn: ' &lt; ',// text of the "remove" button
//            cs_container: 'div', //  html tag to contain both comboselects
//            btn_container: 'div' // html tag to contain the comboselect buttons
//            addbtn: [string,default:' &gt; '], // label for the "add" button
//            rembtn: [string,default:' &lt; ']// label for the "remove" button
//            });
// To set for legeacy compatibility, define the following after you include the plugin, but before you 'wire' it to anything:

//     jQuery.fn.comboselect.defaults = {
//         sort: 'both',
//         addremall : false,
//        addbtn: ' &gt; ',
//         rembtn: ' &lt; ',
//         cs_container: 'fieldset',
//         btn_container: 'fieldset'
//     };
// This method can be used for any defaults you prefer, so you do not have to set options on each use of the comboselect.
//
//
// Version History
// 2.0.0 Reworking release, no sorting
//       * Removed selso dependency
//       * Added ability to set global options
//       * Added add/remove all button and text options
//       * Changed fieldsets to divs for select and button containers
//       * Added option to specify container element for generated selects
//       * Added option to specify container element for generated buttons
//
// 1.0.2 Now works correctly if the form is not the immediate parent of the select.
//       Clears originally selected options before updating with user's new selections on submit.
//       Correctly transforms selects whose options were added dynamically.
// 1.0.1 Correctly transforms inputs which already had options selected.
// 1.0.0 Initial release.

(function($){
  jQuery.fn.comboselect = function(settings){
    settings = jQuery.extend({
      sort: 'both',  // sort which sides? 'none'|'left'|'right'|'both'
      addremall : true,  // include the add/remove all buttons
      updown : true,  // include the up/down buttons
      add_allbtn: ' &gt;&gt; ',   // label for the "add all" button
      rem_allbtn: ' &lt;&lt; ',    // label for the "remove all" button
      upbtn: '&#x2191;',  // label for the "up" button
      downbtn: '&#x2193;',  // label for the "down" button
      addbtn: ' &gt; ',// text of the "add" button
      rembtn: ' &lt; ',// text of the "remove" button
      leftlabel: null, // text to appear above left select
      rightlabel: null, // text to appear above right select
      cs_container: 'div', //  html tag to contain both comboselects
      btn_container: 'div' // html tag to contain the comboselect buttons
    }, jQuery.fn.comboselect.defaults, settings);

    this.each(function(){
      $this = $(this);
      // the id of the original element
      var selectID = this.id;

      // ids for the left and right sides the combo box
      var leftID = selectID + '_left';
      var rightID = selectID + '_right';

      // ids for add and remove buttons
      var addID = selectID + "_add";
      var removeID = selectID + "_remove";

      // ids for up and down buttons
      var upID = selectID + "_up";
      var downID = selectID + "_down";

      // place to store markup for the combo box
      var combo = '';

      // copy of selected and not selected  options from original select
      var selectedOptions = $this.find('option:selected').clone();
      var unSelectedOptions = $this.find('option:not(:selected)').clone();

      // build the combo box
      combo += '<' + settings.cs_container + ' class="comboselect">';
      if(settings.leftlabel) {
        combo += '<p class="leftlabel">' + settings.leftlabel + '</p>';
      }
      combo += '<select id="' + leftID + '" name="' + leftID + '" class="csleft" multiple="multiple">';
      combo += '</select>';
      combo += '<' + settings.btn_container + ' class="cs-buttons">';
      if(settings.updown){
        combo += '<input type="button" class="csup" id="' + upID + '" value="' + settings.upbtn + '" />';
      }
      combo += '<input type="button" class="csadd" id="' + addID + '" value="' + settings.addbtn + '" />';
      if(settings.addremall){
        combo += '<input type="button" class="csadd" id="' + addID + '_all" value="' + settings.add_allbtn + '" />';
        combo += '<input type="button" class="csremove" id="' + removeID + '_all" value="' + settings.rem_allbtn + '" />';
      }
      combo += '<input type="button" class="csremove" id="' + removeID + '" value="' + settings.rembtn + '" />';
      if(settings.updown){
        combo += '<input type="button" class="csdown" id="' + downID + '" value="' + settings.downbtn + '" />';
      }
      combo += '</' + settings.btn_container + '>';
      if(settings.rightlabel) {
        combo += '<p class="rightlabel">' + settings.rightlabel + '</p>';
      }
      combo += '<select id="' + rightID + '" name="' + rightID + '" class="csright" multiple="multiple">';
      combo += '</select>';
      combo += '</' + settings.cs_container + '>';

      // hide the original element and
      // add the combo box after it
      $this.hide().after(combo);

      // find the combo box in the DOM and append
      // a copy of the unselected options
      // element to the left side
      $('#' + leftID).append(unSelectedOptions);

      // and selected on the right
      $('#' + rightID).append(selectedOptions);

      var leftSelect = $("#" + leftID);
      var rightSelect = $("#"+ rightID);
      var originalSelect = $("#" + selectID)

      // bind add and remove buttons
      $("#" + addID).click(function(){
        addSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect, 'right');
      });

      $("#" + removeID).click(function(){
        removeSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect, 'left');
      });

      // bind add and remove all buttons
      $("#" + addID + "_all").click(function(){
        addAllSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect, 'right');
      });

      $("#" + removeID + "_all").click(function(){
        removeAllSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect,'left');
      });

      // bind double clicking options
      $("#" + leftID).dblclick(function(){
        addSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect,'right');
      });

      $("#" + rightID).dblclick(function(){
        removeSelections(leftSelect, rightSelect, originalSelect);
        sortSelects(leftSelect, rightSelect, originalSelect,'left');
      });

      // bind up and down buttons
      $("#" + upID).click(function(){
        moveSelectionsUp(rightSelect, originalSelect);
      });

      $("#" + downID).click(function(){
        moveSelectionsDown(rightSelect, originalSelect);
      });

    });

    function moveSelectionsUp(select, original) {
      var selected = select.find(":selected");
      selected.each(function() {
        var sibling = this.previousElementSibling;
        if (!sibling || sibling.selected) {
          return;
        }

        this.parentNode.insertBefore(this, sibling);

        var originalNode = original.find('option[value="' + $(this).val() + '"]');
        var prevSelected = originalNode.prevAll(":selected");
        originalNode.insertBefore(prevSelected[0]);
      });
    }

    function moveSelectionsDown(select, original) {
      var selected = select.find(":selected");
      for (var i = selected.length - 1; i >= 0; i--) {
        var node = selected.get(i);
        var sibling = node.nextElementSibling;
        if (!sibling || sibling.selected) {
          return;
        }

        sibling = sibling.nextElementSibling;

        if (sibling) {
          $(node).insertBefore(sibling);
        } else {
          select.append(node);
        }

        var originalNode = original.find('option[value="' + $(node).val() + '"]');
        var nextSelected = originalNode.nextAll(":selected");
        var nextNode = nextSelected.get(0);
        nextNode = nextNode.nextElementSibling;
        if (nextNode) {
          originalNode.insertBefore(nextNode);
        } else {
          $(original).append(originalNode);
        }
      }
    }

    function addSelections(left, right, original){
      var selected = left.find(":selected");
      right.append(selected);
      selected.each(function(){
        original.find('option[value="' + $(this).val() + '"]').attr('selected','selected');
      });
    }

    function removeSelections(left, right, original){
      var selected = right.find(":selected");
      left.append(selected);
      selected.each(function(){
        original.find('option[value="' + $(this).val() + '"]').removeAttr('selected');
      });
    }

    function addAllSelections(left, right, original){
      right.append(left.find('option'));
      original.find('option').attr('selected','selected');
    }

    function removeAllSelections(left, right, original){
      left.append(right.find('option'));
      original.find('option').removeAttr('selected');
    }

    function sortSelects(left, right, original, side){
      var order = jQuery.map(original.find('option'), function(option){
        var $option = $(option);
        return $option.attr("value") + $option.text()
      });

      if((settings.sort == 'both' || settings.sort == 'right') && side == 'right' ){
        sortSelect(right, order);
      }
      if((settings.sort == 'both' || settings.sort == 'left') && side == 'left' ){
        sortSelect(left, order);
      }
    }

    function sortSelect(sortable, order){
      var sorted = sortable.find('option').sort(function(a,b){
        var $a = $(a); var $b = $(b);
        cA = jQuery.inArray($a.attr("value") + $a.text(), order);
        cB = jQuery.inArray($b.attr("value") + $b.text(), order);
        return (cA < cB) ? -1 : (cA > cB) ? 1 : 0;
      });
      sortable.append(sorted);
    }

    return this;
  };
})(jQuery);

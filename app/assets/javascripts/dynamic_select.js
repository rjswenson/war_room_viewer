var dynamicSelect = {
  init: function(){
    dynamicSelect.set_dynamic_select_boxes();
  },

  set_dynamic_select_boxes: function(){
    $("select[data-dynamic-collection]").each(function() {
      collections = $(this).data('dynamic-collection');
      event_id = Object.keys(collections)[0];
      tags = collections[event_id];
      target_id = $(this).attr('id');
      model = target_id.split('_')[0];
      event_id = model + "_" + event_id;

      $('#' + event_id).change(function() {
        selected = $(this).children().filter(':selected').first().text();
        relevant_tags = tags[selected];
        $('#' + target_id).find('option').remove();
        $.each(relevant_tags, function(index, value) {
          $('#' + target_id).append('<option value="' + value + '">' + value + '</option>')
        })
      })
    })
  }
}

$( document ).ready(function() {
  dynamicSelect.init();
});
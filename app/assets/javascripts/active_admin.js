//= require active_admin/base
//= require chosen-jquery
//= require nested_form_ui/sortable
//= require jquery-ui
//= require_tree ./active_admin
var admin = {

  init: function(){
    admin.set_admin_editable_events();
  },

  set_admin_editable_events: function(){
    $(".admin-editable").on("keypress", function(e){
      if ( e.keyCode==27 )
        $( e.currentTarget ).hide();

      if ( e.keyCode==13 ){
        var path        = $( e.currentTarget ).attr("data-path");
        var attr        = $( e.currentTarget ).attr("data-attr");
        var resource_id = $( e.currentTarget ).attr("data-resource-id");
        var val         = $( e.currentTarget ).val();

        val = $.trim(val)
        if (val.length==0)
          val = "&nbsp;";

        $("div#"+$( e.currentTarget ).attr("id")).html(val);
        $( e.currentTarget ).hide();
        $(this).closest('tr').next().find('.editable_text_column').dblclick();

        var payload = {}
        resource_class = path.slice(0,-1) // e.g. path = meters, resource_class = meter
        payload[resource_class] = {};
        payload[resource_class][attr] = val;

        $.ajax({
          type: 'PUT',
          url: "/admin/"+path+"/"+resource_id,
          data: payload,
          dataType: "json",
          success: function(){console.log('updated '+resource_class)}
        });
      }
    });

    $(".admin-editable").on("blur", function(e){
      $( e.currentTarget ).hide();
    });
  },

  editable_text_column_do: function(el){
    var input = "input#"+$(el).attr("id")

    $(input).width( $(el).width()+4 ).height( $(el).height()+4 );
    $(input).css({top: ( $(el).offset().top-2 ), left: ( $(el).offset().left-2 ), position:'absolute'});

    val = $.trim( $(el).html() );
    if (val=="&nbsp;")
      val = "";

    $(input).val( val );
    $(input).show();
    $(input).focus().select();
  }
}

$( document ).ready(function() {
  admin.init();

  // Hack to allow multiple sortable nested forms in one page.
  setTimeout(function() {
    window.nestedFormEvents.insertFields = function(content, assoc, link) {
      return $(link).parent().siblings('.nested-form-sortable').append($(content));
    }
  }, 1000);
});

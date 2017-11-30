$(function(){
  $('input[type="file"]').change(function(){
    var chosen_file_name = $(this)[0].files[0].name;
    if(chosen_file_name.match(/\.pdf$/)){
      $('#slide_file_name_field').text(chosen_file_name);
      $('#upload_confirmation_btn').prop('disabled', false);
    }else{
      $('#slide_file_name_field').text("Chosen file is not PDF...");
    }
  });

  var file_name = $('#file_name_link').text();
  $('input[name="slide_title"]').keyup(function(){
    var entered_file_name = $(this)[0].value;
    if(file_name == entered_file_name){
      $('#delete_confirmation_btn').prop('disabled', false);
    }
  });
});
